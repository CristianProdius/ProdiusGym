//
//  CreateExerciseView.swift
//  ProdiusGym
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import SwiftData

struct CreateExerciseView: View {

    // MARK: - Environment & State
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.colorScheme) var scheme
    @State var day: Day

    // MARK: - Local State
    @State private var name: String = ""
    @State private var sets: String = ""
    @State private var reps: String = ""
    @State private var selectedMuscleGroup: String = "Chest"

    // MARK: - Validation

    /// Name is valid if it contains at least 2 alphanumeric characters
    private var isNameValid: Bool {
        let alphanumericCount = name.filter { $0.isLetter || $0.isNumber }.count
        return alphanumericCount >= 2
    }

    /// Sets is valid if it's a number between 1 and 20
    private var isSetsValid: Bool {
        guard let setsInt = Int(sets) else { return false }
        return setsInt > 0 && setsInt <= 20
    }

    /// Reps is valid if it's not empty and contains at least one number
    private var isRepsValid: Bool {
        let trimmed = reps.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.contains(where: { $0.isNumber })
    }

    private var isFormValid: Bool {
        isNameValid && isSetsValid && isRepsValid
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // Exercise Name Section
                Section {
                    TextField("e.g. Bench Press", text: $name)
                } header: {
                    Text("Exercise Name")
                } footer: {
                    nameFooterText
                }
                .listRowBackground(Color.black.opacity(0.1))

                // Sets Section
                Section {
                    TextField("e.g. 3", text: $sets)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Number of Sets")
                } footer: {
                    setsFooterText
                }
                .listRowBackground(Color.black.opacity(0.1))

                // Reps Section
                Section {
                    TextField("e.g. 8-12 or AMRAP", text: $reps)
                } header: {
                    Text("Rep Goal")
                } footer: {
                    repsFooterText
                }
                .listRowBackground(Color.black.opacity(0.1))

                // Muscle Group Section
                Section {
                    Picker("Muscle Group", selection: $selectedMuscleGroup) {
                        ForEach(viewModel.muscleGroupNames, id: \.self) { muscleGroup in
                            Text(muscleGroup).tag(muscleGroup)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(PremiumColors.gold)
                } header: {
                    Text("Target Muscle")
                }
                .listRowBackground(Color.black.opacity(0.1))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDisabled(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        createExercise()
                    } label: {
                        Text("Add")
                            .fontWeight(.semibold)
                            .foregroundStyle(isFormValid ? PremiumColors.gold : .secondary)
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    // MARK: - Footer Views

    @ViewBuilder
    private var nameFooterText: some View {
        if name.isEmpty {
            Text("What exercise are you adding?")
                .foregroundColor(.secondary)
                .font(.caption)
        } else if isNameValid {
            Text("✓ Looks good!")
                .foregroundColor(.green)
                .font(.caption)
        } else {
            Text("Name needs at least 2 letters or numbers")
                .foregroundColor(.orange)
                .font(.caption)
        }
    }

    @ViewBuilder
    private var setsFooterText: some View {
        if sets.isEmpty {
            Text("How many sets?")
                .foregroundColor(.secondary)
                .font(.caption)
        } else if isSetsValid {
            Text("✓ \(sets) sets")
                .foregroundColor(.green)
                .font(.caption)
        } else {
            Text("Enter a number between 1 and 20")
                .foregroundColor(.orange)
                .font(.caption)
        }
    }

    @ViewBuilder
    private var repsFooterText: some View {
        if reps.isEmpty {
            Text("Can be a range (8-12), exact (10), or AMRAP")
                .foregroundColor(.secondary)
                .font(.caption)
        } else if isRepsValid {
            Text("✓ Goal: \(reps)")
                .foregroundColor(.green)
                .font(.caption)
        } else {
            Text("Enter a rep goal (e.g. 8-12, 10, AMRAP)")
                .foregroundColor(.orange)
                .font(.caption)
        }
    }

    // MARK: - Actions

    private func createExercise() {
        viewModel.name = name.trimmingCharacters(in: .whitespaces)
        viewModel.sets = sets
        viewModel.reps = reps
        viewModel.muscleGroup = selectedMuscleGroup

        Task {
            await viewModel.createExercise(to: day)
        }
        dismiss()
    }
}
