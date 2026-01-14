//
//  SplitGeneratorQuestions.swift
//  ProdiusGym
//
//  Created by Claude Code on 05.01.2026.
//

import Foundation

// MARK: - Split Preferences (Collected from Questionnaire)

/// All user preferences collected from the questionnaire
struct SplitPreferences: Codable {
    // From existing FitnessProfile
    var fitnessGoal: FitnessGoal
    var equipment: EquipmentType
    var experience: ExperienceLevel
    var daysPerWeek: Int

    // Additional questionnaire responses
    var splitType: SplitTypePreference
    var sessionDuration: SessionDurationPreference
    var musclePriority: [String]  // Selected muscle groups to prioritize
    var trainingIntensity: IntensityPreference
    var exerciseVariety: VarietyPreference
    var compoundIsolation: CompoundIsolationPreference
    var restDayPlacement: RestDayPreference
    var limitations: String?  // Free text for injuries/restrictions

    /// Initialize with existing fitness profile
    init(from profile: FitnessProfile) {
        self.fitnessGoal = profile.goal
        self.equipment = profile.equipment
        self.experience = profile.experience
        self.daysPerWeek = profile.daysPerWeek

        // Defaults for new questions
        self.splitType = .aiDecides
        self.sessionDuration = .medium
        self.musclePriority = []
        self.trainingIntensity = .moderate
        self.exerciseVariety = .moderate
        self.compoundIsolation = .balanced
        self.restDayPlacement = .flexible
        self.limitations = nil
    }

    /// Default initializer
    init() {
        self.fitnessGoal = .gainMuscle
        self.equipment = .fullGym
        self.experience = .intermediate
        self.daysPerWeek = 4
        self.splitType = .aiDecides
        self.sessionDuration = .medium
        self.musclePriority = []
        self.trainingIntensity = .moderate
        self.exerciseVariety = .moderate
        self.compoundIsolation = .balanced
        self.restDayPlacement = .flexible
        self.limitations = nil
    }
}

// MARK: - Question 1: Split Type Preference

enum SplitTypePreference: String, CaseIterable, Codable, Identifiable {
    case ppl = "ppl"
    case upperLower = "upper_lower"
    case fullBody = "full_body"
    case broSplit = "bro_split"
    case aiDecides = "ai_decides"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ppl: return "Push / Pull / Legs"
        case .upperLower: return "Upper / Lower"
        case .fullBody: return "Full Body"
        case .broSplit: return "Bro Split"
        case .aiDecides: return "Let AI Decide"
        }
    }

    var description: String {
        switch self {
        case .ppl:
            return "Train pushing muscles, pulling muscles, and legs on separate days"
        case .upperLower:
            return "Alternate between upper body and lower body workouts"
        case .fullBody:
            return "Hit all major muscle groups in every workout session"
        case .broSplit:
            return "Dedicate each day to one or two muscle groups"
        case .aiDecides:
            return "Let AI choose the best split based on your goals and schedule"
        }
    }

    var icon: String {
        switch self {
        case .ppl: return "arrow.left.arrow.right"
        case .upperLower: return "arrow.up.arrow.down"
        case .fullBody: return "figure.stand"
        case .broSplit: return "person.3.fill"
        case .aiDecides: return "sparkles"
        }
    }
}

// MARK: - Question 2: Session Duration Preference

enum SessionDurationPreference: String, CaseIterable, Codable, Identifiable {
    case short = "short"
    case medium = "medium"
    case long = "long"
    case extended = "extended"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .short: return "30-45 minutes"
        case .medium: return "45-60 minutes"
        case .long: return "60-90 minutes"
        case .extended: return "90+ minutes"
        }
    }

    var description: String {
        switch self {
        case .short:
            return "Quick, efficient workouts focusing on essentials"
        case .medium:
            return "Balanced sessions with warm-up, training, and cool-down"
        case .long:
            return "Comprehensive workouts with more exercises and volume"
        case .extended:
            return "Extended sessions for maximum volume and detail work"
        }
    }

    var icon: String {
        switch self {
        case .short: return "hare.fill"
        case .medium: return "clock"
        case .long: return "clock.fill"
        case .extended: return "hourglass"
        }
    }

    var minuteRange: (min: Int, max: Int) {
        switch self {
        case .short: return (30, 45)
        case .medium: return (45, 60)
        case .long: return (60, 90)
        case .extended: return (90, 120)
        }
    }
}

// MARK: - Question 3: Muscle Priority (Multi-select)

/// Available muscle groups for priority selection
struct MuscleGroupOption: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String

    static let allOptions: [MuscleGroupOption] = [
        MuscleGroupOption(id: "Chest", name: "Chest", icon: "figure.strengthtraining.traditional"),
        MuscleGroupOption(id: "Back", name: "Back", icon: "figure.rower"),
        MuscleGroupOption(id: "Shoulders", name: "Shoulders", icon: "figure.arms.open"),
        MuscleGroupOption(id: "Biceps", name: "Biceps", icon: "dumbbell.fill"),
        MuscleGroupOption(id: "Triceps", name: "Triceps", icon: "figure.highintensity.intervaltraining"),
        MuscleGroupOption(id: "Quads", name: "Quads", icon: "figure.walk"),
        MuscleGroupOption(id: "Hamstrings", name: "Hamstrings", icon: "figure.run"),
        MuscleGroupOption(id: "Glutes", name: "Glutes", icon: "figure.cooldown"),
        MuscleGroupOption(id: "Calves", name: "Calves", icon: "figure.step.training"),
        MuscleGroupOption(id: "Abs", name: "Abs", icon: "figure.core.training")
    ]
}

