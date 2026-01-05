//
//  SplitImportPreviewView.swift
//  Gymly
//
//  Preview screen for shared splits before importing
//

import SwiftUI

struct SplitImportPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject var appearanceManager: AppearanceManager

    let split: Split
    let onImport: () -> Void

    @State private var showingImportConfirmation = false

    var totalExercises: Int {
        split.days?.reduce(0) { total, day in
            total + (day.exercises?.count ?? 0)
        } ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Floating clouds background matching app theme
                FloatingClouds(theme: CloudsTheme.accent(scheme, accentColor: appearanceManager.accentColor))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header Card
                        VStack(alignment: .center, spacing: 16) {
                            // Shared Split Badge
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.down.fill")
                                    .font(.caption)
                                Text("Shared Split")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(appearanceManager.accentColor.color.opacity(0.2))
                            .foregroundColor(appearanceManager.accentColor.color)
                            .cornerRadius(20)

                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 60))
                                .foregroundColor(appearanceManager.accentColor.color)

                            Text(split.name)
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 20) {
                                InfoPill(
                                    icon: "calendar",
                                    text: "\(split.days?.count ?? 0) Days",
                                    color: .blue
                                )
                                InfoPill(
                                    icon: "dumbbell.fill",
                                    text: "\(totalExercises) Exercises",
                                    color: .orange
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.3))
                        )

                        // Days Section
                        if let days = split.days?.sorted(by: { $0.dayOfSplit < $1.dayOfSplit }) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Workout Days")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)

                                ForEach(days, id: \.id) { day in
                                    DayPreviewCard(day: day)
                                }
                            }
                        }

                        // Import Button
                        Button(action: {
                            showingImportConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Import Split")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(appearanceManager.accentColor.color)
                            .foregroundColor(.black)
                            .cornerRadius(15)
                        }
                        .padding(.vertical)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .confirmationDialog(
                "Import Split",
                isPresented: $showingImportConfirmation
            ) {
                Button("Import Split") {
                    onImport()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will add \"\(split.name)\" to your splits library.")
            }
        }
    }
}

struct DayPreviewCard: View {
    let day: Day
    @State private var isExpanded = false
    @EnvironmentObject var appearanceManager: AppearanceManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Day \(day.dayOfSplit): \(day.name)")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("\(day.exercises?.count ?? 0) exercises")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(appearanceManager.accentColor.color.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    if let exercises = day.exercises?.sorted(by: { $0.exerciseOrder < $1.exerciseOrder }) {
                        ForEach(Array(exercises.enumerated()), id: \.element.id) { _, exercise in
                            ExercisePreviewRow(exercise: exercise)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.1))
                )
            }
        }
    }
}

struct ExercisePreviewRow: View {
    let exercise: Exercise
    @EnvironmentObject var appearanceManager: AppearanceManager

    var body: some View {
        HStack {
            Circle()
                .fill(appearanceManager.accentColor.color)
                .frame(width: 6, height: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.subheadline)
                    .foregroundColor(.white)

                Text(exercise.repGoal)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            Text(exercise.muscleGroup)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.1))
                .foregroundColor(.white.opacity(0.8))
                .cornerRadius(6)
        }
        .padding(.horizontal)
    }
}

#Preview {
    let previewSplit = Split(
        id: UUID(),
        name: "Push Pull Legs",
        days: [
            Day(
                id: UUID(),
                name: "Push",
                dayOfSplit: 1,
                exercises: [
                    Exercise(
                        id: UUID(),
                        name: "Bench Press",
                        sets: [],
                        repGoal: "8-12",
                        muscleGroup: "Chest",
                        createdAt: Date(),
                        exerciseOrder: 1
                    ),
                    Exercise(
                        id: UUID(),
                        name: "Overhead Press",
                        sets: [],
                        repGoal: "8-12",
                        muscleGroup: "Shoulders",
                        createdAt: Date(),
                        exerciseOrder: 2
                    )
                ],
                date: ""
            ),
            Day(
                id: UUID(),
                name: "Pull",
                dayOfSplit: 2,
                exercises: [
                    Exercise(
                        id: UUID(),
                        name: "Deadlift",
                        sets: [],
                        repGoal: "5",
                        muscleGroup: "Back",
                        createdAt: Date(),
                        exerciseOrder: 1
                    )
                ],
                date: ""
            )
        ],
        isActive: false,
        startDate: Date()
    )

    SplitImportPreviewView(split: previewSplit) {
        print("Import tapped")
    }
    .environmentObject(AppearanceManager())
}
