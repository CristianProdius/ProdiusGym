//
//  WorkoutSummary.swift
//  ShadowLift
//
//  Created by Sebastián Kučera on 22.09.2025.
//


import Foundation
import FoundationModels


@Generable
public struct WorkoutSummary: Codable, Sendable {
    // Version first for parsing
    public var version: String                // "1.0"

    // Data/stats first - these inform the analysis
    @Guide(.maximumCount(3))
    public var keyStats: [KeyStat]            // compact, UI-friendly metrics

    public var session: SessionBreakdown      // per-exercise rollup

    @Guide(.maximumCount(4))
    public var trends: [Trend]                // short-term patterns (1–4 weeks)

    @Guide(.maximumCount(5))
    public var prs: [PersonalRecords]          // any PRs detected

    @Guide(.maximumCount(3))
    public var issues: [Issue]                // injuries, form flags, anomalies

    @Guide(.maximumCount(3))
    public var recommendations: [Recommendation] // next-steps you can act on

    // Analysis/summary LAST for best quality (generated after seeing all data)
    @Guide(description: "A motivating headline capturing the week's key achievement, max 10 words")
    public var headline: String               // e.g., "Solid Pull Day — 2 PRs"

    @Guide(description: "2-3 sentences summarizing overall performance in plain language")
    public var overview: String               // 2–3 sentences in plain language
}


@Generable
public struct KeyStat: Codable, Sendable {
    public var name: String                   // "Total Volume"
    public var value: String                  // "21,450 kg"
    public var delta: String?                 // "+6% vs last week"
    public var emoji: String?                 // "📈"
}


@Generable
public struct SessionBreakdown: Codable, Sendable {
    public var durationMinutes: Int
    public var effortRating: Int?             // 1–10 subjective or inferred
    public var exercises: [ExerciseSummary]
}


@Generable
public struct ExerciseSummary: Codable, Sendable {
    public var name: String                   // "Barbell Bench Press"
    public var sets: Int
    public var repsTotal: Int
    public var topSet: String?                // "110 kg × 3 @ RPE 9"
    public var volume: String?                // "7,920 kg"
    public var notes: String?                 // short, 1 sentence
}


@Generable
public struct Trend: Codable, Sendable {
    public var label: String                  // "Bench strength"

    @Guide(.anyOf(["up", "flat", "down"]))
    public var direction: String              // "up" | "flat" | "down"

    public var evidence: String               // "Top set +5 kg vs last week"
}


@Generable
public struct PersonalRecords: Codable, Sendable {
    public var exercise: String               // "Deadlift"

    @Guide(.anyOf(["Weight PR", "Rep PR", "Volume PR", "1RM Est"]))
    public var type: String                   // "Weight PR" | "Rep PR" | "Volume PR" | "1RM Est"

    public var value: String                  // "180 kg (est 1RM)"
}


@Generable
public struct Issue: Codable, Sendable {
    public var category: String               // "Form" | "Pain" | "Consistency"
    public var detail: String                 // "Knees caved on last 2 reps"

    @Guide(.anyOf(["low", "medium", "high"]))
    public var severity: String               // "low" | "medium" | "high"
}


@Generable
public struct Recommendation: Codable, Sendable {
    public var title: String                  // "Deload lower body volume by 10%"
    public var rationale: String              // why
    public var action: String                 // concrete next step
}
