//
//  ToolBar.swift
//  ProdiusGym
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import HealthKit
import SwiftData

struct ToolBar: View {
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) private var context
    @State private var loginRefreshTrigger = false
    @StateObject private var userProfileManager = UserProfileManager.shared
    @StateObject private var appearanceManager = AppearanceManager.shared
    @StateObject private var prManager = PRManager.shared
    @StateObject private var streakNotificationManager = StreakNotificationManager.shared
    @StateObject private var workoutReminderManager = WorkoutReminderManager.shared
    @StateObject private var milestoneNotificationManager = MilestoneNotificationManager.shared
    @StateObject private var inactivityReminderManager = InactivityReminderManager.shared
    @State private var todayViewModel: WorkoutViewModel?
    @State private var calendarViewModel: WorkoutViewModel?
    @State private var settingsViewModel: WorkoutViewModel?
    @State private var showFitnessProfileSetup = false

    var body: some View {
        Group {
            if let todayVM = todayViewModel, let settingsVM = settingsViewModel, let calendarVM = calendarViewModel {
                mainTabView(todayVM: todayVM, settingsVM: settingsVM, calendarVM: calendarVM)
            } else {
                // Show loading while ViewModels initialize
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .environmentObject(config)
        .environmentObject(userProfileManager)
        .environmentObject(appearanceManager)
        .task {
            // Initialize UserProfileManager with SwiftData context
            userProfileManager.setup(modelContext: context)

            // Initialize PRManager with SwiftData context
            prManager.setup(modelContext: context, userProfileManager: userProfileManager)

            // Initialize StreakNotificationManager
            streakNotificationManager.setup(userProfileManager: userProfileManager, config: config)

            // Initialize WorkoutReminderManager
            workoutReminderManager.setup(modelContext: context, config: config)

            // Initialize MilestoneNotificationManager
            milestoneNotificationManager.setup(config: config)

            // Initialize InactivityReminderManager
            inactivityReminderManager.setup(userProfileManager: userProfileManager, config: config)

            // Initialize WorkoutViewModels and connect userProfileManager
            let todayVM = WorkoutViewModel(config: config, context: context)
            let settingsVM = WorkoutViewModel(config: config, context: context)
            let calendarVM = WorkoutViewModel(config: config, context: context)

            todayVM.setUserProfileManager(userProfileManager)
            settingsVM.setUserProfileManager(userProfileManager)
            calendarVM.setUserProfileManager(userProfileManager)

            todayViewModel = todayVM
            settingsViewModel = settingsVM
            calendarViewModel = calendarVM

            debugLog("✅ TOOLBAR: Connected userProfileManager to all ViewModels")

            // Load profile on app startup
            debugLog("🔄 TOOLBAR: Checking for existing profile...")

            // Try to load existing profile first
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try? context.fetch(descriptor)

            if let existingProfile = profiles?.first {
                // Profile exists in SwiftData - use it
                userProfileManager.currentProfile = existingProfile
                debugLog("✅ TOOLBAR: Loaded existing profile for \(existingProfile.username)")
            } else {
                // No local profile - create default profile
                debugLog("⚠️ TOOLBAR: No local profile found, creating default profile")
                userProfileManager.loadOrCreateProfile()
            }

            // Check streak status on app launch
            userProfileManager.checkStreakStatus()

            // Schedule streak protection notifications
            streakNotificationManager.scheduleStreakProtection()

            // Schedule smart workout reminders
            workoutReminderManager.scheduleSmartWorkoutReminders()

            // Check for inactivity and schedule reminder if needed
            inactivityReminderManager.checkAndScheduleInactivityReminder()
        }
    }

    // MARK: - Main Tab View

    @ViewBuilder
    private func mainTabView(todayVM: WorkoutViewModel, settingsVM: WorkoutViewModel, calendarVM: WorkoutViewModel) -> some View {
        TabView {
            TodayWorkoutView(viewModel: todayVM, loginRefreshTrigger: loginRefreshTrigger)
                .tabItem {
                    Label("Routine", systemImage: "dumbbell")
                }
                .tag(1)
            CalendarView(viewModel: calendarVM)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(2)
            SettingsView(viewModel: settingsVM)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
                .toolbar(.visible, for: .tabBar)
                .toolbarBackground(.black, for: .tabBar)
        }
        .tint(PremiumColors.gold)
        .fullScreenCover(isPresented: $showFitnessProfileSetup) {
            FitnessProfileSetupView()
        }
        .onChange(of: config.hasCompletedFitnessProfile) { _, hasCompleted in
            // If user hasn't completed profile, show setup
            if !hasCompleted {
                showFitnessProfileSetup = true
            }
        }
        .onAppear {
            // Check if profile needs to be shown on initial load
            if !config.hasCompletedFitnessProfile {
                showFitnessProfileSetup = true
            }
        }
    }

}

