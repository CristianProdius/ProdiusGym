//
//  TutorialView.swift
//  ShadowLift
//
//  Created by Claude Code on 09.01.2026.
//

import SwiftUI

// MARK: - Tutorial Step Definition

enum TutorialHighlight: Int, CaseIterable {
    case welcome
    case profile
    case splits
    case addExercise
    case daySelector
    case calendar
    case settings
    case done

    var title: String {
        switch self {
        case .welcome: return "Welcome to ShadowLift!"
        case .profile: return "Your Profile"
        case .splits: return "Your Workout Splits"
        case .addExercise: return "Add Exercises"
        case .daySelector: return "Switch Workout Days"
        case .calendar: return "Track Your History"
        case .settings: return "Customize Your Experience"
        case .done: return "You're All Set!"
        }
    }

    var description: String {
        switch self {
        case .welcome:
            return "Let's take a quick tour of the features that will help you crush your fitness goals."
        case .profile:
            return "Tap your profile picture to view your stats, streaks, and personal records."
        case .splits:
            return "Tap here to create, edit, and manage your workout splits. Choose from templates like Push/Pull/Legs or create your own!"
        case .addExercise:
            return "Quickly add new exercises to your current workout day with just a tap."
        case .daySelector:
            return "Tap the day name to switch between different workout days in your split."
        case .calendar:
            return "View your workout history, track consistency, and see your progress over time."
        case .settings:
            return "Connect HealthKit, customize themes, enable iCloud sync, and manage your account."
        case .done:
            return "You're ready to start training! Remember, consistency is key to reaching your goals."
        }
    }

    var icon: String {
        switch self {
        case .welcome: return "figure.strengthtraining.traditional"
        case .profile: return "person.crop.circle"
        case .splits: return "list.bullet.rectangle"
        case .addExercise: return "plus.circle"
        case .daySelector: return "chevron.down"
        case .calendar: return "calendar"
        case .settings: return "gearshape"
        case .done: return "checkmark.circle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .welcome: return .orange
        case .profile: return .pink
        case .splits: return .purple
        case .addExercise: return .blue
        case .daySelector: return .green
        case .calendar: return .cyan
        case .settings: return .gray
        case .done: return .green
        }
    }

    // Whether to show spotlight circle for this step
    var showSpotlight: Bool {
        switch self {
        case .welcome, .daySelector, .done: return false
        default: return true
        }
    }

    // Tooltip position relative to spotlight
    var tooltipAlignment: TooltipAlignment {
        switch self {
        case .welcome: return .center
        case .profile: return .below
        case .splits: return .below
        case .addExercise: return .below
        case .daySelector: return .below
        case .calendar: return .above
        case .settings: return .above
        case .done: return .center
        }
    }
}

enum TooltipAlignment {
    case above
    case below
    case center
}

// MARK: - Tutorial Overlay View

struct TutorialView: View {
    @EnvironmentObject var config: Config
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var currentStep: TutorialHighlight = .welcome
    @State private var showContent = false
    @State private var spotlightOpacity: Double = 0

    private let steps = TutorialHighlight.allCases

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // App-like skeleton background (handles its own safe area)
                SkeletonAppBackground(geometry: geometry, colorScheme: colorScheme)

                // Dark overlay - lighter to show skeleton better
                Color.black.opacity(0.55)
                    .ignoresSafeArea()

                // Spotlight cutout (only for steps that show spotlight)
                if currentStep.showSpotlight {
                    SpotlightCutout(
                        position: spotlightPosition(for: currentStep, in: geometry),
                        size: CGSize(width: 50, height: 50)
                    )
                    .opacity(spotlightOpacity)
                }

                // Mock UI Elements for context
                MockUIOverlay(currentStep: currentStep, geometry: geometry)
                    .opacity(currentStep.showSpotlight || currentStep == .daySelector ? spotlightOpacity : 0)

                // Tooltip content
                VStack(spacing: 0) {
                    if currentStep.tooltipAlignment == .below || currentStep == .welcome || currentStep == .done {
                        Spacer()
                    }

                    TooltipCard(
                        step: currentStep,
                        accentColor: appearanceManager.accentColor.color,
                        isFirstStep: currentStep == .welcome,
                        isLastStep: currentStep == .done,
                        onNext: nextStep,
                        onBack: previousStep,
                        onSkip: completeTutorial
                    )
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                    if currentStep.tooltipAlignment == .above {
                        Spacer()
                    }

                    if currentStep == .welcome || currentStep == .done {
                        Spacer()
                    }
                }
                .padding(.vertical, currentStep.tooltipAlignment == .center ? 0 : 100)

