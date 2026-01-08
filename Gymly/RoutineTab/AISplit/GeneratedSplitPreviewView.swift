//
//  GeneratedSplitPreviewView.swift
//  ShadowLift
//
//  Created by Claude Code on 05.01.2026.
//

import SwiftUI

@available(iOS 26, *)
struct GeneratedSplitPreviewView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.colorScheme) var scheme

    let generatedSplit: GeneratedSplit.PartiallyGenerated?
    let isGenerating: Bool
    let onSave: () -> Void
    let onModify: () -> Void

    @State private var expandedDays: Set<Int> = []
    @State private var loadingMessageIndex = 0
    @State private var loadingTimer: Timer?

    private let loadingMessages = [
        ("Analyzing your fitness goals...", "sparkles"),
        ("Designing optimal workout structure...", "figure.strengthtraining.traditional"),
        ("Selecting exercises for your equipment...", "dumbbell.fill"),
        ("Balancing muscle groups...", "arrow.triangle.2.circlepath"),
        ("Optimizing rest and recovery...", "bed.double.fill"),
        ("Calculating training volume...", "chart.bar.fill"),
        ("Fine-tuning rep ranges...", "slider.horizontal.3"),
        ("Finalizing your personalized split...", "checkmark.seal.fill")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                if isGenerating {
                    aiLoadingView
                } else if let split = generatedSplit {
                    splitContentView(split)
                } else {
                    emptyStateView
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 140) // Space for floating buttons
        }
        .overlay(alignment: .bottom) {
            if !isGenerating && generatedSplit?.name != nil {
                actionButtonsView
            }
        }
        .onAppear {
            if isGenerating {
                startLoadingAnimation()
            }
        }
        .onChange(of: isGenerating) { _, newValue in
            if newValue {
                startLoadingAnimation()
            } else {
                stopLoadingAnimation()
            }
        }
        .onDisappear {
            stopLoadingAnimation()
        }
    }

    // MARK: - AI Loading View

    private var aiLoadingView: some View {
        VStack(spacing: 32) {
            Spacer(minLength: 40)

            // Simplified AI Icon (no continuous animation)
            ZStack {
                // Static outer ring
                Circle()
                    .stroke(
                        LinearGradient(colors: [.purple.opacity(0.3), appearanceManager.accentColor.color.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 2
                    )
                    .frame(width: 100, height: 100)

                // Center icon background
                Circle()
                    .fill(
                        LinearGradient(colors: [.purple.opacity(0.2), appearanceManager.accentColor.color.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 80, height: 80)

                // Icon - changes with message
                Image(systemName: loadingMessages[loadingMessageIndex].1)
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, appearanceManager.accentColor.color], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .contentTransition(.symbolEffect(.replace))
            }

            // Loading text
            VStack(spacing: 12) {
                Text("Creating Your Split")
                    .font(.system(size: 24, weight: .bold))

                Text(loadingMessages[loadingMessageIndex].0)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .id("message-\(loadingMessageIndex)")
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: loadingMessageIndex)
            }

            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<loadingMessages.count, id: \.self) { index in
                    Circle()
                        .fill(index <= loadingMessageIndex ?
                              LinearGradient(colors: [.purple, appearanceManager.accentColor.color], startPoint: .leading, endPoint: .trailing) :
                              LinearGradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.2)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 6, height: 6)
                }
            }

            // Show partial content as it streams
            if let split = generatedSplit {
                VStack(spacing: 16) {
                    if let name = split.name {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(name)
                                .font(.system(size: 15, weight: .medium))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(20)
                        .transition(.scale.combined(with: .opacity))
                    }

                    if let days = split.days, !days.isEmpty {
                        HStack {
                            Image(systemName: "calendar.badge.checkmark")
                                .foregroundColor(.blue)
                            Text("\(days.count) days created")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.4), value: split.name)
                .animation(.spring(response: 0.4), value: split.days?.count)
            }

            Spacer(minLength: 40)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 60)

            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [.purple.opacity(0.5), appearanceManager.accentColor.color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Text("Ready to Generate")
                .font(.system(size: 22, weight: .bold))

            Text("Complete the questionnaire to create your personalized workout split")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Split Content View

    @ViewBuilder
    private func splitContentView(_ split: GeneratedSplit.PartiallyGenerated) -> some View {
        VStack(spacing: 20) {
            // Split header card
            if let name = split.name {
                VStack(spacing: 12) {
                    // Success icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [.green.opacity(0.2), .green.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 60, height: 60)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.green)
                    }

                    Text(name)
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)

                    if let description = split.description {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // Stats row
                    if let days = split.days {
                        HStack(spacing: 20) {
                            GeneratedStatBadge(icon: "calendar", value: "\(days.count)", label: "Days")
                            GeneratedStatBadge(icon: "dumbbell.fill", value: "\(totalExercises(in: days))", label: "Exercises")
                            if let volume = split.weeklyVolume {
                                GeneratedStatBadge(icon: "chart.bar.fill", value: volume, label: "Volume")
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }

            // Days list
            if let days = split.days {
                VStack(spacing: 12) {
                    ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                        if let dayNumber = day.dayNumber {
                            GeneratedDayPreviewCard(
                                day: day,
                                isExpanded: expandedDays.contains(dayNumber),
                                onToggle: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        if expandedDays.contains(dayNumber) {
                                            expandedDays.remove(dayNumber)
                                        } else {
                                            expandedDays.insert(dayNumber)
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
            }

            // Rationale section
            if let rationale = split.rationale {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("Why This Split?")
                            .font(.system(size: 16, weight: .semibold))
                    }

                    Text(rationale)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.yellow.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtonsView: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)

            HStack(spacing: 12) {
                // Modify button
                Button(action: onModify) {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Modify")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }

                // Save button
                Button(action: onSave) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Save Split")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [.purple, appearanceManager.accentColor.color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .background(Color.black.opacity(0.9))
        }
    }

    // MARK: - Helpers

    private func totalExercises(in days: [GeneratedDay.PartiallyGenerated]) -> Int {
        days.reduce(0) { total, day in
            total + (day.exercises?.count ?? 0)
        }
    }

    private func startLoadingAnimation() {
        loadingMessageIndex = 0
        // Slower interval (3s) to reduce UI updates
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            loadingMessageIndex = (loadingMessageIndex + 1) % loadingMessages.count
        }
    }

    private func stopLoadingAnimation() {
        loadingTimer?.invalidate()
        loadingTimer = nil
    }
}

// MARK: - Generated Stat Badge

@available(iOS 26, *)
private struct GeneratedStatBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
            }
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Day Preview Card

@available(iOS 26, *)
private struct GeneratedDayPreviewCard: View {
    @EnvironmentObject var appearanceManager: AppearanceManager

    let day: GeneratedDay.PartiallyGenerated
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header (always visible)
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    // Day number badge
                    if let dayNumber = day.dayNumber {
                        Text("\(dayNumber)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(
                                        day.isRestDay == true ?
                                        LinearGradient(colors: [.orange, .orange.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                                        LinearGradient(colors: [.purple, appearanceManager.accentColor.color], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                            )
                    }

                    // Day info
                    VStack(alignment: .leading, spacing: 2) {
                        if let name = day.name {
                            Text(name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        if day.isRestDay == true {
                            Text("Recovery Day")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                        } else if let focus = day.focus {
                            Text(focus)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Exercise count or rest badge
                    if day.isRestDay == true {
                        Image(systemName: "moon.zzz.fill")
                            .foregroundColor(.orange)
                    } else if let exercises = day.exercises {
                        HStack(spacing: 4) {
                            Text("\(exercises.count)")
                                .font(.system(size: 13, weight: .medium))
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: isExpanded ? 16 : 14)
                        .fill(Color.white.opacity(0.08))
                )
            }
            .buttonStyle(.plain)

            // Expanded content (exercises)
            if isExpanded, day.isRestDay != true, let exercises = day.exercises {
                VStack(spacing: 6) {
                    ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                        GeneratedExercisePreviewRow(exercise: exercise, index: index + 1)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.04))
                )
                .padding(.top, 2)
            }
        }
    }
}

// MARK: - Exercise Preview Row

@available(iOS 26, *)
private struct GeneratedExercisePreviewRow: View {
    @EnvironmentObject var appearanceManager: AppearanceManager

    let exercise: GeneratedExercise.PartiallyGenerated
    let index: Int

    var body: some View {
        HStack(spacing: 12) {
            // Exercise number
            Text("\(index)")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 20)

            // Exercise info
            VStack(alignment: .leading, spacing: 3) {
                if let name = exercise.name {
                    Text(name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }

                HStack(spacing: 8) {
                    if let muscleGroup = exercise.muscleGroup {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(appearanceManager.accentColor.color)
                                .frame(width: 6, height: 6)
                            Text(muscleGroup)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let sets = exercise.sets, let reps = exercise.repRange {
                        Text("\(sets) × \(reps)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(appearanceManager.accentColor.color.opacity(0.8))
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.04))
        )
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
