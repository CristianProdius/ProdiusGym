//
//  NotificationTestHelper.swift
//  Gymly
//
//  Created by Claude Code on 25.11.2025.
//

import Foundation
import SwiftData
import UserNotifications

#if DEBUG
@MainActor
class NotificationTestHelper {
    static let shared = NotificationTestHelper()

    private init() {}

    /// Test streak warning notification (simulates streak at risk)
    func testStreakWarningNotification() async {
        let notificationManager = NotificationManager.shared

        do {
            // Schedule a test notification in 5 seconds
            try await notificationManager.scheduleNotification(
                id: "test_streak_warning",
                title: "Your 15-day streak is at risk! 🔥",
                body: "Work out today to keep your streak alive!",
                timeInterval: 5,
                categoryIdentifier: NotificationManager.NotificationCategory.streak,
                userInfo: ["type": "test"]
            )

            debugLog("✅ TEST: Streak warning notification scheduled in 5 seconds")
        } catch {
            debugLog("❌ TEST: Failed to schedule notification - \(error)")
        }
    }

    /// Test streak saved notification
    func testStreakSavedNotification() async {
        let notificationManager = NotificationManager.shared

        do {
            try await notificationManager.scheduleNotification(
                id: "test_streak_saved",
                title: "Streak saved! 🎉",
                body: "16 days and counting. You're unstoppable!",
                timeInterval: 5,
                categoryIdentifier: NotificationManager.NotificationCategory.streak,
                userInfo: ["type": "test"]
            )

            debugLog("✅ TEST: Streak saved notification scheduled in 5 seconds")
        } catch {
            debugLog("❌ TEST: Failed to schedule notification - \(error)")
        }
    }

    /// Test streak milestone notification
    func testStreakMilestoneNotification() async {
        let notificationManager = NotificationManager.shared

        do {
            try await notificationManager.scheduleNotification(
                id: "test_streak_milestone",
                title: "30-Day Streak! 🏆",
                body: "One month of dedication. Incredible achievement!",
                timeInterval: 5,
                categoryIdentifier: NotificationManager.NotificationCategory.streak,
                userInfo: ["type": "test"]
            )

            debugLog("✅ TEST: Milestone notification scheduled in 5 seconds")
        } catch {
            debugLog("❌ TEST: Failed to schedule notification - \(error)")
        }
    }

    /// Simulate user with streak at risk (2 days since last workout, 2 rest days allowed)
    func simulateStreakAtRisk(userProfileManager: UserProfileManager, config: Config) {
        guard let profile = userProfileManager.currentProfile else {
            debugLog("❌ TEST: No user profile")
            return
        }

        // Set up a streak that's at risk
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!

        profile.currentStreak = 15
        profile.lastWorkoutDate = twoDaysAgo
        profile.restDaysPerWeek = 2
        profile.streakPaused = false

        debugLog("✅ TEST: Simulated streak at risk")
        debugLog("   - Current streak: 15 days")
        debugLog("   - Last workout: 2 days ago")
        debugLog("   - Rest days allowed: 2 per week")
        debugLog("   - Result: Streak will break TODAY if no workout")

        // Trigger notification scheduling
        StreakNotificationManager.shared.scheduleStreakProtection()
    }

    /// Simulate user with safe streak
    func simulateSafeStreak(userProfileManager: UserProfileManager, config: Config) {
        guard let profile = userProfileManager.currentProfile else {
            debugLog("❌ TEST: No user profile")
            return
        }

        // Set up a safe streak
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!

        profile.currentStreak = 10
        profile.lastWorkoutDate = yesterday
        profile.restDaysPerWeek = 2
        profile.streakPaused = false

        debugLog("✅ TEST: Simulated safe streak")
        debugLog("   - Current streak: 10 days")
        debugLog("   - Last workout: 1 day ago")
        debugLog("   - Rest days allowed: 2 per week")
        debugLog("   - Result: Streak safe for 1 more day")

        // Trigger notification scheduling
        StreakNotificationManager.shared.scheduleStreakProtection()
    }

    /// List all pending notifications
    func listPendingNotifications() async {
        let pending = await NotificationManager.shared.getPendingNotifications()

        debugLog("\n📋 PENDING NOTIFICATIONS (\(pending.count) total):")
        for request in pending {
            let content = request.content
            debugLog("   ID: \(request.identifier)")
            debugLog("   Title: \(content.title)")
            debugLog("   Body: \(content.body)")
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                debugLog("   Scheduled: \(trigger.nextTriggerDate() ?? Date())")
            } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                debugLog("   In: \(trigger.timeInterval) seconds")
            }
            debugLog("   ---")
        }
        debugLog("")
    }

    /// Clear all test notifications
    func clearAllTestNotifications() {
        NotificationManager.shared.cancelNotification(withId: "test_streak_warning")
        NotificationManager.shared.cancelNotification(withId: "test_streak_saved")
        NotificationManager.shared.cancelNotification(withId: "test_streak_milestone")
        debugLog("🗑️ TEST: Cleared all test notifications")
    }
}
#endif
