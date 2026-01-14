//
//  SplitChatModificationView.swift
//  ProdiusGym
//
//  Created by Claude Code on 05.01.2026.
//

import SwiftUI

@available(iOS 26, *)
struct SplitChatModificationView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme

    @ObservedObject var generator: SplitGeneratorService
    let onApply: () -> Void
    let onCancel: () -> Void

    @State private var chatInput: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var isModifying = false

    // Categorized suggestions
    private let suggestionCategories: [(String, String, [String])] = [
        ("Volume", "chart.bar.fill", [
            "Add more exercises",
            "Reduce total volume",
            "Increase sets per exercise"
        ]),
        ("Focus", "target", [
            "More chest emphasis",
            "Focus more on back",
            "Include more leg work",
            "Add arm isolation"
        ]),
        ("Structure", "rectangle.3.group", [
            "Add a rest day",
            "Make workouts shorter",
            "Combine muscle groups"
        ]),
        ("Difficulty", "speedometer", [
            "Make it beginner-friendly",
            "Make it more challenging",
            "Add advanced techniques"
        ])
    ]

    var body: some View {
        ZStack {
            // Background
            FloatingClouds(theme: CloudsTheme.appleIntelligence(scheme))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                // Main content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Current split preview
                        if let split = generator.generatedSplit {
                            currentSplitCard(split)
                        }

                        // Suggestion categories
                        suggestionsSection

                        // Custom request hint
                        customRequestHint
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }

                // Input area
                inputAreaView
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Modify Split")
                    .font(.system(size: 17, weight: .semibold))
                Text("Tell AI what to change")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Invisible placeholder for symmetry
            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Current Split Card

    @ViewBuilder
    private func currentSplitCard(_ split: GeneratedSplit.PartiallyGenerated) -> some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [.purple.opacity(0.3), PremiumColors.gold.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 40, height: 40)

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(
                            LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Current Split")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    if let name = split.name {
                        Text(name)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }

                Spacer()

                if let days = split.days {
                    Text("\(days.count) days")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(PremiumColors.gold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(PremiumColors.gold.opacity(0.15))
                        .cornerRadius(12)
                }
            }

            // Days preview
            if let days = split.days {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                            ModifyDayChip(day: day, dayNumber: index + 1)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Suggestions Section

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Quick Modifications")
                    .font(.system(size: 16, weight: .semibold))
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(suggestionCategories, id: \.0) { category in
                    SuggestionCategoryCard(
                        title: category.0,
                        icon: category.1,
                        suggestions: category.2,
                        selectedSuggestion: chatInput,
                        onSelect: { suggestion in
                            withAnimation(.spring(response: 0.3)) {
                                chatInput = suggestion
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Custom Request Hint

    private var customRequestHint: some View {
        HStack(spacing: 12) {
            Image(systemName: "text.cursor")
                .font(.system(size: 20))
                .foregroundStyle(
                    LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Custom Request")
                    .font(.system(size: 14, weight: .medium))
                Text("Type your own modification below")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(colors: [.purple.opacity(0.3), PremiumColors.gold.opacity(0.3)], startPoint: .leading, endPoint: .trailing),
                            lineWidth: 1
                        )
                )
        )
    }

    // MARK: - Input Area

    private var inputAreaView: some View {
        VStack(spacing: 0) {
            // Gradient fade
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 30)

            VStack(spacing: 12) {
                // Text input with send button
                HStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundStyle(
                                LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .leading, endPoint: .trailing)
                            )

                        TextField("Describe your changes...", text: $chatInput, axis: .vertical)
                            .textFieldStyle(.plain)
                            .focused($isInputFocused)
                            .lineLimit(1...4)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        isInputFocused ?
                                        LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .leading, endPoint: .trailing) :
                                        LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing),
                                        lineWidth: 1
                                    )
                            )
                    )

                    // Send button
                    Button(action: applyModification) {
                        ZStack {
                            Circle()
                                .fill(
                                    chatInput.isEmpty || generator.isGenerating ?
                                    LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom) :
                                    LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 48, height: 48)

                            if generator.isGenerating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(chatInput.isEmpty || generator.isGenerating)
                }

                // Loading status
                if generator.isGenerating {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 8, height: 8)
                            .scaleEffect(generator.isGenerating ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: generator.isGenerating)

                        Text("AI is modifying your split...")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 30)
            .background(Color.black.opacity(0.8))
        }
    }

    // MARK: - Actions

    private func applyModification() {
        guard !chatInput.isEmpty else { return }

        Task {
            do {
                try await generator.modifySplit(userRequest: chatInput)
                chatInput = ""
                onApply()
            } catch {
                debugLog("Error modifying split: \(error)")
            }
        }
    }
}

// MARK: - Modify Day Chip

@available(iOS 26, *)
private struct ModifyDayChip: View {
    @EnvironmentObject var appearanceManager: AppearanceManager

    let day: GeneratedDay.PartiallyGenerated
    let dayNumber: Int

    var body: some View {
        HStack(spacing: 8) {
            Text("\(dayNumber)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(
                            day.isRestDay == true ?
                            LinearGradient(colors: [.orange, .orange.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                )

            if let name = day.name {
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }

            if day.isRestDay == true {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
            } else if let exercises = day.exercises {
                Text("\(exercises.count)")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.08))
        )
    }
}

// MARK: - Suggestion Category Card

@available(iOS 26, *)
private struct SuggestionCategoryCard: View {
    @EnvironmentObject var appearanceManager: AppearanceManager

    let title: String
    let icon: String
    let suggestions: [String]
    let selectedSuggestion: String
    let onSelect: (String) -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(
                            LinearGradient(colors: [.purple, PremiumColors.gold], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )

                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            // Suggestions (when expanded)
            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: { onSelect(suggestion) }) {
                            HStack(spacing: 8) {
                                Image(systemName: selectedSuggestion == suggestion ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(selectedSuggestion == suggestion ? PremiumColors.gold : .secondary)

                                Text(suggestion)
                                    .font(.system(size: 12))
                                    .foregroundColor(selectedSuggestion == suggestion ? .white : .secondary)

                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedSuggestion == suggestion ? PremiumColors.gold.opacity(0.15) : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Flow Layout for Chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)

        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(
                    x: bounds.minX + result.positions[index].x,
                    y: bounds.minY + result.positions[index].y
                ),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            let maxWidth: CGFloat = maxWidth

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                sizes.append(size)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))

                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)

                self.size.width = max(self.size.width, currentX - spacing)
            }

            self.size.height = currentY + lineHeight
        }
    }
}
