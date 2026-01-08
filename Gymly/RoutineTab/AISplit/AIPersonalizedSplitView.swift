//
//  AIPersonalizedSplitView.swift
//  ShadowLift
//
//  Created by Claude Code on 05.01.2026.
//

import SwiftUI
import SwiftData

@available(iOS 26, *)
struct AIPersonalizedSplitView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @Environment(\.colorScheme) var scheme

    @StateObject private var generator = SplitGeneratorService()
    @State private var preferences: SplitPreferences
    @State private var currentStep = 1
    @State private var currentPhase: GenerationPhase = .questionnaire
    @State private var showModifySheet = false
    @State private var showSaveConfirmation = false
    @State private var isSaving = false

    enum GenerationPhase {
        case questionnaire
        case generating
        case preview
    }

    init(viewModel: WorkoutViewModel, config: Config) {
        self.viewModel = viewModel

        // Initialize preferences from existing fitness profile
        if let profile = config.fitnessProfile {
            _preferences = State(initialValue: SplitPreferences(from: profile))
        } else {
            _preferences = State(initialValue: SplitPreferences())
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                FloatingClouds(theme: CloudsTheme.appleIntelligence(scheme))
                    .ignoresSafeArea()

                // Main content based on phase
                Group {
                    switch currentPhase {
                    case .questionnaire:
                        SplitQuestionnaireView(
                            preferences: $preferences,
                            currentStep: $currentStep,
                            onComplete: startGeneration
                        )

                    case .generating, .preview:
                        GeneratedSplitPreviewView(
                            generatedSplit: generator.generatedSplit,
                            isGenerating: generator.isGenerating,
                            onSave: { showSaveConfirmation = true },
                            onModify: { showModifySheet = true }
                        )
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if currentPhase == .preview && !generator.isGenerating {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            regenerateSplit()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showModifySheet) {
            SplitChatModificationView(
                generator: generator,
                onApply: {
                    showModifySheet = false
                },
                onCancel: {
                    showModifySheet = false
                }
            )
        }
        .alert("Save Split?", isPresented: $showSaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                saveSplit()
            }
        } message: {
            if let name = generator.generatedSplit?.name {
                Text("This will add \"\(name)\" to your splits and set it as active.")
            } else {
                Text("This will add the generated split to your collection.")
            }
        }
        .onAppear {
            generator.prewarm()
        }
    }

    // MARK: - Computed Properties

    private var navigationTitle: String {
        switch currentPhase {
        case .questionnaire:
            return "AI Split Generator"
        case .generating:
            return "Generating..."
        case .preview:
            return "Your Split"
        }
    }

    // MARK: - Actions

    private func startGeneration() {
        currentPhase = .generating

        Task {
            do {
                try await generator.generateSplit(preferences: preferences)
                currentPhase = .preview
            } catch {
                debugLog("Error generating split: \(error)")
                // Stay on preview phase to show error state
                currentPhase = .preview
            }
        }
    }

    private func regenerateSplit() {
        generator.clearSplit()
        currentPhase = .generating

        Task {
            do {
                try await generator.generateSplit(preferences: preferences)
                currentPhase = .preview
            } catch {
                debugLog("Error regenerating split: \(error)")
                currentPhase = .preview
            }
        }
    }

    private func saveSplit() {
        guard let generatedSplit = generator.generatedSplit,
              let name = generatedSplit.name,
              let days = generatedSplit.days else {
            return
        }

        isSaving = true

        // Deactivate all existing splits
        viewModel.deactivateAllSplits()

        // Create new Split
        let newSplit = Split(
            name: name,
            days: [],
            isActive: true,
            startDate: Date()
        )

        // Create Days from generated data
        var createdDays: [Day] = []

        for genDay in days {
            guard let dayNumber = genDay.dayNumber,
                  let dayName = genDay.name else { continue }

            let day = Day(
                name: dayName,
                dayOfSplit: dayNumber,
                exercises: [],
                date: "",
                isRestDay: genDay.isRestDay ?? false
            )

            // Create Exercises (skip for rest days)
            if genDay.isRestDay != true, let genExercises = genDay.exercises {
                var createdExercises: [Exercise] = []

                for genExercise in genExercises {
                    guard let exerciseName = genExercise.name,
                          let muscleGroup = genExercise.muscleGroup,
                          let repRange = genExercise.repRange,
                          let sets = genExercise.sets,
                          let order = genExercise.exerciseOrder else { continue }

                    let exercise = Exercise(
                        name: exerciseName,
                        sets: [],
                        repGoal: repRange,
                        muscleGroup: muscleGroup,
                        exerciseOrder: order
                    )

                    context.insert(exercise)

                    // Create placeholder sets
                    var exerciseSets: [Exercise.Set] = []
                    for _ in 1...sets {
                        let set = Exercise.Set.createDefault()
                        context.insert(set)
                        exerciseSets.append(set)
                    }
                    exercise.sets = exerciseSets

                    createdExercises.append(exercise)
                }

                day.exercises = createdExercises
            }

            context.insert(day)
            createdDays.append(day)
        }

        newSplit.days = createdDays
        context.insert(newSplit)

        // Save to SwiftData
        do {
            try context.save()
            debugLog("AI Generated split saved: \(name)")

            // Update config
            config.splitStarted = true
            config.dayInSplit = 1
            config.splitLength = createdDays.count

            // Dismiss the view
            dismiss()
        } catch {
            debugLog("Error saving AI split: \(error)")
            isSaving = false
        }
    }
}

// MARK: - Preview Provider

@available(iOS 26, *)
#Preview {
    // Preview would require proper setup with Config and ViewModel
    Text("AI Personalized Split View")
}
