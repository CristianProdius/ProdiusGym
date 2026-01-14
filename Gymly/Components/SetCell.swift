//
//  SetCellView.swift
//  ProdiusGym
//
//  Created by Sebastián Kučera on 07.03.2025.
//


import SwiftUI

struct SetCell: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var appearanceManager: AppearanceManager
    var index: Int
    var set: Exercise.Set
    var config: Config
    var exercise: Exercise
    var setForCalendar: Bool
    var onSetTap: ((Exercise.Set) -> Void)? = nil
    @State private var showEditSheet = false

    // PR tracking
    @State private var isPR: Bool = false
    @StateObject private var prManager = PRManager.shared

    // Computed properties to break down complex expressions
    private var weightUnit: String {
        userProfileManager.currentProfile?.weightUnit ?? "Kg"
    }

    private var weightConversionFactor: Double {
        weightUnit == "Kg" ? 1.0 : 2.20462
    }

    /// Build accessibility label for VoiceOver
    private func buildSetAccessibilityLabel() -> String {
        var parts: [String] = []

        // Weight
        let weight = Int(round(Double(set.weight) * weightConversionFactor))
        if set.bodyWeight {
            parts.append("Bodyweight plus \(weight) \(weightUnit)")
        } else {
            parts.append("\(weight) \(weightUnit)")
        }

        // Reps
        parts.append("\(set.reps) reps")

        // Set type indicators
        if set.warmUp {
            parts.append("warm-up set")
        }
        if set.failure {
            parts.append("to failure")
        }
        if set.restPause {
            parts.append("rest-pause")
        }
        if set.dropSet {
            parts.append("drop set")
        }
        if isPR && !set.warmUp {
            parts.append("personal record")
        }

        // Completion status
        if !set.time.isEmpty {
            parts.append("completed at \(set.time)")
        }

        return parts.joined(separator: ", ")
    }

    var body: some View {
        Section("Set \(index + 1)") {
            Button {
                if setForCalendar == false {
                    debugLog("📱 Tapping set \(index + 1) (ID: \(set.id))")
                    if let onSetTap = onSetTap {
                        // Use callback for external sheet management
                        debugLog("📱 Using callback for set tap")
                        onSetTap(set)
                    } else {
                        // Use internal sheet management
                        debugLog("📱 Using internal sheet - showEditSheet: \(showEditSheet)")
                        showEditSheet = true
                        debugLog("📱 Set showEditSheet to: \(showEditSheet)")
                    }
                }
            } label: {
                HStack {
                    /// Display set details (weight, reps, notes)
                    HStack {
                        if set.bodyWeight {
                            Text("BW  +")
                                .foregroundStyle(PremiumColors.platinum)
                                .bold()
                        }
                        Text("\(Int(round(Double(set.weight) * weightConversionFactor)))")
                            .foregroundStyle(PremiumColors.platinum)
                            .bold()
                        Text("\(weightUnit)")
                            .foregroundStyle(PremiumColors.platinum)
                            .opacity(0.6)
                            .offset(x: -5)
                    }
                    HStack {
                        Text("\(set.reps)")
                            .foregroundStyle(Color.green)
                            .bold()
                        Text("Reps")
                            .foregroundStyle(Color.green)
                            .opacity(0.6)
                            .offset(x: -5)
                    }
                    HStack {
                        if set.failure {
                            Text("F")
                                .foregroundStyle(Color.red)
                                .offset(x: -5)
                        }
                        if set.warmUp {
                            Text("W")
                                .foregroundStyle(Color.orange)
                                .offset(x: -5)
                        }
                        if set.restPause {
                            Text("RP")
                                .foregroundStyle(Color.green)
                                .offset(x: -5)
                        }
                        if set.dropSet {
                            Text("DS")
                                .foregroundStyle(Color.blue)
                                .offset(x: -5)
                        }
                        if isPR && !set.warmUp {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color.yellow)
                                .font(.caption)
                                .offset(x: -5)
                        }
                    }
                    Spacer()
                    Text("\(set.time)")
                        .foregroundStyle(Color.white)
                        .opacity(set.time.isEmpty ? 0 : 0.3)
                }
            }
            .accessibilityLabel(buildSetAccessibilityLabel())
            .accessibilityHint(setForCalendar ? "View only" : "Double tap to edit this set")

            if !set.note.isEmpty {
                Text(set.note)
                    .foregroundStyle(Color.white)
                    .opacity(0.5)
            }
        }
        .sheet(isPresented: onSetTap == nil ? $showEditSheet : .constant(false)) {
            if onSetTap == nil {
                EditExerciseSetView(
                    targetSet: set,
                    exercise: exercise,
                    unit: .constant(weightUnit)
                )
                .onAppear {
                    debugLog("📱 EditExerciseSetView appeared for set \(index + 1)")
                }
                .onDisappear {
                    debugLog("📱 EditExerciseSetView disappeared for set \(index + 1)")
                }
            }
        }
        .onChange(of: showEditSheet) { oldValue, newValue in
            if onSetTap == nil {
                debugLog("📱 showEditSheet changed to: \(newValue) for set \(index + 1)")
            }
        }
        .task {
            // Check if this set is a PR (only for completed sets with time)
            if !set.time.isEmpty && !set.warmUp {
                isPR = await prManager.isSetPR(
                    exerciseName: exercise.name,
                    weight: set.weight,
                    reps: set.reps
                )
            }
        }
        .onChange(of: set.time) { oldTime, newTime in
            // Re-check PR status when set is marked as done
            if !newTime.isEmpty && !set.warmUp {
                Task {
                    isPR = await prManager.isSetPR(
                        exerciseName: exercise.name,
                        weight: set.weight,
                        reps: set.reps
                    )
                    debugLog("⭐ SetCell: PR check for \(exercise.name) - isPR: \(isPR)")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .listRowBackground(Color.black.opacity(0.1))
    }
}
