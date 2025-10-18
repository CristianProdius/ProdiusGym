//
//  iCloudSyncManager.swift
//  Gymly
//
//  Created by Sebastián Kučera on 17.10.2025.
//

import Foundation
import Combine

@MainActor
class iCloudSyncManager: ObservableObject {
    private let store = NSUbiquitousKeyValueStore.default
    private let config: Config

    // Keys for iCloud storage
    private let kHasCompletedProfile = "hasCompletedFitnessProfile"
    private let kFitnessGoal = "fitnessGoal"
    private let kEquipmentAccess = "equipmentAccess"
    private let kExperienceLevel = "experienceLevel"
    private let kTrainingDaysPerWeek = "trainingDaysPerWeek"

    init(config: Config) {
        self.config = config

        // Listen for iCloud changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store
        )

        debugPrint("☁️ iCloudSyncManager initialized")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Sync Operations

    /// Sync profile to iCloud (non-blocking)
    func syncToiCloud() {
        // Run on background thread to avoid blocking UI
        Task.detached(priority: .utility) {
            let store = NSUbiquitousKeyValueStore.default

            await MainActor.run {
                store.set(self.config.hasCompletedFitnessProfile, forKey: self.kHasCompletedProfile)
                store.set(self.config.fitnessGoal, forKey: self.kFitnessGoal)
                store.set(self.config.equipmentAccess, forKey: self.kEquipmentAccess)
                store.set(self.config.experienceLevel, forKey: self.kExperienceLevel)
                store.set(self.config.trainingDaysPerWeek, forKey: self.kTrainingDaysPerWeek)
            }

            // Synchronize happens in background
            let synced = store.synchronize()
            if synced {
                debugPrint("☁️ ✅ Fitness profile synced to iCloud successfully")
            } else {
                debugPrint("☁️ ⚠️ iCloud sync may be delayed or unavailable")
            }
        }
    }

    /// Fetch profile from iCloud
    func fetchFromiCloud() {
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
            let timeoutTask = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                debugPrint("☁️ ⏱️ iCloud fetch timed out, using local data")
                continuation.resume()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: timeoutTask)

            Task { @MainActor in
                self.fetchFromiCloud()
                timeoutTask.cancel()
                continuation.resume()
            }
        }
    }

    /// Clear fitness profile from both iCloud and local storage
    func clearProfile() {
        debugPrint("☁️ 🗑️ Clearing fitness profile...")

        // Clear from Config (UserDefaults)
        config.hasCompletedFitnessProfile = false
        config.fitnessGoal = ""
        config.equipmentAccess = ""
        config.experienceLevel = ""
        config.trainingDaysPerWeek = 4

        // Clear from iCloud
        store.removeObject(forKey: kHasCompletedProfile)
        store.removeObject(forKey: kFitnessGoal)
        store.removeObject(forKey: kEquipmentAccess)
        store.removeObject(forKey: kExperienceLevel)
        store.removeObject(forKey: kTrainingDaysPerWeek)
        store.synchronize()

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