                // Progress indicators - positioned at top for tab bar steps, bottom otherwise
                VStack {
                    if currentStep == .calendar || currentStep == .settings {
                        ProgressIndicator(
                            currentIndex: currentStep.rawValue,
                            totalSteps: steps.count,
                            accentColor: appearanceManager.accentColor.color
                        )
                        .padding(.top, geometry.safeAreaInsets.top + 60)
                        .opacity(showContent ? 1 : 0)
                        Spacer()
                    } else {
                        Spacer()
                        ProgressIndicator(
                            currentIndex: currentStep.rawValue,
                            totalSteps: steps.count,
                            accentColor: appearanceManager.accentColor.color
                        )
                        .padding(.bottom, 50)
                        .opacity(showContent ? 1 : 0)
                    }
                }
            }
        }
        .onAppear {
            animateIn()
        }
    }

    // MARK: - Positioning Helpers

    private func spotlightPosition(for step: TutorialHighlight, in geometry: GeometryProxy) -> CGPoint {
        let width = geometry.size.width
        let height = geometry.size.height

        // Tab bar calculations (matching MockUIOverlay padding)
        let tabPadding: CGFloat = 24
        let tabWidth = max((width - tabPadding * 2) / 3, 1)

        // Note: Top elements use y=26 (not safeArea.top + 26) because skeleton uses .ignoresSafeArea()
        // and positions content at safeArea.top + 4 + 22 (half icon) from screen top,
        // but our coordinate space already starts below safe area
        switch step {
        case .welcome, .done:
            return CGPoint(x: width / 2, y: height / 2)
        case .profile:
            // Top left - profile button
            return CGPoint(x: 34, y: 26)
        case .splits:
            // Toolbar: second from right
            return CGPoint(x: width - 90, y: 26)
        case .addExercise:
            // Toolbar: far right
            return CGPoint(x: width - 30, y: 26)
        case .daySelector:
            // Below nav bar (no spotlight, just mock UI)
            return CGPoint(x: 100, y: 80)
        case .calendar:
            // Center tab in tab bar - positioned at very bottom
            return CGPoint(x: width / 2, y: height - 5)
        case .settings:
            // Right tab: padding + 2.5 tab widths
            return CGPoint(x: tabPadding + tabWidth * 2.5, y: height - 5)
        }
    }

    // MARK: - Actions

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
            showContent = true
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            spotlightOpacity = 1
        }
    }

    private func nextStep() {
        let currentIndex = currentStep.rawValue
        if currentIndex < steps.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showContent = false
                spotlightOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentStep = steps[currentIndex + 1]
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showContent = true
                    spotlightOpacity = 1
                }
            }
        } else {
            completeTutorial()
        }
    }

    private func previousStep() {
        let currentIndex = currentStep.rawValue
        if currentIndex > 0 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showContent = false
                spotlightOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentStep = steps[currentIndex - 1]
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showContent = true
                    spotlightOpacity = 1
                }
            }
        }
    }

    private func completeTutorial() {
        withAnimation(.easeOut(duration: 0.3)) {
            showContent = false
            spotlightOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            config.hasSeenTutorial = true
            dismiss()
        }
    }
}

// MARK: - Skeleton App Background

struct SkeletonAppBackground: View {
    let geometry: GeometryProxy
    let colorScheme: ColorScheme

