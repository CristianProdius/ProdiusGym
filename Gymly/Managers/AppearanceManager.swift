//
//  AppearanceManager.swift
//  ProdiusGym
//
//  Created by Sebastián Kučera on 20.10.2025.
//

import SwiftUI
import Combine

// MARK: - Appearance Mode Options
public enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    public var id: String { rawValue }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil  // Follow system setting
        case .light: return .light
        case .dark: return .dark
        }
    }

    public var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

// MARK: - Premium Color Palette
/// Old Money Imperial Blue palette - Classical luxury inspired by heritage brands
public struct PremiumColors {
    // Core Palette - Old Money Imperial
    /// Imperial Blue - Primary color for headers, cards, surfaces
    public static let imperialBlue = Color(red: 0/255, green: 21/255, blue: 81/255)      // #001D51

    /// Deep Imperial - Dark mode backgrounds, deepest navy
    public static let deepImperial = Color(red: 0/255, green: 17/255, blue: 47/255)      // #00112F

    /// Ivory - Light mode backgrounds, warm white
    public static let ivory = Color(red: 253/255, green: 251/255, blue: 247/255)         // #FDFBF7

    /// Platinum - Primary accent for buttons, highlights, interactive elements
    public static let platinum = Color(red: 232/255, green: 232/255, blue: 232/255)      // #E8E8E8

    /// Silver - Secondary accent, muted elements
    public static let silver = Color(red: 192/255, green: 192/255, blue: 192/255)        // #C0C0C0

    /// Charcoal - Secondary text, subtle UI elements
    public static let charcoal = Color(red: 54/255, green: 69/255, blue: 79/255)         // #36454F

    // Derived Color Variants
    /// Light platinum for subtle backgrounds and highlights
    public static let platinumLight = platinum.opacity(0.2)

    /// Muted platinum for secondary elements
    public static let platinumMuted = platinum.opacity(0.6)

    /// Light imperial blue for card overlays
    public static let imperialLight = imperialBlue.opacity(0.15)

    /// Subtle silver for borders and separators
    public static let silverSubtle = silver.opacity(0.3)

    // Legacy Aliases (for backward compatibility)
    /// Legacy gold reference - now maps to platinum
    public static let gold = platinum

    /// Light gold - maps to platinum light
    public static let goldLight = platinumLight

    /// Muted gold - maps to platinum muted
    public static let goldMuted = platinumMuted
}

// MARK: - Appearance Manager
@MainActor
public class AppearanceManager: ObservableObject {
    public static let shared = AppearanceManager()

    @Published public var appearanceMode: AppearanceMode {
        didSet {
            saveAppearanceMode()
        }
    }

    /// Returns the ColorScheme to apply, or nil for system default
    public var colorScheme: ColorScheme? {
        appearanceMode.colorScheme
    }

    private let userDefaults = UserDefaults.standard
    private let appearanceModeKey = "selectedAppearanceMode"

    public init() {
        // Load saved appearance mode or default to system
        if let savedModeRaw = userDefaults.string(forKey: appearanceModeKey),
           let savedMode = AppearanceMode(rawValue: savedModeRaw) {
            self.appearanceMode = savedMode
        } else {
            self.appearanceMode = .system // Default
        }

        debugPrint("🎨 AppearanceManager initialized with mode: \(appearanceMode.rawValue)")
    }

    private func saveAppearanceMode() {
        userDefaults.set(appearanceMode.rawValue, forKey: appearanceModeKey)
        debugPrint("🎨 Appearance mode saved: \(appearanceMode.rawValue)")
    }
}

// MARK: - Color Extension Helper
public extension Color {
    /// The app's primary accent color - Premium Platinum
    static var appAccent: Color {
        PremiumColors.platinum
    }
}

// MARK: - Adaptive Colors for Light/Dark Mode
public extension Color {
    /// Adaptive list row background - subtle Imperial Blue tint
    static func listRowBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? PremiumColors.imperialBlue.opacity(0.15)
            : PremiumColors.imperialBlue.opacity(0.04)
    }

    /// Adaptive card background - deeper, more solid with Imperial tint
    static func cardBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? PremiumColors.imperialBlue.opacity(0.25)
            : PremiumColors.ivory.opacity(0.9)
    }

    /// Adaptive secondary background - Deep Imperial or Ivory
    static func secondaryBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? PremiumColors.deepImperial
            : PremiumColors.ivory
    }

    /// Adaptive text on floating clouds background
    static func adaptiveText(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? PremiumColors.ivory
            : PremiumColors.deepImperial
    }

    /// Adaptive secondary text
    static func adaptiveSecondaryText(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? PremiumColors.platinum.opacity(0.7)
            : PremiumColors.charcoal
    }

    /// Adaptive separator color
    static func adaptiveSeparator(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? PremiumColors.silver.opacity(0.2)
            : PremiumColors.imperialBlue.opacity(0.1)
    }
}

// MARK: - View Modifier for Adaptive List Row Background
public extension View {
    func adaptiveListRowBackground(_ scheme: ColorScheme) -> some View {
        self.listRowBackground(Color.listRowBackground(for: scheme))
    }
}

// MARK: - Old Money Typography System
/// Classical typography helpers for refined, understated luxury feel
public struct OldMoneyTypography {
    /// Large header with light weight and letter spacing
    public static func largeHeader(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.light)
            .tracking(2.0)
    }

    /// Section header with medium weight and subtle tracking
    public static func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .fontWeight(.medium)
            .tracking(0.5)
    }

    /// Number display with semibold weight and default design (not rounded)
    public static func number(_ value: String, size: CGFloat = 28) -> some View {
        Text(value)
            .font(.system(size: size, weight: .semibold, design: .default))
    }

    /// Body text with regular weight
    public static func body(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .fontWeight(.regular)
    }

    /// Caption text with regular weight
    public static func caption(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.regular)
    }
}

// MARK: - Typography View Modifiers
public extension Text {
    /// Apply classical header styling with light weight and tracking
    func classicalHeader() -> some View {
        self.fontWeight(.light)
            .tracking(1.5)
    }

    /// Apply section header styling with medium weight
    func classicalSection() -> some View {
        self.fontWeight(.medium)
            .tracking(0.5)
            .textCase(.uppercase)
    }

    /// Apply number styling with default design (not rounded)
    func classicalNumber(size: CGFloat = 28) -> some View {
        self.font(.system(size: size, weight: .semibold, design: .default))
    }
}
