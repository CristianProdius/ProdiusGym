//
//  WorkoutDataFetcher.swift
//  ShadowLift
//
//  Created by Sebastián Kučera on 22.09.2025.
//

import Foundation
import SwiftData

// IMPORTANT: Using @ModelActor for thread-safe background SwiftData access
// This is Apple's recommended pattern for off-main-thread database operations
@ModelActor
actor WorkoutDataFetcher {
    // Static DateFormatter for performance (expensive to create)
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    func fetchWeeklyWorkouts() -> [CompletedWorkout] {
        return fetchWorkouts(weeksBack: 0, numberOfWeeks: 1)
    }

    func fetchWorkoutsForComparison() -> (thisWeek: [CompletedWorkout], lastWeek: [CompletedWorkout]) {
        let thisWeek = fetchWorkouts(weeksBack: 0, numberOfWeeks: 1)
        let lastWeek = fetchWorkouts(weeksBack: 1, numberOfWeeks: 1)
        return (thisWeek, lastWeek)
    }

    private func fetchWorkouts(weeksBack: Int, numberOfWeeks: Int) -> [CompletedWorkout] {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .weekOfYear, value: -weeksBack, to: Date()) ?? Date()
        guard let startDate = calendar.date(byAdding: .day, value: -(numberOfWeeks * 7), to: endDate) else {
            #if DEBUG
            debugLog("🔍 AI Fetch: Failed to create start date")
            #endif
            return []
        }

        let startDateString = Self.dateFormatter.string(from: startDate)
        let endDateString = Self.dateFormatter.string(from: endDate)

        #if DEBUG
        debugLog("🔍 AI Fetch: Looking for workouts between '\(startDateString)' and '\(endDateString)'")
        debugLog("🔍 AI Fetch: Date range (Date objects): \(startDate) to \(endDate)")
        #endif

        // IMPORTANT: Cannot use string comparison for date filtering because the format
        // "d MMMM yyyy" (e.g., "2 October 2025") does not sort correctly as strings.
        // String "2 October" comes before "18 November" alphabetically, but October comes after November chronologically.
        // Solution: Fetch all DayStorage entries, then filter using Date comparison in Swift.
        let dayStorageDescriptor = FetchDescriptor<DayStorage>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        do {
            // Fetch ALL DayStorage entries using modelContext (provided by @ModelActor)
            let allDayStorages = try modelContext.fetch(dayStorageDescriptor)

            #if DEBUG
            debugLog("🔍 AI Fetch: Found \(allDayStorages.count) total DayStorage entries in database")
            #endif

            // Filter by date range using Date comparison
            let dayStorages = allDayStorages.filter { storage in
                guard let storageDate = Self.dateFormatter.date(from: storage.date) else {
                    #if DEBUG
                    debugLog("   ⚠️ Could not parse date: '\(storage.date)'")
                    #endif
                    return false
                }
                return storageDate >= startDate && storageDate <= endDate
            }

            #if DEBUG
            debugLog("🔍 AI Fetch: Found \(dayStorages.count) DayStorage entries in date range (after filtering)")
            debugLog("🔍 AI Fetch: Date range filter: \(startDate) to \(endDate)")
            // Log each DayStorage entry to check for duplicates
            for storage in dayStorages {
                debugLog("   📋 DayStorage: date='\(storage.date)', dayName='\(storage.dayName)', dayId=\(storage.dayId)")
            }
            #endif

            var completedWorkouts: [CompletedWorkout] = []
            var skippedCount = 0
            var skippedReasons: [String: Int] = [:]

            for dayStorage in dayStorages {
                #if DEBUG
                debugLog("\n🔍 Processing DayStorage: date='\(dayStorage.date)', dayName='\(dayStorage.dayName)'")
                #endif

                // Fetch Day directly by ID
                let dayId = dayStorage.dayId
                let dayDescriptor = FetchDescriptor<Day>(
                    predicate: #Predicate<Day> { day in
                        day.id == dayId
                    }
                )

                guard let day = try modelContext.fetch(dayDescriptor).first else {
                    #if DEBUG
                    debugLog("   ❌ SKIP: Day with id \(dayId) does NOT exist (orphaned DayStorage)")
                    #endif
                    skippedCount += 1
                    skippedReasons["orphaned (Day not found)"] = (skippedReasons["orphaned (Day not found)"] ?? 0) + 1
                    continue
                }

                #if DEBUG
                debugLog("   ✅ Day found: id=\(day.id)")
                #endif

                guard let exercises = day.exercises, !exercises.isEmpty else {
                    #if DEBUG
                    debugLog("   ❌ SKIP: Day has NO exercises")
                    #endif
                    skippedCount += 1
                    skippedReasons["no exercises"] = (skippedReasons["no exercises"] ?? 0) + 1
                    continue
                }

                #if DEBUG
                debugLog("   📊 Day has \(exercises.count) total exercises")
                #endif

                // Separate completed and incomplete exercises
                let completedExercises = exercises.compactMap { exercise -> CompletedExercise? in
                    guard exercise.done,
                          let sets = exercise.sets,
                          !sets.isEmpty else {
                        return nil
                    }

                    let completedSets = sets.map { set in
                        CompletedSet(
                            weight: set.weight,
                            reps: set.reps,
                            failure: set.failure,
                            dropSet: set.dropSet,
                            restPause: set.restPause
                        )
                    }

                    return CompletedExercise(
                        name: exercise.name,
                        muscleGroup: exercise.muscleGroup,
                        sets: completedSets
                    )
                }

                // Get incomplete exercises for recommendations
                let incompleteExercises = exercises.compactMap { exercise -> IncompleteExercise? in
                    guard !exercise.done else { return nil }

                    return IncompleteExercise(
                        name: exercise.name,
                        muscleGroup: exercise.muscleGroup
                    )
                }

                #if DEBUG
                debugLog("   📈 Completed exercises: \(completedExercises.count)")
                debugLog("   📉 Incomplete exercises: \(incompleteExercises.count)")
                #endif

                guard !completedExercises.isEmpty else {
                    #if DEBUG
                    debugLog("   ❌ SKIP: Day has NO COMPLETED exercises (all incomplete)")
                    #endif
                    skippedCount += 1
                    skippedReasons["no completed exercises"] = (skippedReasons["no completed exercises"] ?? 0) + 1
                    continue
                }

                let workoutDate = Self.dateFormatter.date(from: dayStorage.date) ?? Date()
                let duration = calculateDuration(from: completedExercises)

                #if DEBUG
                debugLog("   ✅ INCLUDED: Adding workout with \(completedExercises.count) exercises")
                #endif

                completedWorkouts.append(
                    CompletedWorkout(
                        date: workoutDate,
                        dayName: dayStorage.dayName,
                        duration: duration,
                        exercises: completedExercises,
                        incompleteExercises: incompleteExercises
                    )
                )
            }

            #if DEBUG
            debugLog("\n" + String(repeating: "=", count: 60))
            debugLog("📊 AI FETCH SUMMARY:")
            debugLog("   Total DayStorage entries found: \(dayStorages.count)")
            debugLog("   Valid workouts included: \(completedWorkouts.count)")
            debugLog("   Entries skipped: \(skippedCount)")
            if !skippedReasons.isEmpty {
                debugLog("   Skip reasons:")
                for (reason, count) in skippedReasons.sorted(by: { $0.value > $1.value }) {
                    debugLog("      - \(reason): \(count)")
                }
            }
            debugLog(String(repeating: "=", count: 60) + "\n")
            #endif

            return completedWorkouts.sorted { $0.date < $1.date }
        } catch {
            #if DEBUG
            debugLog("❌ AI Fetch Error: \(error)")
            #endif
            return []
        }
    }

    private func calculateDuration(from exercises: [CompletedExercise]) -> Int {
        let totalSets = exercises.reduce(0) { $0 + $1.sets.count }
        let estimatedMinutesPerSet = 3
        let restTimeMinutes = 2
        return (totalSets * estimatedMinutesPerSet) + (totalSets * restTimeMinutes)
    }

    func fetchHistoricalData(for exerciseName: String, weeks: Int = 4) -> [ExerciseHistory] {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.name == exerciseName && exercise.done == true
            },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )

        do {
            let exercises = try modelContext.fetch(descriptor)
            return exercises.compactMap { exercise -> ExerciseHistory? in
                guard let sets = exercise.sets, !sets.isEmpty else { return nil }

                let maxWeight = sets.map { $0.weight }.max() ?? 0
                let totalVolume = sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }

                return ExerciseHistory(
                    date: exercise.completedAt ?? exercise.createdAt,
                    maxWeight: maxWeight,
                    totalVolume: totalVolume,
                    setCount: sets.count
                )
            }
        } catch {
            debugLog("Error fetching historical data: \(error)")
            return []
        }
    }
}

struct ExerciseHistory {
    let date: Date
    let maxWeight: Double
    let totalVolume: Double
    let setCount: Int
}

struct IncompleteExercise {
    let name: String
    let muscleGroup: String
}