    private var bgColor: Color {
        colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.95)
    }

    private var cardColor: Color {
        colorScheme == .dark ? Color(white: 0.18) : Color(white: 0.88)
    }

    private var shimmerColor: Color {
        colorScheme == .dark ? Color(white: 0.25) : Color(white: 0.82)
    }

    var body: some View {
        let width = geometry.size.width
        let tabPadding: CGFloat = 24
        let tabWidth = max((width - tabPadding * 2) / 3, 1)

        ZStack {
            // Base background - extends to edges
            bgColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation bar area - y=26 is center of icons (matching MockUIOverlay)
                // 4pt from top of safe area + 22pt (half of 44pt icon) = 26
                HStack(spacing: 0) {
                    // Profile placeholder - center at x=34
                    Circle()
                        .fill(cardColor)
                        .frame(width: 44, height: 44)
                        .padding(.leading, 12)

                    Spacer()

                    // Title placeholder
                    RoundedRectangle(cornerRadius: 4)
                        .fill(cardColor)
                        .frame(width: 100, height: 20)

                    Spacer()

                    // Toolbar buttons - splits at width-90, addExercise at width-30
                    HStack(spacing: 16) {
                        // Splits button - center at width - 90
                        Circle()
                            .fill(cardColor)
                            .frame(width: 44, height: 44)
                        // Add exercise button - center at width - 30
                        Circle()
                            .fill(cardColor)
                            .frame(width: 44, height: 44)
                    }
                    .padding(.trailing, 8)
                }
                .padding(.top, 4)
                .padding(.bottom, 12)

                // Day title placeholder
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(cardColor)
                        .frame(width: 140, height: 32)
                        .padding(.leading, 16)
                    Spacer()
                }
                .padding(.vertical, 16)

                // Exercise list skeleton
                VStack(spacing: 12) {
                    // Section header
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shimmerColor)
                            .frame(width: 60, height: 14)
                            .padding(.leading, 16)
                        Spacer()
                    }

                    // Exercise rows
                    ForEach(0..<4, id: \.self) { _ in
                        SkeletonExerciseRow(cardColor: cardColor, shimmerColor: shimmerColor)
                    }

                    // Another section
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shimmerColor)
                            .frame(width: 80, height: 14)
                            .padding(.leading, 16)
                        Spacer()
                    }
                    .padding(.top, 8)

                    ForEach(0..<2, id: \.self) { _ in
                        SkeletonExerciseRow(cardColor: cardColor, shimmerColor: shimmerColor)
                    }
                }

                Spacer()

                // Tab bar skeleton - aligned with spotlight positions
                // Calendar at center (width/2), Settings at tabPadding + tabWidth * 2.5
                // Tab bar center should be at height - 38 from screen top
                HStack(spacing: 0) {
                    // Routine tab
                    VStack(spacing: 4) {
                        Circle()
                            .fill(cardColor)
                            .frame(width: 24, height: 24)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(cardColor)
                            .frame(width: 44, height: 10)
                    }
                    .frame(width: tabWidth)

                    // Calendar tab - center at width/2
                    VStack(spacing: 4) {
                        Circle()
                            .fill(cardColor)
                            .frame(width: 24, height: 24)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(cardColor)
                            .frame(width: 44, height: 10)
                    }
                    .frame(width: tabWidth)

                    // Settings tab - center at tabPadding + tabWidth * 2.5
                    VStack(spacing: 4) {
                        Circle()
                            .fill(cardColor)
                            .frame(width: 24, height: 24)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(cardColor)
                            .frame(width: 44, height: 10)
                    }
                    .frame(width: tabWidth)
                }
                .padding(.horizontal, tabPadding)
                // Icon center should be at height - 38
                // Tab item is 38pt tall, icon center is 26pt from bottom (10 label + 4 spacing + 12 half-circle)
                // So bottom padding = 38 - 26 = 12
                .padding(.bottom, 12)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct SkeletonExerciseRow: View {
    let cardColor: Color
    let shimmerColor: Color

    var body: some View {
        HStack(spacing: 12) {
            // Number
            Circle()
                .fill(shimmerColor)
                .frame(width: 24, height: 24)

            // Exercise name
            RoundedRectangle(cornerRadius: 4)
                .fill(shimmerColor)
                .frame(width: CGFloat.random(in: 100...180), height: 16)

            Spacer()

            // Chevron
            RoundedRectangle(cornerRadius: 2)
                .fill(cardColor)
                .frame(width: 8, height: 14)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(cardColor)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Spotlight Cutout

struct SpotlightCutout: View {
    let position: CGPoint
    let size: CGSize

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Create a path that covers everything except the spotlight area
                Rectangle()
                    .fill(Color.black.opacity(0.001)) // Nearly invisible but captures taps

                // Spotlight circle with glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width
                        )
                    )
                    .frame(width: size.width * 2, height: size.height * 2)
                    .position(position)

                // Pulsing ring
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    .frame(width: size.width + 20, height: size.height + 20)
                    .position(position)
                    .modifier(PulseAnimation())
            }
        }
    }
}

// MARK: - Pulse Animation

struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 0.3 : 1.0)
            .animation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Mock UI Overlay (shows context)

struct MockUIOverlay: View {
    let currentStep: TutorialHighlight
    let geometry: GeometryProxy

    private var safeArea: EdgeInsets { geometry.safeAreaInsets }
    private var width: CGFloat { geometry.size.width }
    private var height: CGFloat { geometry.size.height }
    private var tabPadding: CGFloat { 24 }
    private var tabWidth: CGFloat { max((width - tabPadding * 2) / 3, 1) }

