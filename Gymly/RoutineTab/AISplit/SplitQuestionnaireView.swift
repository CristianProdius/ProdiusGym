//
//  SplitQuestionnaireView.swift
//  ProdiusGym
//
//  Created by Claude Code on 05.01.2026.
//

import SwiftUI

@available(iOS 26, *)
struct SplitQuestionnaireView: View {
    @EnvironmentObject var config: Config
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.colorScheme) var scheme

    @Binding var preferences: SplitPreferences
    @Binding var currentStep: Int
    let onComplete: () -> Void

    // Step states
    @State private var selectedSplitType: SplitTypePreference?
    @State private var selectedDuration: SessionDurationPreference?
    @State private var selectedMuscles: Set<String> = []
    @State private var selectedIntensity: IntensityPreference?
    @State private var selectedVariety: VarietyPreference?
    @State private var selectedCompoundIsolation: CompoundIsolationPreference?
    @State private var selectedRestDay: RestDayPreference?
    @State private var limitations: String = ""

    private let totalSteps = SplitGeneratorQuestion.totalSteps

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Compact Header
                VStack(spacing: 6) {
                    // Progress indicator
                    HStack(spacing: 4) {
                        ForEach(1...totalSteps, id: \.self) { step in
                            Capsule()
                                .fill(step <= currentStep ?
                                      LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .leading, endPoint: .trailing) :
                                      LinearGradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.2)], startPoint: .leading, endPoint: .trailing))
                                .frame(height: 3)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    Text("Step \(currentStep) of \(totalSteps)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Step Content - Takes most of the screen
                Group {
                    switch currentStep {
                    case 1:
                        AIQuestionView(
                            title: SplitGeneratorQuestion.splitType.title,
                            subtitle: SplitGeneratorQuestion.splitType.subtitle,
                            content: {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(SplitTypePreference.allCases) { option in
                                        AISelectionTile(
                                            icon: option.icon,
                                            title: option.displayName,
                                            isSelected: selectedSplitType == option
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedSplitType = option
                                            }
                                        }
                                    }
                                }
                            }
                        )
                    case 2:
                        AIQuestionView(
                            title: SplitGeneratorQuestion.sessionDuration.title,
                            subtitle: SplitGeneratorQuestion.sessionDuration.subtitle,
                            content: {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(SessionDurationPreference.allCases) { option in
                                        AISelectionTile(
                                            icon: option.icon,
                                            title: option.displayName,
                                            isSelected: selectedDuration == option
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedDuration = option
                                            }
                                        }
                                    }
                                }
                            }
                        )
                    case 3:
                        AIQuestionView(
                            title: SplitGeneratorQuestion.musclePriority.title,
                            subtitle: SplitGeneratorQuestion.musclePriority.subtitle,
                            content: {
                                VStack(spacing: 12) {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                        ForEach(MuscleGroupOption.allOptions) { option in
                                            AIMuscleChip(
                                                name: option.name,
                                                icon: option.icon,
                                                isSelected: selectedMuscles.contains(option.id)
                                            ) {
                                                withAnimation(.spring(response: 0.3)) {
                                                    if selectedMuscles.contains(option.id) {
                                                        selectedMuscles.remove(option.id)
                                                    } else {
                                                        selectedMuscles.insert(option.id)
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    if selectedMuscles.isEmpty {
                                        Text("Skip to train all muscles equally")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text("Prioritizing: \(selectedMuscles.sorted().joined(separator: ", "))")
                                            .font(.caption)
                                            .foregroundStyle(PremiumColors.gold)
                                    }
                                }
                            }
                        )
                    case 4:
                        AIQuestionView(
                            title: SplitGeneratorQuestion.trainingIntensity.title,
                            subtitle: SplitGeneratorQuestion.trainingIntensity.subtitle,
                            content: {
                                VStack(spacing: 12) {
                                    ForEach(IntensityPreference.allCases) { option in
                                        AIOptionRow(
                                            icon: option.icon,
                                            title: option.displayName,
                                            description: option.description,
                                            isSelected: selectedIntensity == option
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedIntensity = option
                                            }
                                        }
                                    }
                                }
                            }
                        )
                    case 5:
                        AIQuestionView(
                            title: SplitGeneratorQuestion.exerciseVariety.title,
                            subtitle: SplitGeneratorQuestion.exerciseVariety.subtitle,
                            content: {
                                VStack(spacing: 12) {
                                    ForEach(VarietyPreference.allCases) { option in
                                        AIOptionRow(
                                            icon: option.icon,
                                            title: option.displayName,
                                            description: option.description,
                                            isSelected: selectedVariety == option
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedVariety = option
                                            }
                                        }
                                    }
                                }
                            }
                        )
                    case 6:
                        AIQuestionView(
                            title: SplitGeneratorQuestion.compoundIsolation.title,
                            subtitle: SplitGeneratorQuestion.compoundIsolation.subtitle,
                            content: {
                                VStack(spacing: 12) {
                                    ForEach(CompoundIsolationPreference.allCases) { option in
                                        AIOptionRow(
                                            icon: option.icon,
                                            title: option.displayName,
                                            description: option.description,
                                            isSelected: selectedCompoundIsolation == option
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedCompoundIsolation = option
                                            }
                                        }
                                    }
                                }
                            }
                        )
                    case 7:
                        AIQuestionView(
                            title: SplitGeneratorQuestion.restDayPlacement.title,
                            subtitle: SplitGeneratorQuestion.restDayPlacement.subtitle,
                            content: {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(RestDayPreference.allCases) { option in
                                        AISelectionTile(
                                            icon: option.icon,
                                            title: option.displayName,
                                            isSelected: selectedRestDay == option
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedRestDay = option
                                            }
                                        }
                                    }
                                }
                            }
                        )
                    case 8:
                        AIQuestionView(
                            title: SplitGeneratorQuestion.limitations.title,
                            subtitle: SplitGeneratorQuestion.limitations.subtitle,
                            content: {
                                AILimitationsInput(limitations: $limitations)
                            }
                        )
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)

                Spacer(minLength: 20)

                // Bottom Navigation
                HStack(spacing: 12) {
                    // Back Button
                    if currentStep > 1 {
                        Button(action: {
                            withAnimation(.spring(response: 0.4)) {
                                currentStep -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                )
                        }
                    }

                    // Next/Generate Button
                    Button(action: {
                        saveCurrentStep()
                        if currentStep < totalSteps {
                            withAnimation(.spring(response: 0.4)) {
                                currentStep += 1
                            }
                        } else {
                            finalizePreferences()
                            onComplete()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentStep < totalSteps ? "Continue" : "Generate Split")
                                .font(.system(size: 17, weight: .semibold))

                            Image(systemName: currentStep < totalSteps ? "arrow.right" : "sparkles")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            Group {
                                if isNextButtonEnabled {
                                    LinearGradient(
                                        colors: [.purple, PremiumColors.gold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                } else {
                                    Color.gray.opacity(0.3)
                                }
                            }
                        )
                        .cornerRadius(25)
                    }
                    .disabled(!isNextButtonEnabled)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            initializeFromPreferences()
        }
    }

    private var isNextButtonEnabled: Bool {
        switch currentStep {
        case 1: return selectedSplitType != nil
        case 2: return selectedDuration != nil
        case 3: return true // Muscle priority is optional
        case 4: return selectedIntensity != nil
        case 5: return selectedVariety != nil
        case 6: return selectedCompoundIsolation != nil
        case 7: return selectedRestDay != nil
        case 8: return true // Limitations is optional
        default: return false
        }
    }

    private func initializeFromPreferences() {
        selectedSplitType = preferences.splitType
        selectedDuration = preferences.sessionDuration
        selectedMuscles = Set(preferences.musclePriority)
        selectedIntensity = preferences.trainingIntensity
        selectedVariety = preferences.exerciseVariety
        selectedCompoundIsolation = preferences.compoundIsolation
        selectedRestDay = preferences.restDayPlacement
        limitations = preferences.limitations ?? ""
    }

    private func saveCurrentStep() {
        switch currentStep {
        case 1:
            if let split = selectedSplitType {
                preferences.splitType = split
            }
        case 2:
            if let duration = selectedDuration {
                preferences.sessionDuration = duration
            }
        case 3:
            preferences.musclePriority = Array(selectedMuscles)
        case 4:
            if let intensity = selectedIntensity {
                preferences.trainingIntensity = intensity
            }
        case 5:
            if let variety = selectedVariety {
                preferences.exerciseVariety = variety
            }
        case 6:
            if let compound = selectedCompoundIsolation {
                preferences.compoundIsolation = compound
            }
        case 7:
            if let rest = selectedRestDay {
                preferences.restDayPlacement = rest
            }
        case 8:
            preferences.limitations = limitations.isEmpty ? nil : limitations
        default:
            break
        }
    }

    private func finalizePreferences() {
        saveCurrentStep()
    }
}

// MARK: - AI Question Container View

@available(iOS 26, *)
private struct AIQuestionView<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 16) {
            // Question header
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Content
            ScrollView(showsIndicators: false) {
                content()
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - AI Selection Tile (Grid item)

@available(iOS 26, *)
private struct AISelectionTile: View {
    @EnvironmentObject var appearanceManager: AppearanceManager

    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ?
                              LinearGradient(colors: [.purple.opacity(0.3), PremiumColors.gold.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? PremiumColors.gold : .white)
                }

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected ? 0.15 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ?
                                LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color.clear, Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

// MARK: - AI Option Row (Full width)

@available(iOS 26, *)
private struct AIOptionRow: View {
    @EnvironmentObject var appearanceManager: AppearanceManager

    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected ?
                              LinearGradient(colors: [.purple.opacity(0.3), PremiumColors.gold.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? PremiumColors.gold : .white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(isSelected ? 0.12 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected ?
                                LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color.clear, Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AI Muscle Chip

@available(iOS 26, *)
private struct AIMuscleChip: View {
    @EnvironmentObject var appearanceManager: AppearanceManager

    let name: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(name)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(isSelected ? PremiumColors.gold : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ?
                          PremiumColors.gold.opacity(0.2) :
                          Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? PremiumColors.gold : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

// MARK: - AI Limitations Input

@available(iOS 26, *)
private struct AILimitationsInput: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Binding var limitations: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Suggestion chips
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick add:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                FlowLayout(spacing: 8) {
                    ForEach(["Bad knees", "Lower back pain", "Shoulder injury", "No overhead pressing", "Wrist issues"], id: \.self) { suggestion in
                        Button(action: {
                            if limitations.isEmpty {
                                limitations = suggestion
                            } else if !limitations.contains(suggestion) {
                                limitations += ", \(suggestion)"
                            }
                        }) {
                            Text(suggestion)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Text input
            VStack(alignment: .leading, spacing: 6) {
                TextEditor(text: $limitations)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100, maxHeight: 150)
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFocused ? PremiumColors.gold : Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .focused($isFocused)

                Text("Leave empty if none")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