// MARK: - Question 4: Training Intensity Preference

enum IntensityPreference: String, CaseIterable, Codable, Identifiable {
    case moderate = "moderate"
    case high = "high"
    case varied = "varied"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .moderate: return "Moderate Intensity"
        case .high: return "High Intensity"
        case .varied: return "Varied Intensity"
        }
    }

    var description: String {
        switch self {
        case .moderate:
            return "Sustainable effort level with 2-3 reps in reserve on most sets"
        case .high:
            return "Push close to failure on working sets for maximum stimulus"
        case .varied:
            return "Mix of moderate and intense days with planned deloads"
        }
    }

    var icon: String {
        switch self {
        case .moderate: return "gauge.with.dots.needle.33percent"
        case .high: return "gauge.with.dots.needle.100percent"
        case .varied: return "waveform.path.ecg"
        }
    }
}

// MARK: - Question 5: Exercise Variety Preference

enum VarietyPreference: String, CaseIterable, Codable, Identifiable {
    case basics = "basics"
    case moderate = "moderate"
    case high = "high"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .basics: return "Stick to Basics"
        case .moderate: return "Some Variety"
        case .high: return "Lots of Variation"
        }
    }

    var description: String {
        switch self {
        case .basics:
            return "Focus on proven compound movements with minimal variation"
        case .moderate:
            return "Core exercises with some accessory work and occasional swaps"
        case .high:
            return "Diverse exercise selection with regular rotation and variation"
        }
    }

    var icon: String {
        switch self {
        case .basics: return "square.stack"
        case .moderate: return "rectangle.stack"
        case .high: return "square.stack.3d.up"
        }
    }
}

// MARK: - Question 6: Compound vs Isolation Preference

enum CompoundIsolationPreference: String, CaseIterable, Codable, Identifiable {
    case compoundFocused = "compound_focused"
    case balanced = "balanced"
    case isolationIncluded = "isolation_included"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .compoundFocused: return "Compound-Focused"
        case .balanced: return "Balanced Mix"
        case .isolationIncluded: return "Include Isolations"
        }
    }

    var description: String {
        switch self {
        case .compoundFocused:
            return "Prioritize multi-joint exercises like squats, deadlifts, and presses"
        case .balanced:
            return "Mix of compound movements and targeted isolation work"
        case .isolationIncluded:
            return "More isolation exercises for specific muscle development"
        }
    }

    var icon: String {
        switch self {
        case .compoundFocused: return "arrow.triangle.merge"
        case .balanced: return "equal.circle"
        case .isolationIncluded: return "target"
        }
    }
}

// MARK: - Question 7: Rest Day Placement Preference

enum RestDayPreference: String, CaseIterable, Codable, Identifiable {
    case afterEveryDay = "after_every_day"
    case weekendsOff = "weekends_off"
    case consecutiveTraining = "consecutive_training"
    case flexible = "flexible"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .afterEveryDay: return "Rest After Training"
        case .weekendsOff: return "Weekends Off"
        case .consecutiveTraining: return "Consecutive Days"
        case .flexible: return "AI Decides"
        }
    }

    var description: String {
        switch self {
        case .afterEveryDay:
            return "Include a rest day after every 1-2 training days"
        case .weekendsOff:
            return "Train weekdays with weekends reserved for recovery"
        case .consecutiveTraining:
            return "Train multiple days in a row before taking rest"
        case .flexible:
            return "Let AI optimize rest day placement for your schedule"
        }
    }

    var icon: String {
        switch self {
        case .afterEveryDay: return "arrow.left.arrow.right.circle"
        case .weekendsOff: return "calendar.badge.minus"
        case .consecutiveTraining: return "arrow.right.circle"
        case .flexible: return "sparkles"
        }
    }
}

// MARK: - Question Order

enum SplitGeneratorQuestion: Int, CaseIterable {
    case splitType = 1
    case sessionDuration = 2
    case musclePriority = 3
    case trainingIntensity = 4
    case exerciseVariety = 5
    case compoundIsolation = 6
    case restDayPlacement = 7
    case limitations = 8

    var title: String {
        switch self {
        case .splitType: return "What split structure do you prefer?"
        case .sessionDuration: return "How long do you want your workouts?"
        case .musclePriority: return "Any muscles to prioritize?"
        case .trainingIntensity: return "What intensity level do you prefer?"
        case .exerciseVariety: return "How much exercise variety do you want?"
        case .compoundIsolation: return "Compound or isolation preference?"
        case .restDayPlacement: return "How should rest days be placed?"
        case .limitations: return "Any injuries or limitations?"
        }
    }

    var subtitle: String {
        switch self {
        case .splitType: return "Choose how your training days are organized"
        case .sessionDuration: return "This affects the number of exercises per session"
        case .musclePriority: return "Select muscles you want to emphasize (optional)"
        case .trainingIntensity: return "How hard you push during your sets"
        case .exerciseVariety: return "More variety vs consistent exercise selection"
        case .compoundIsolation: return "Multi-joint vs single-joint exercise balance"
        case .restDayPlacement: return "When to schedule recovery days"
        case .limitations: return "Injuries, restrictions, or equipment limitations"
        }
    }

    static var totalSteps: Int {
        return Self.allCases.count
    }
}
