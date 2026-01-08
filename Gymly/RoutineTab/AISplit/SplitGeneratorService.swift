//
//  SplitGeneratorService.swift
//  ShadowLift
//
//  Created by Claude Code on 05.01.2026.
//

import Foundation
import FoundationModels
import SwiftUI

// MARK: - Errors

enum SplitGeneratorError: LocalizedError {
    case missingPreferences
    case generationFailed(String)
    case invalidMuscleGroups

    var errorDescription: String? {
        switch self {
        case .missingPreferences:
            return "Please complete the questionnaire before generating a split."
        case .generationFailed(let reason):
            return "Failed to generate split: \(reason)"
        case .invalidMuscleGroups:
            return "Generated split contains invalid muscle groups. Please try again."
        }
    }
}

// MARK: - Split Generator Service

@available(iOS 26, *)
@MainActor
final class SplitGeneratorService: ObservableObject {
    @Published private(set) var generatedSplit: GeneratedSplit.PartiallyGenerated?
    @Published var isGenerating = false
    @Published var error: Error?
    @Published private(set) var isPrewarming = false

    // Lazy session initialization to avoid blocking on init
    private var _session: LanguageModelSession?
    private var session: LanguageModelSession {
        if _session == nil {
            _session = createSession()
        }
        return _session!
    }

    init() {
        // Don't initialize session here - do it lazily
    }

    private func createSession() -> LanguageModelSession {
        LanguageModelSession(
            instructions: Instructions {
                "You are an expert personal trainer. Create workout splits based on user preferences."
                "ONLY use these muscle groups: Chest, Back, Biceps, Triceps, Shoulders, Quads, Hamstrings, Calves, Glutes, Abs"
            }
        )
    }

    /// Generate a personalized split based on user preferences
    func generateSplit(preferences: SplitPreferences) async throws {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        // Build compact prompt
        let muscleList = preferences.musclePriority.isEmpty ? "balanced" : preferences.musclePriority.joined(separator: ", ")
        let limitations = preferences.limitations ?? "none"

        let stream = session.streamResponse(
            generating: GeneratedSplit.self,
            includeSchemaInPrompt: false,
            options: GenerationOptions(sampling: .greedy)
        ) {
            "Create \(preferences.daysPerWeek)-day \(preferences.splitType.displayName) split."
            "Goal: \(preferences.fitnessGoal.displayName). Equipment: \(preferences.equipment.displayName). Experience: \(preferences.experience.displayName)."
            "Duration: \(preferences.sessionDuration.displayName). Intensity: \(preferences.trainingIntensity.displayName). Priority: \(muscleList). Limitations: \(limitations)."
            "RULES: Use ONLY: Chest, Back, Biceps, Triceps, Shoulders, Quads, Hamstrings, Calves, Glutes, Abs. 4-8 exercises/day. Compounds first."
        }

        for try await partialResponse in stream {
            generatedSplit = partialResponse.content
        }

        if let finalSplit = generatedSplit, let name = finalSplit.name, !name.isEmpty {
            debugLog("AI Split generated successfully: \(name)")
        }
    }

    /// Modify an existing split based on user feedback
    func modifySplit(userRequest: String) async throws {
        guard let currentSplit = generatedSplit else {
            throw SplitGeneratorError.missingPreferences
        }

        isGenerating = true
        error = nil
        defer { isGenerating = false }

        // Build compact representation of current split
        let splitSummary = buildSplitSummary(currentSplit)

        let stream = session.streamResponse(
            generating: GeneratedSplit.self,
            includeSchemaInPrompt: false,
            options: GenerationOptions(sampling: .greedy)
        ) {
            "CURRENT SPLIT: \(splitSummary)"
            "MODIFY: \(userRequest)"
            "Keep everything unchanged except what user asked. Use ONLY: Chest, Back, Biceps, Triceps, Shoulders, Quads, Hamstrings, Calves, Glutes, Abs."
        }

        for try await partialResponse in stream {
            generatedSplit = partialResponse.content
        }
    }

    /// Build a compact text summary of the current split for modification context
    private func buildSplitSummary(_ split: GeneratedSplit.PartiallyGenerated) -> String {
        var summary = "Name: \(split.name ?? "Unnamed")"

        if let days = split.days {
            for day in days {
                if let dayNum = day.dayNumber, let dayName = day.name {
                    if day.isRestDay == true {
                        summary += " | Day\(dayNum): \(dayName) (Rest)"
                    } else if let exercises = day.exercises {
                        let exerciseNames = exercises.compactMap { $0.name }.joined(separator: ", ")
                        summary += " | Day\(dayNum): \(dayName) [\(exerciseNames)]"
                    }
                }
            }
        }

        return summary
    }

    /// Clear the generated split
    func clearSplit() {
        generatedSplit = nil
        error = nil
    }

    /// Prewarm the AI session in background to avoid blocking UI
    func prewarm() {
        guard !isPrewarming && _session == nil else { return }
        isPrewarming = true

        // Run prewarm on a background thread to avoid blocking UI
        Task.detached(priority: .background) { [weak self] in
            // Create and prewarm session off main thread
            let newSession = LanguageModelSession(
                instructions: Instructions {
                    "You are an expert personal trainer. Create workout splits based on user preferences."
                    "ONLY use these muscle groups: Chest, Back, Biceps, Triceps, Shoulders, Quads, Hamstrings, Calves, Glutes, Abs"
                }
            )
            newSession.prewarm()

            await MainActor.run {
                self?._session = newSession
                self?.isPrewarming = false
            }
        }
    }

}
