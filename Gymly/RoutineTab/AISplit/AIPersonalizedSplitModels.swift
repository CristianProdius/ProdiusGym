//
//  AIPersonalizedSplitModels.swift
//  ShadowLift
//
//  Created by Claude Code on 05.01.2026.
//

import Foundation
import FoundationModels

// MARK: - Generated Split Structure

/// Root structure for AI-generated workout split
@Generable
public struct GeneratedSplit: Codable, Sendable {
    /// Name of the generated split (e.g., "Custom Push Pull Legs")
    public var name: String

    /// Brief description of the split structure
    public var description: String

    /// Array of workout days in the split
    public var days: [GeneratedDay]

    /// Explanation of why this split suits the user's goals and preferences
    public var rationale: String

    /// Estimated weekly volume description
    public var weeklyVolume: String?
}

/// Individual day within the split
@Generable
public struct GeneratedDay: Codable, Sendable {
    /// Position in the split (1-indexed)
    public var dayNumber: Int

    /// Name of the day (e.g., "Push Day", "Upper A", "Full Body")
    public var name: String

    /// Whether this is a rest day
    public var isRestDay: Bool

    /// Primary focus of the day (e.g., "Chest & Triceps focus")
    public var focus: String?

    /// Exercises for this day (nil for rest days)
    public var exercises: [GeneratedExercise]?
}

/// Individual exercise within a day
@Generable
public struct GeneratedExercise: Codable, Sendable {
    /// Exercise name (e.g., "Barbell Bench Press")
    public var name: String

    /// Target muscle group - MUST be one of: Chest, Back, Biceps, Triceps, Shoulders, Quads, Hamstrings, Calves, Glutes, Abs
    public var muscleGroup: String

    /// Number of working sets (typically 3-5)
    public var sets: Int

    /// Rep range or scheme (e.g., "8-12", "5x5", "AMRAP", "12-15")
    public var repRange: String

    /// Order within the day's workout (for sorting)
    public var exerciseOrder: Int

    /// Optional notes about the exercise (e.g., "Start with 2 warm-up sets")
    public var notes: String?
}

// MARK: - Valid Muscle Groups

/// The 10 valid muscle groups that exercises can target
enum ValidMuscleGroup: String, CaseIterable {
    case chest = "Chest"
    case back = "Back"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case shoulders = "Shoulders"
    case quads = "Quads"
    case hamstrings = "Hamstrings"
    case calves = "Calves"
    case glutes = "Glutes"
    case abs = "Abs"

    /// Returns list of all valid muscle group names for prompt construction
    static var validNames: [String] {
        return Self.allCases.map { $0.rawValue }
    }

    /// Validates if a string is a valid muscle group
    static func isValid(_ name: String) -> Bool {
        return Self.allCases.contains { $0.rawValue == name }
    }
}

// MARK: - Conversion to SwiftData Models

extension GeneratedSplit {
    /// Validates that all exercises use valid muscle groups
    func validateMuscleGroups() -> Bool {
        for day in days {
            guard let exercises = day.exercises else { continue }
            for exercise in exercises {
                if !ValidMuscleGroup.isValid(exercise.muscleGroup) {
                    debugLog("Invalid muscle group: \(exercise.muscleGroup) for exercise: \(exercise.name)")
                    return false
                }
            }
        }
        return true
    }
}
