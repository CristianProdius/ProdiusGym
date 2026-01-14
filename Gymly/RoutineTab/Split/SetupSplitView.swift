//
//  SetupSplitView.swift
//  ProdiusGym
//
//  Created by Sebastián Kučera on 17.10.2024.
//

import SwiftUI

struct SetupSplitView: View {

    // MARK: - State
    @State private var name: String = ""
    @State private var splitLength: String = ""
    @State private var showValidationError = false
    @State private var validationErrorMessage = ""

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject var config: Config
    @EnvironmentObject var appearanceManager: AppearanceManager
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.colorScheme) var scheme

    // MARK: - Validation

    /// Name is valid if it contains at least 2 alphanumeric characters
    private var isNameValid: Bool {
        let alphanumericCount = name.filter { $0.isLetter || $0.isNumber }.count
        return alphanumericCount >= 2
    }

    /// Days is valid if it's a number between 1 and 14
    private var isDaysValid: Bool {
        guard let days = Int(splitLength) else { return false }
        return days > 0 && days <= 14
    }

    private var isFormValid: Bool {
        isNameValid && isDaysValid
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                // Name Section
                Section {
                    TextField("e.g. Push Pull Legs", text: $name)
                } header: {
                    Text("Split Name")
                } footer: {
                    nameFooterText
                }
                .listRowBackground(Color.black.opacity(0.1))

                // Days Section
                Section {
                    TextField("e.g. 6", text: $splitLength)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Number of Days")
                } footer: {
                    daysFooterText
                }
                .listRowBackground(Color.black.opacity(0.1))

                // Quick select buttons
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(["3", "4", "5", "6", "7"], id: \.self) { value in
                                Button {
                                    splitLength = value
                                } label: {
                                    Text("\(value) Day")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(splitLength == value ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(splitLength == value ? PremiumColors.gold : Color.black.opacity(0.2))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Popular Splits")
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Create Split")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        createSplit()
                    } label: {
                        Text("Create")
                            .fontWeight(.semibold)
                            .foregroundStyle(isFormValid ? PremiumColors.gold : .secondary)
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Invalid Input", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationErrorMessage)
            }
        }
    }

    // MARK: - Footer Views

    @ViewBuilder
    private var nameFooterText: some View {
        if name.isEmpty {
            Text("Give your split a memorable name")
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
    private var daysFooterText: some View {
        if splitLength.isEmpty {
            Text("Most common: 3-7 days")
                .foregroundColor(.secondary)
                .font(.caption)
        } else if isDaysValid {
            let days = Int(splitLength) ?? 0
            Text("✓ \(days) day\(days == 1 ? "" : "s") split")
                .foregroundColor(.green)
                .font(.caption)
        } else {
            Text("Enter a number between 1 and 14")
                .foregroundColor(.orange)
                .font(.caption)
        }
    }

    // MARK: - Actions

    private func createSplit() {
        guard isNameValid else {
            validationErrorMessage = "Please enter a valid name (at least 2 letters or numbers)."
            showValidationError = true
            return
        }

        guard let days = Int(splitLength), days > 0, days <= 14 else {
            validationErrorMessage = "Please enter a valid number of days (1-14)."
            showValidationError = true
            return
        }

        viewModel.createNewSplit(
            name: name.trimmingCharacters(in: .whitespaces),
            numberOfDays: days,
            startDate: Date(),
            context: context
        )

        config.dayInSplit = 1
        dismiss()
    }
}