    var body: some View {
        ZStack {
            // Profile icon - y=26 (coordinate space starts below safe area)
            if currentStep == .profile {
                ZStack {
                    Circle()
                        .fill(Color.pink.opacity(0.3))
                        .frame(width: 44, height: 44)

                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
                .position(x: 34, y: 26)
            }

            // Splits icon
            if currentStep == .splits {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 44, height: 44)

                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .position(x: width - 90, y: 26)
            }

            // Add exercise icon
            if currentStep == .addExercise {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 44, height: 44)

                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .position(x: width - 30, y: 26)
            }

            // Day selector - positioned below nav bar
            if currentStep == .daySelector {
                HStack(spacing: 8) {
                    Text("Push Day")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)

                    Image(systemName: "chevron.down")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.2))
                        .stroke(Color.green.opacity(0.5), lineWidth: 2)
                )
                .position(x: 110, y: 90)
            }

            // Calendar tab - positioned at very bottom
            if currentStep == .calendar {
                TabBarMockItem(
                    icon: "calendar",
                    label: "Calendar",
                    isHighlighted: true
                )
                .position(x: width / 2, y: height - 5)
            }

            // Settings tab
            if currentStep == .settings {
                TabBarMockItem(
                    icon: "gearshape",
                    label: "Settings",
                    isHighlighted: true
                )
                .position(x: tabPadding + tabWidth * 2.5, y: height - 5)
            }
        }
    }
}

struct TabBarMockItem: View {
    let icon: String
    let label: String
    let isHighlighted: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isHighlighted ? .cyan : .white.opacity(0.4))

            Text(label)
                .font(.caption2)
                .foregroundColor(isHighlighted ? .cyan : .white.opacity(0.4))
        }
    }
}

// MARK: - Tooltip Card

struct TooltipCard: View {
    let step: TutorialHighlight
    let accentColor: Color
    let isFirstStep: Bool
    let isLastStep: Bool
    let onNext: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 24) {
            // Icon with glow
            ZStack {
                // Outer glow
                Circle()
                    .fill(step.iconColor.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)

                // Icon background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                step.iconColor.opacity(0.25),
                                step.iconColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)

                // Icon border
                Circle()
                    .stroke(step.iconColor.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 72, height: 72)

                Image(systemName: step.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(step.iconColor)
            }

            // Text content
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(step.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Buttons
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    if !isFirstStep && !isLastStep {
                        Button(action: onBack) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Back")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                        }
                    }

                    Button(action: isLastStep ? onSkip : onNext) {
                        HStack(spacing: 6) {
                            Text(isLastStep ? "Get Started" : "Next")
                                .fontWeight(.semibold)
                            if !isLastStep {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .frame(maxWidth: isFirstStep || isLastStep ? .infinity : nil)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [accentColor, accentColor.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }

                // Skip button (not on first or last step)
                if !isLastStep && !isFirstStep {
                    Button(action: onSkip) {
                        Text("Skip Tutorial")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
        }
        .padding(28)
        .background(
            ZStack {
                // Gradient background
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.18),
                                Color(white: 0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Subtle border
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 15)
        )
    }
}

// MARK: - Progress Indicator

struct ProgressIndicator: View {
    let currentIndex: Int
    let totalSteps: Int
    let accentColor: Color

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? accentColor : Color.white.opacity(0.3))
                    .frame(width: index == currentIndex ? 10 : 8, height: index == currentIndex ? 10 : 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
            }
        }
    }
}

// MARK: - Preview

#Preview("Tutorial") {
    TutorialView()
        .environmentObject(Config())
        .environmentObject(AppearanceManager.shared)
        .preferredColorScheme(.dark)
}

#Preview("Tutorial - Splits Step") {
    TutorialPreviewWrapper(step: .splits)
}

#Preview("Tutorial - Calendar Step") {
    TutorialPreviewWrapper(step: .calendar)
}

struct TutorialPreviewWrapper: View {
    let step: TutorialHighlight

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.85)
                    .ignoresSafeArea()

                MockUIOverlay(currentStep: step, geometry: geometry)

                VStack {
                    if step.tooltipAlignment == .below {
                        Spacer()
                    }

                    TooltipCard(
                        step: step,
                        accentColor: .blue,
                        isFirstStep: false,
                        isLastStep: false,
                        onNext: {},
                        onBack: {},
                        onSkip: {}
                    )
                    .padding(.horizontal, 24)

                    if step.tooltipAlignment == .above {
                        Spacer()
                    }
                }
                .padding(.vertical, 100)
            }
        }
        .preferredColorScheme(.dark)
    }
}
