//
//  SignInView.swift
//  ShadowLift
//
//  Created by Sebastián Kučera on 28.01.2025.
//

import SwiftUI
import AuthenticationServices
import Foundation
import SwiftData

struct SignInView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) var colorScheme
    @State private var isSyncingFromCloud = false
    @State private var syncProgress: Double = 0.0
    @State private var syncError: String?
    @State private var syncStatus: SyncStatus = .checkingCloudKit

    // Animation states
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var featuresOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var floatingOffset: CGFloat = 0

    enum SyncStatus: CaseIterable {
        case checkingCloudKit
        case syncingProfile
        case syncingFitnessProfile
        case waitingForWorkouts
        case fetchingFromCloudKit
        case complete

        var message: String {
            switch self {
            case .checkingCloudKit: return "Checking iCloud status..."
            case .syncingProfile: return "Syncing your profile..."
            case .syncingFitnessProfile: return "Syncing fitness preferences..."
            case .waitingForWorkouts: return "Looking for your workouts..."
            case .fetchingFromCloudKit: return "Fetching workout data..."
            case .complete: return "All done!"
            }
        }

        var icon: String {
            switch self {
            case .checkingCloudKit: return "icloud"
            case .syncingProfile: return "person.crop.circle"
            case .syncingFitnessProfile: return "figure.strengthtraining.traditional"
            case .waitingForWorkouts: return "dumbbell"
            case .fetchingFromCloudKit: return "arrow.down.circle"
            case .complete: return "checkmark.circle.fill"
            }
        }

        var index: Int {
            switch self {
            case .checkingCloudKit: return 0
            case .syncingProfile: return 1
            case .syncingFitnessProfile: return 2
            case .waitingForWorkouts: return 3
            case .fetchingFromCloudKit: return 4
            case .complete: return 5
            }
        }
    }

    private var syncStatusMessage: String {
        syncStatus.message
    }

    var body: some View {
        ZStack {
            // Background
            FloatingClouds(theme: CloudsTheme.graphite(colorScheme))
                .ignoresSafeArea()

            // iCloud Sync Overlay
            if isSyncingFromCloud {
                iCloudSyncOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(1)
            }

            // Main Sign In Content
            signInContent
                .opacity(isSyncingFromCloud ? 0 : 1)
        }
        .onAppear {
            startEntryAnimations()
        }
    }

    // MARK: - Sign In Content

    private var signInContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero Section
            VStack(spacing: 24) {
                // App Logo with floating animation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 180, height: 180)
                        .blur(radius: 20)

                    // Logo container
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(white: colorScheme == .dark ? 0.15 : 0.95),
                                        Color(white: colorScheme == .dark ? 0.1 : 0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)

                        Image("AppLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .offset(y: floatingOffset)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // App Name & Tagline
                VStack(spacing: 12) {
                    Text("ShadowLift")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.primary,
                                    Color.primary.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Your personal strength training companion")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(titleOpacity)
            }

            Spacer()

            // Feature Highlights
            VStack(spacing: 16) {
                SignInFeatureRow(
                    icon: "dumbbell.fill",
                    iconColor: .orange,
                    title: "Track Every Rep",
                    subtitle: "Log workouts with ease"
                )

                SignInFeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: .green,
                    title: "See Your Progress",
                    subtitle: "Visualize gains over time"
                )

                SignInFeatureRow(
                    icon: "icloud.fill",
                    iconColor: .blue,
                    title: "Sync Everywhere",
                    subtitle: "Access on all your devices"
                )
            }
            .padding(.horizontal, 32)
            .opacity(featuresOpacity)

            Spacer()

            // Sign In Section
            VStack(spacing: 20) {
                // Apple Sign In Button with custom styling
                SignInWithAppleButton(.signUp) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    handleSignInResult(result)
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)

                // Privacy note
                Text("Your data stays private and secure")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
            .opacity(buttonOpacity)
        }
    }

    // MARK: - iCloud Sync Overlay

    private var iCloudSyncOverlay: some View {
        ZStack {
            // Background
            FloatingClouds(theme: CloudsTheme.iCloud(colorScheme))
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // iCloud Icon with animated ring
                ZStack {
                    // Pulsing ring
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 160, height: 160)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: syncProgress)
                        .stroke(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: syncProgress)

                    // iCloud image
                    Image(.shadowICloud)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                }

                // Status Section
                VStack(spacing: 20) {
                    Text("Syncing from iCloud")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    // Step indicators
                    VStack(spacing: 12) {
                        ForEach(Array(SyncStatus.allCases.dropLast().enumerated()), id: \.element.index) { _, step in
                            SyncStepRow(
                                step: step,
                                currentStatus: syncStatus,
                                isActive: step.index == syncStatus.index,
                                isComplete: step.index < syncStatus.index
                            )
                        }
                    }
                    .padding(.horizontal, 40)

                    // Error message if any
                    if let error = syncError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(8)
                    }
                }

                Spacer()

                // Progress percentage
                VStack(spacing: 8) {
                    ProgressView(value: syncProgress, total: 1.0)
                        .progressViewStyle(.linear)
                        .tint(.white)
                        .frame(width: 200)

                    Text("\(Int(syncProgress * 100))% complete")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.bottom, 60)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Animations

    private func startEntryAnimations() {
        // Floating animation for logo
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            floatingOffset = -8
        }

        // Staggered entry animations
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            titleOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            featuresOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
            buttonOpacity = 1.0
        }
    }

    // MARK: - Sign In Handler

    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            // IMMEDIATELY show loading overlay BEFORE any async work
            withAnimation(.easeInOut(duration: 0.3)) {
                isSyncingFromCloud = true
            }
            debugLog("SHOWING SYNC OVERLAY")

            if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                debugLog("User ID: \(userCredential.user)")

                // Store email in UserProfile if available (but don't override existing)
                if let email = userCredential.email {
                    debugLog("User Email: \(email)")
                    let currentEmail = userProfileManager.currentProfile?.email ?? ""
                    if currentEmail.isEmpty || currentEmail == "user@example.com" {
                        userProfileManager.updateEmail(email)
                    }
                } else {
                    debugLog("Email not available (User has logged in before)")
                }

                // Store username from Apple ID, but only as fallback
                if let fullName = userCredential.fullName,
                   let givenName = fullName.givenName {
                    debugLog("APPLE ID USERNAME: \(givenName)")
                    let currentUsername = userProfileManager.currentProfile?.username ?? ""
                    if currentUsername.isEmpty || currentUsername == "User" {
                        userProfileManager.updateUsername(givenName)
                    }
                }
            }

            let isFirstTimeLogin = (authorization.credential as? ASAuthorizationAppleIDCredential)?.fullName != nil
            debugLog("IS FIRST TIME LOGIN: \(isFirstTimeLogin)")

            // Trigger CloudKit sync after successful login
            Task {
                await performCloudSync()
            }

        case .failure(let error):
            debugLog("Could not authenticate: \(error.localizedDescription)")
        }
    }

    func ColorSchemeAdaptiveColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
    }

    // MARK: - Cloud Sync Logic

    private func performCloudSync() async {
        // Small delay to ensure overlay renders before heavy sync work
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        debugLog("STARTING CLOUDKIT SYNC PROCESS")

        // Step 1: Check CloudKit status
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                syncStatus = .checkingCloudKit
                syncProgress = 0.05
            }
        }

        await CloudKitManager.shared.checkCloudKitStatus()
        let isCloudKitAvailable = CloudKitManager.shared.isCloudKitEnabled

        debugLog("CLOUDKIT AVAILABLE: \(isCloudKitAvailable)")

        if isCloudKitAvailable {
            // Step 2: Sync user profile
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    syncStatus = .syncingProfile
                    syncProgress = 0.15
                }
            }

            debugLog("STARTING USERPROFILE CLOUDKIT SYNC")
            await userProfileManager.syncFromCloudKit()
            debugLog("USERPROFILE CLOUDKIT SYNC COMPLETED")
            debugLog("CURRENT USERNAME: \(userProfileManager.currentProfile?.username ?? "none")")

            // Step 3: Sync fitness profile from iCloud Key-Value Store
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    syncStatus = .syncingFitnessProfile
                    syncProgress = 0.25
                }
            }

            debugLog("FETCHING FITNESS PROFILE FROM ICLOUD")
            iCloudSyncManager.shared.setup(config: config)
            await iCloudSyncManager.shared.fetchFromiCloudWithTimeout(timeout: 2.0)
            debugLog("FITNESS PROFILE FETCH COMPLETED")
        }

        // Step 4: Wait for SwiftData to sync workout data
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                syncStatus = .waitingForWorkouts
                syncProgress = 0.35
            }
        }

        debugLog("WAITING FOR SWIFTDATA ICLOUD SYNC...")

        var attempts = 0
        let maxAttempts = 40 // 40 attempts × 0.5 seconds = 20 seconds max (SwiftData iCloud sync can be slow)
        var splitsFound = false
        var consecutiveErrors = 0

        while attempts < maxAttempts {
            // Update progress bar (35% to 85% during polling)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    syncProgress = 0.35 + (Double(attempts) / Double(maxAttempts)) * 0.5
                }
            }

            // Check if splits exist in database
            do {
                let descriptor = FetchDescriptor<Split>()
                let splits = try context.fetch(descriptor)
                consecutiveErrors = 0 // Reset error counter on success

                if !splits.isEmpty {
                    debugLog("FOUND \(splits.count) SPLITS IN DATABASE AFTER \(attempts) ATTEMPTS")
                    splitsFound = true
                    break
                }
            } catch {
                consecutiveErrors += 1
                debugLog("Error checking for splits (\(consecutiveErrors)): \(error.localizedDescription)")

                // If we have too many consecutive errors, break out
                if consecutiveErrors >= 3 {
                    await MainActor.run {
                        syncError = "Database temporarily unavailable"
                    }
                    break
                }
            }

            // Wait before next attempt
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            attempts += 1
        }

        // Step 5: If no splits found via SwiftData, try fetching from CloudKit directly
        if !splitsFound && isCloudKitAvailable {
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    syncStatus = .fetchingFromCloudKit
                    syncProgress = 0.90
                    syncError = nil // Clear any previous error
                }
            }

            debugLog("SWIFTDATA TIMEOUT - TRYING CLOUDKIT DIRECT FETCH")

            do {
                // Fetch and merge data from CloudKit as fallback
                await CloudKitManager.shared.fetchAndMergeData(context: context, config: config)

                // Check again if we have splits now
                let descriptor = FetchDescriptor<Split>()
                let splits = try context.fetch(descriptor)

                if !splits.isEmpty {
                    debugLog("CLOUDKIT FALLBACK SUCCESS - FOUND \(splits.count) SPLITS")
                    splitsFound = true
                } else {
                    debugLog("NO SPLITS IN CLOUDKIT - This may be a new user")
                }
            } catch {
                debugLog("CLOUDKIT FALLBACK FAILED: \(error.localizedDescription)")
                await MainActor.run {
                    syncError = "Sync completed with some issues"
                }
            }
        }

        // Step 6: Complete
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                syncStatus = .complete
                syncProgress = 1.0
            }
        }

        if splitsFound {
            debugLog("SYNC COMPLETED - SPLITS FOUND")
        } else {
            debugLog("SYNC COMPLETED - NO SPLITS (new user or no cloud data)")
        }

        // Small delay to show 100% before dismissing
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Post notification to refresh views after all syncs complete
        await MainActor.run {
            NotificationCenter.default.post(name: Notification.Name.cloudKitDataSynced, object: nil)
        }

        // Hide loading overlay and mark user as logged in
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.4)) {
                isSyncingFromCloud = false
            }
            config.isUserLoggedIn = true
            debugLog("SIGNIN: All syncs completed, transitioning to main app")
        }

        // If no splits found, start background polling for SwiftData sync
        // SwiftData's automatic iCloud sync may still be in progress
        if !splitsFound {
            debugLog("SIGNIN: Starting background polling for delayed SwiftData sync...")
            startBackgroundSyncPolling()
        }
    }

    /// Background polling for SwiftData sync that may complete after sign-in
    private func startBackgroundSyncPolling() {
        Task {
            var backgroundAttempts = 0
            let maxBackgroundAttempts = 60 // 60 × 1 second = 60 seconds max background polling

            while backgroundAttempts < maxBackgroundAttempts {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

                do {
                    let descriptor = FetchDescriptor<Split>()
                    let splits = try context.fetch(descriptor)

                    if !splits.isEmpty {
                        debugLog("SIGNIN BACKGROUND: Found \(splits.count) splits after \(backgroundAttempts) seconds!")

                        // Post notification to refresh views
                        await MainActor.run {
                            NotificationCenter.default.post(name: Notification.Name.cloudKitDataSynced, object: nil)
                        }
                        return // Stop polling
                    }
                } catch {
                    debugLog("SIGNIN BACKGROUND: Error checking splits: \(error.localizedDescription)")
                }

                backgroundAttempts += 1
            }

            debugLog("SIGNIN BACKGROUND: Polling timeout - no splits found after 60 seconds")
        }
    }
}

