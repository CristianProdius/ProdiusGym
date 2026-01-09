//
//  iCloudSyncManager.swift
//  ShadowLift
//
//  Created by Sebastián Kučera on 17.10.2025.
//

import Foundation
import Combine

@MainActor
class iCloudSyncManager: ObservableObject {
    static let shared = iCloudSyncManager()

    private let store = NSUbiquitousKeyValueStore.default
    private weak var config: Config?

    // Keys for iCloud storage
    private let kHasCompletedProfile = "hasCompletedFitnessProfile"
    private let kFitnessGoal = "fitnessGoal"
    private let kEquipmentAccess = "equipmentAccess"
    private let kExperienceLevel = "experienceLevel"
    private let kTrainingDaysPerWeek = "trainingDaysPerWeek"

    private var isSetup = false

    private init() {
        // Listen for iCloud changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store
        )

        debugPrint("☁️ iCloudSyncManager singleton initialized")
    }

    /// Setup with Config - call once during app initialization
    func setup(config: Config) {
        guard !isSetup else { return }
        self.config = config
        isSetup = true
        debugPrint("☁️ iCloudSyncManager setup with Config")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Sync Operations

    /// Sync profile to iCloud (non-blocking)
    func syncToiCloud() {
        guard let config = config else {
            debugPrint("☁️ ⚠️ iCloudSyncManager: Config not set, skipping sync")
            return
        }

        // Capture values to avoid Sendable issues
        let hasCompleted = config.hasCompletedFitnessProfile
        let goal = config.fitnessGoal
        let equipment = config.equipmentAccess
        let experience = config.experienceLevel
        let days = config.trainingDaysPerWeek
        let keyCompleted = kHasCompletedProfile
        let keyGoal = kFitnessGoal
        let keyEquipment = kEquipmentAccess
        let keyExperience = kExperienceLevel
        let keyDays = kTrainingDaysPerWeek

        // Run on background thread to avoid blocking UI
        Task.detached(priority: .utility) {
            let store = NSUbiquitousKeyValueStore.default

            store.set(hasCompleted, forKey: keyCompleted)
            store.set(goal, forKey: keyGoal)
            store.set(equipment, forKey: keyEquipment)
            store.set(experience, forKey: keyExperience)
            store.set(days, forKey: keyDays)

            // Note: synchronize() is deprecated and no longer necessary
            // The system automatically syncs NSUbiquitousKeyValueStore
            // Listen to didChangeExternallyNotification for sync confirmation
            debugPrint("☁️ ✅ Fitness profile queued for iCloud sync")
        }
    }

    /// Fetch profile from iCloud
    func fetchFromiCloud() {
        guard let config = config else {
            debugPrint("☁️ ⚠️ iCloudSyncManager: Config not set, skipping fetch")
            return
        }

        debugPrint("☁️ 🔍 Fetching fitness profile from iCloud...")

        // Check if profile exists in iCloud
        if store.bool(forKey: kHasCompletedProfile) {
            config.hasCompletedFitnessProfile = true
            config.fitnessGoal = store.string(forKey: kFitnessGoal) ?? ""
            config.equipmentAccess = store.string(forKey: kEquipmentAccess) ?? ""
            config.experienceLevel = store.string(forKey: kExperienceLevel) ?? ""

            let days = store.longLong(forKey: kTrainingDaysPerWeek)
            config.trainingDaysPerWeek = days > 0 ? Int(days) : 4

            debugPrint("☁️ ✅ Fitness profile fetched from iCloud")
            debugPrint("☁️    Goal: \(config.fitnessGoal)")
            debugPrint("☁️    Equipment: \(config.equipmentAccess)")
            debugPrint("☁️    Experience: \(config.experienceLevel)")
            debugPrint("☁️    Days/week: \(config.trainingDaysPerWeek)")
        } else {
            debugPrint("☁️ ℹ️ No fitness profile found in iCloud")
        }
    }

    /// Fetch from iCloud with timeout (for app launch)
    func fetchFromiCloudWithTimeout(timeout: TimeInterval = 2.0) async {
        debugPrint("☁️ 🔍 Fetching fitness profile from iCloud with \(timeout)s timeout...")

        await withCheckedContinuation { continuation in
            // Use a class to safely track if continuation has been resumed
            // This prevents the race condition where both timeout and completion could fire
            final class ResumeState: @unchecked Sendable {
                private let lock = NSLock()
                private var _hasResumed = false

                var hasResumed: Bool {
                    lock.lock()
                    defer { lock.unlock() }
                    return _hasResumed
                }

                func tryResume() -> Bool {
                    lock.lock()
                    defer { lock.unlock() }
                    if _hasResumed { return false }
                    _hasResumed = true
                    return true
                }
            }

            let state = ResumeState()

            let timeoutTask = DispatchWorkItem {
                if state.tryResume() {
                    debugPrint("☁️ ⏱️ iCloud fetch timed out, using local data")
                    continuation.resume()
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: timeoutTask)

            Task { @MainActor in
                self.fetchFromiCloud()
                timeoutTask.cancel()
                if state.tryResume() {
                    continuation.resume()
                }
            }
        }
    }

    /// Clear fitness profile from both iCloud and local storage
    func clearProfile() {
        debugPrint("☁️ 🗑️ Clearing fitness profile...")

        // Clear from Config (UserDefaults)
        if let config = config {
            config.hasCompletedFitnessProfile = false
            config.fitnessGoal = ""
            config.equipmentAccess = ""
            config.experienceLevel = ""
            config.trainingDaysPerWeek = 4
        }

        // Clear from iCloud
        store.removeObject(forKey: kHasCompletedProfile)
        store.removeObject(forKey: kFitnessGoal)
        store.removeObject(forKey: kEquipmentAccess)
        store.removeObject(forKey: kExperienceLevel)
        store.removeObject(forKey: kTrainingDaysPerWeek)
        // Note: synchronize() removed - system syncs automatically

        debugPrint("☁️ ✅ Fitness profile cleared")
    }

    // MARK: - iCloud Change Handler

    @objc private func iCloudStoreDidChange(notification: NSNotification) {
        debugPrint("☁️ 🔄 iCloud store changed externally (from another device)")

        // Get the list of keys that changed
        if let userInfo = notification.userInfo,
           let changeReason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int {

            switch changeReason {
            case NSUbiquitousKeyValueStoreServerChange:
                debugPrint("☁️    Reason: Server change")
            case NSUbiquitousKeyValueStoreInitialSyncChange:
                debugPrint("☁️    Reason: Initial sync")
            case NSUbiquitousKeyValueStoreQuotaViolationChange:
                debugPrint("☁️    Reason: Quota violation")
            case NSUbiquitousKeyValueStoreAccountChange:
                debugPrint("☁️    Reason: Account change")
            default:
                debugPrint("☁️    Reason: Unknown")
            }
        }

        // Fetch updated profile from iCloud
        Task { @MainActor in
            self.fetchFromiCloud()
        }
    }
}
