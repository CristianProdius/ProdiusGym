//
//  FloatingClouds.swift
//  ProdiusGym
//
//  Created by Sebastián Kučera on 10.09.2025.
//

import SwiftUI
import CoreFoundation
import Combine

struct CloudsTheme {
    var background: Color
    var topLeading: Color
    var topTrailing: Color
    var bottomLeading: Color
    var bottomTrailing: Color

    // MARK: - Classical Theme (Old Money Imperial Blue & Platinum)
    /// Old Money aesthetic - subtle, calm, refined Imperial Blue palette
    static func classical(_ scheme: ColorScheme) -> CloudsTheme {
        CloudsTheme(
            // Dark: Deep Imperial (#00112F) | Light: Ivory (#FDFBF7)
            background: scheme == .dark
                ? PremiumColors.deepImperial
                : PremiumColors.ivory,

            // Very subtle Imperial Blue - top left
            topLeading: scheme == .dark
                ? PremiumColors.imperialBlue.opacity(0.3)
                : PremiumColors.imperialBlue.opacity(0.08),

            // Subtle Platinum shimmer - top right
            topTrailing: scheme == .dark
                ? PremiumColors.platinum.opacity(0.1)
                : PremiumColors.silver.opacity(0.06),

            // Imperial Blue depth - bottom left
            bottomLeading: scheme == .dark
                ? PremiumColors.imperialBlue.opacity(0.2)
                : PremiumColors.platinum.opacity(0.05),

            // Platinum accent - bottom right
            bottomTrailing: scheme == .dark
                ? PremiumColors.platinum.opacity(0.15)
                : PremiumColors.imperialBlue.opacity(0.04)
        )
    }

    // MARK: - Premium Theme (Alias for Classical)
    /// Alias for classical theme - maintained for backward compatibility
    static func premium(_ scheme: ColorScheme) -> CloudsTheme {
        return classical(scheme)
    }

    // MARK: - Special Purpose Themes
    static func appleIntelligence(_ scheme: ColorScheme) -> CloudsTheme {
        CloudsTheme(
            // Inky base with an indigo tint (dark) / airy off-white with lavender cast (light)
            background: scheme == .dark
                ? Color(red: 0.05, green: 0.06, blue: 0.10)                 // near-black indigo
                : Color(red: 0.97, green: 0.97, blue: 1.00),                // soft cool white

            // Luminous electric blue/cyan up top-left
            topLeading: scheme == .dark
                ? Color(red: 0.20, green: 0.60, blue: 1.00, opacity: 0.85)  // electric blue glow
                : Color(red: 0.40, green: 0.70, blue: 1.00, opacity: 0.70),

            // Violet/magenta bloom top-right
            topTrailing: scheme == .dark
                ? Color(red: 0.75, green: 0.40, blue: 1.00, opacity: 0.75)  // vibrant violet
                : Color(red: 0.85, green: 0.55, blue: 1.00, opacity: 0.65),

            // Pink warmth bottom-left to balance the cool tones
            bottomLeading: scheme == .dark
                ? Color(red: 1.00, green: 0.45, blue: 0.70, opacity: 0.65)  // rosy glow
                : Color(red: 1.00, green: 0.55, blue: 0.80, opacity: 0.60),

            // Mint/cyan shimmer bottom-right for that “intelligent” sparkle
            bottomTrailing: scheme == .dark
                ? Color(red: 0.30, green: 1.00, blue: 0.95, opacity: 0.78)  // cool mint
                : Color(red: 0.45, green: 1.00, blue: 0.95, opacity: 0.70)
        )
    }
    
    static func black(_ scheme: ColorScheme) -> CloudsTheme {
        CloudsTheme(
            // Dark mode: pure black | Light mode: clean white
            background: scheme == .dark
                ? Color.black
                : Color(red: 0.97, green: 0.97, blue: 0.98),

            // Light mode: use slightly more saturated blue-gray tones for visibility
            topLeading: scheme == .dark
                ? Color(red: 0.20, green: 0.20, blue: 0.22, opacity: 0.75)
                : Color(red: 0.75, green: 0.78, blue: 0.88, opacity: 0.55),

            topTrailing: scheme == .dark
                ? Color(red: 0.25, green: 0.25, blue: 0.28, opacity: 0.5)
                : Color(red: 0.80, green: 0.82, blue: 0.92, opacity: 0.48),

            bottomLeading: scheme == .dark
                ? Color(red: 0.18, green: 0.18, blue: 0.20, opacity: 0.55)
                : Color(red: 0.72, green: 0.75, blue: 0.85, opacity: 0.45),

            bottomTrailing: scheme == .dark
                ? Color(red: 0.30, green: 0.30, blue: 0.33, opacity: 0.65)
                : Color(red: 0.78, green: 0.80, blue: 0.90, opacity: 0.50)
        )
    }
    