// MARK: - Supporting Views

struct SignInFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.listRowBackground(for: colorScheme))
        )
    }
}

struct SyncStepRow: View {
    let step: SignInView.SyncStatus
    let currentStatus: SignInView.SyncStatus
    let isActive: Bool
    let isComplete: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(isComplete ? Color.green : (isActive ? Color.white : Color.white.opacity(0.3)))
                    .frame(width: 24, height: 24)

                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                } else if isActive {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }

            // Step text
            Text(step.message)
                .font(.subheadline)
                .foregroundStyle(isActive ? .white : .white.opacity(isComplete ? 0.7 : 0.4))

            Spacer()

            // Icon
            if isActive {
                Image(systemName: step.icon)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}

// MARK: - Previews

#Preview("Sign In Screen") {
    SignInPreviewWrapper()
}

#Preview("iCloud Sync Overlay") {
    iCloudSyncPreview()
}

// Preview helper for Sign In (needs mock dependencies)
struct SignInPreviewWrapper: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            FloatingClouds(theme: CloudsTheme.graphite(colorScheme))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Hero Section
                VStack(spacing: 24) {
                    // App Logo
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.15), Color.clear],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 180, height: 180)
                            .blur(radius: 20)

                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(white: colorScheme == .dark ? 0.15 : 0.95),
                                            Color(white: colorScheme == .dark ? 0.1 : 0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)

                            Image("AppLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                    }

                    VStack(spacing: 12) {
                        Text("ShadowLift")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("Your personal strength training companion")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()

                // Feature Highlights
                VStack(spacing: 16) {
                    SignInFeatureRow(
                        icon: "dumbbell.fill",
                        iconColor: .orange,
                        title: "Track Every Rep",
                        subtitle: "Log workouts with ease"
                    )

                    SignInFeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: .green,
                        title: "See Your Progress",
                        subtitle: "Visualize gains over time"
                    )

                    SignInFeatureRow(
                        icon: "icloud.fill",
                        iconColor: .blue,
                        title: "Sync Everywhere",
                        subtitle: "Access on all your devices"
                    )
                }
                .padding(.horizontal, 32)

                Spacer()

                // Mock Sign In Button
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                        .frame(height: 56)
                        .overlay(
                            HStack(spacing: 8) {
                                Image(systemName: "apple.logo")
                                Text("Sign in with Apple")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)

                    Text("Your data stays private and secure")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }
}

