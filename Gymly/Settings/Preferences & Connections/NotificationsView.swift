//
//  NotificationsView.swift
//  ShadowLift
//
//  Created by Sebastián Kučera on 25.11.2025.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject var config: Config
    @EnvironmentObject var userProfileManager: UserProfileManager
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showPermissionAlert = false

    var body: some View {
        ZStack {
            FloatingClouds(theme: CloudsTheme.graphite(scheme))
                .ignoresSafeArea()

            Form {
                // Permission Status Section
                Section(header: Text("Permission")) {
                    HStack {
                        Image(systemName: notificationManager.isAuthorized ? "checkmark.circle.fill" : "bell.slash.fill")
                            .foregroundStyle(notificationManager.isAuthorized ? .green : .orange)
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Status")
                                .font(.headline)
                            Text(notificationManager.isAuthorized ? "Granted" : "Not granted")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if !notificationManager.isAuthorized {
                            Button("Enable") {
                                Task {
                                    await requestPermission()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .listRowBackground(Color.black.opacity(0.05))

                    if !notificationManager.isAuthorized {
                        Text("Allow Gymly to send you helpful reminders and motivational notifications")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .listRowBackground(Color.black.opacity(0.05))
                    }

                    if notificationManager.isAuthorized {
                        Toggle("Enable Notifications", isOn: $config.notificationsEnabled)
                            .onChange(of: config.notificationsEnabled) { oldValue, newValue in
                                handleNotificationToggle(enabled: newValue)
                            }
                            .listRowBackground(Color.black.opacity(0.05))
                    }
                }

                if notificationManager.isAuthorized && config.notificationsEnabled {
                    // Streak Protection
                    Section(header: Text("Motivation")) {
                        Toggle(isOn: $config.streakNotificationsEnabled) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Streak Protection")
                                    Text("Get reminded before your streak breaks")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onChange(of: config.streakNotificationsEnabled) { _, _ in
                            StreakNotificationManager.shared.rescheduleAllStreakNotifications()
                        }
                        .listRowBackground(Color.black.opacity(0.05))
                    }

                    // Workout Reminders
                    Section(header: Text("Workout Reminders")) {
                        Toggle(isOn: $config.workoutReminderEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(.blue)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Daily Reminder")
                                    Text("Get reminded to work out")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .listRowBackground(Color.black.opacity(0.05))

                        if config.workoutReminderEnabled {
                            DatePicker(
                                "Reminder Time",
                                selection: $config.workoutReminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .listRowBackground(Color.black.opacity(0.05))
                        }
                    }

                    // Progress Tracking
                    Section(header: Text("Progress")) {
                        Toggle(isOn: $config.progressMilestonesEnabled) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(.yellow)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Milestones")
                                    Text("Celebrate PRs and achievements")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .listRowBackground(Color.black.opacity(0.05))
                    }

                    // Re-engagement
                    Section(header: Text("Re-engagement")) {
                        Toggle(isOn: $config.inactivityRemindersEnabled) {
                            HStack {
                                Image(systemName: "clock.badge.exclamationmark.fill")
                                    .foregroundStyle(.purple)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Inactivity Reminders")
                                    Text("Get notified if you've been inactive")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .listRowBackground(Color.black.opacity(0.05))

                        Text("We'll send you a gentle reminder if you haven't worked out in a few days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .listRowBackground(Color.black.opacity(0.05))
                    }
                }

                #if DEBUG
                // Debug Testing Section
                if notificationManager.isAuthorized && config.notificationsEnabled {
                    Section(header: Text("🧪 Testing (Debug Only)")) {
                        Button("Test Streak Warning") {
                            Task {
                                await NotificationTestHelper.shared.testStreakWarningNotification()
                            }
                        }
                        .listRowBackground(Color.black.opacity(0.05))

                        Button("Test Streak Saved") {
                            Task {
                                await NotificationTestHelper.shared.testStreakSavedNotification()
                            }
                        }
                        .listRowBackground(Color.black.opacity(0.05))

                        Button("Test Milestone") {
                            Task {
                                await NotificationTestHelper.shared.testStreakMilestoneNotification()
                            }
                        }
                        .listRowBackground(Color.black.opacity(0.05))

                        Button("Simulate Streak At Risk") {
                            NotificationTestHelper.shared.simulateStreakAtRisk(userProfileManager: userProfileManager, config: config)
                        }
                        .listRowBackground(Color.black.opacity(0.05))

                        Button("List Pending Notifications") {
                            Task {
                                await NotificationTestHelper.shared.listPendingNotifications()
                            }
                        }
                        .listRowBackground(Color.black.opacity(0.05))

                        Button("Clear Test Notifications", role: .destructive) {
                            NotificationTestHelper.shared.clearAllTestNotifications()
                        }
                        .listRowBackground(Color.black.opacity(0.05))
                    }
                }
                #endif
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await notificationManager.checkAuthorizationStatus()
        }
        .alert("Notification Permission Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                notificationManager.openSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable notifications in Settings to receive workout reminders and progress updates.")
        }
    }

    private func requestPermission() async {
        do {
            try await notificationManager.requestAuthorization()
            if notificationManager.isAuthorized {
                await MainActor.run {
                    config.notificationsEnabled = true
                }
            }
        } catch {
            await MainActor.run {
                showPermissionAlert = true
            }
        }
    }

    private func handleNotificationToggle(enabled: Bool) {
        if !enabled {
            // Cancel all pending notifications when disabled
            Task {
                notificationManager.cancelAllNotifications()
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .environmentObject(Config())
    }
}