    static func graphite(_ scheme: ColorScheme) -> CloudsTheme {
        CloudsTheme(
            // Dark mode: deep black | Light mode: clean white with subtle cool tint
            background: scheme == .dark
                ? Color.black
                : Color(red: 0.96, green: 0.96, blue: 0.98),

            // Dark mode: subtle dark grays | Light mode: soft blue-gray with VISIBLE presence
            topLeading: scheme == .dark
                ? Color(red: 0.25, green: 0.25, blue: 0.28, opacity: 0.75)
                : Color(red: 0.70, green: 0.75, blue: 0.85, opacity: 0.65),

            topTrailing: scheme == .dark
                ? Color(red: 0.35, green: 0.35, blue: 0.38, opacity: 0.5)
                : Color(red: 0.75, green: 0.80, blue: 0.92, opacity: 0.55),

            bottomLeading: scheme == .dark
                ? Color(red: 0.20, green: 0.20, blue: 0.22, opacity: 0.55)
                : Color(red: 0.65, green: 0.72, blue: 0.85, opacity: 0.50),

            bottomTrailing: scheme == .dark
                ? Color(red: 0.40, green: 0.40, blue: 0.43, opacity: 0.65)
                : Color(red: 0.72, green: 0.78, blue: 0.90, opacity: 0.58)
        )
    }

    static func blue(_ scheme: ColorScheme) -> CloudsTheme { // original-ish
        CloudsTheme(
            background: Color(red: 0.043, green: 0.467, blue: 0.494),
            topLeading: scheme == .dark ? Color(red: 0.000, green: 0.176, blue: 0.216, opacity: 0.8)
                                        : Color(red: 0.039, green: 0.388, blue: 0.502, opacity: 0.81),
            topTrailing: scheme == .dark ? Color(red: 0.408, green: 0.698, blue: 0.420, opacity: 0.61)
                                         : Color(red: 0.196, green: 0.796, blue: 0.329, opacity: 0.5),
            bottomLeading: scheme == .dark ? Color(red: 0.525, green: 0.859, blue: 0.655, opacity: 0.45)
                                           : Color(red: 0.196, green: 0.749, blue: 0.486, opacity: 0.55),
            bottomTrailing: Color(red: 0.541, green: 0.733, blue: 0.812, opacity: 0.7)
        )
    }

    static func iCloud(_ scheme: ColorScheme) -> CloudsTheme {
        CloudsTheme(
            // Deep black background like iCloud interface
            background: Color(red: 0.0, green: 0.0, blue: 0.0),

            // Bright electric blue (iCloud brand color) - top left
            topLeading: Color(red: 0.0, green: 0.48, blue: 1.0, opacity: 0.85),

            // Lighter sky blue - top right
            topTrailing: Color(red: 0.2, green: 0.6, blue: 1.0, opacity: 0.7),

            // Deep blue with slight cyan tint - bottom left
            bottomLeading: Color(red: 0.0, green: 0.3, blue: 0.7, opacity: 0.6),

            // Bright cyan/light blue - bottom right
            bottomTrailing: Color(red: 0.3, green: 0.7, blue: 1.0, opacity: 0.75)
        )
    }
}
    
class CloudProvider: ObservableObject {
    let offset: CGSize
    let frameHeightRatio: CGFloat
    
    init() {
        frameHeightRatio = CGFloat.random(in: 0.7 ..< 1.4)
        offset = CGSize(width: CGFloat.random(in: -150 ..< 150),
                        height: CGFloat.random(in: -150 ..< 150))
    }
}
    
struct Cloud: View {
    @StateObject var provider = CloudProvider()
    let proxy: GeometryProxy
    let color: Color
    let rotationStart: Double
    let duration: Double
    let alignment: Alignment

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let progress = (t.truncatingRemainder(dividingBy: duration)) / duration
            let angle = rotationStart + progress * 360

            Circle()
                .fill(color)
                .frame(height: proxy.size.height / provider.frameHeightRatio)
                .offset(provider.offset)
                .rotationEffect(.degrees(angle))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
                .opacity(0.8)
        }
    }
}
    
struct FloatingClouds: View {
    @Environment(\.colorScheme) var scheme

    var theme: CloudsTheme?
    let blur: CGFloat

    init(theme: CloudsTheme? = nil, blur: CGFloat = 80) {
        // Increased default blur for softer, more subtle effect
        self.theme = theme
        self.blur = blur
    }

    var body: some View {
        let t = theme ?? CloudsTheme.classical(scheme)

        GeometryReader { proxy in
            ZStack {
                t.background
                // Slower animation durations (2x slower for classical, calm feel)
                Cloud(proxy: proxy,
                      color: t.bottomTrailing,
                      rotationStart: 0,
                      duration: 120,
                      alignment: .bottomTrailing)
                Cloud(proxy: proxy,
                      color: t.topTrailing,
                      rotationStart: 240,
                      duration: 100,
                      alignment: .topTrailing)
                Cloud(proxy: proxy,
                      color: t.bottomLeading,
                      rotationStart: 120,
                      duration: 160,
                      alignment: .bottomLeading)
                Cloud(proxy: proxy,
                      color: t.topLeading,
                      rotationStart: 180,
                      duration: 140,
                      alignment: .topLeading)
            }
            .blur(radius: blur)
            .ignoresSafeArea()
        }
    }
}

// Example usage:
// FloatingClouds(theme: CloudsTheme.red(scheme))    // red background
// FloatingClouds(theme: CloudsTheme.black(scheme))  // black/graphite background
// FloatingClouds(theme: CloudsTheme.blue(scheme))   // original-ish blue