// Preview for iCloud Sync Overlay
struct iCloudSyncPreview: View {
    @State private var syncProgress: Double = 0.45
    @State private var currentStep = 2

    let steps = [
        ("Checking iCloud status...", "icloud"),
        ("Syncing your profile...", "person.crop.circle"),
        ("Syncing fitness preferences...", "figure.strengthtraining.traditional"),
        ("Looking for your workouts...", "dumbbell"),
        ("Fetching workout data...", "arrow.down.circle")
    ]

    var body: some View {
        ZStack {
            FloatingClouds(theme: CloudsTheme.iCloud(.dark))
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // iCloud Icon with progress ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 160, height: 160)

                    Circle()
                        .trim(from: 0, to: syncProgress)
                        .stroke(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "icloud.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                }

                // Status Section
                VStack(spacing: 20) {
                    Text("Syncing from iCloud")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    // Step indicators
                    VStack(spacing: 12) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(index < currentStep ? Color.green : (index == currentStep ? Color.white : Color.white.opacity(0.3)))
                                        .frame(width: 24, height: 24)

                                    if index < currentStep {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white)
                                    } else if index == currentStep {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 8, height: 8)
                                    }
                                }

                                Text(steps[index].0)
                                    .font(.subheadline)
                                    .foregroundStyle(index == currentStep ? .white : .white.opacity(index < currentStep ? 0.7 : 0.4))

                                Spacer()

                                if index == currentStep {
                                    Image(systemName: steps[index].1)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }

                Spacer()

                // Progress
                VStack(spacing: 8) {
                    ProgressView(value: syncProgress, total: 1.0)
                        .progressViewStyle(.linear)
                        .tint(.white)
                        .frame(width: 200)

                    Text("\(Int(syncProgress * 100))% complete")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.bottom, 60)
            }
        }
        .preferredColorScheme(.dark)
    }
}
