//
//  AppearanceView.swift
//  ProdiusGym
//
//  Created by Sebastián Kučera on 20.10.2025.
//

import SwiftUI

struct AppearanceView: View {
    @ObservedObject private var appearanceManager = AppearanceManager.shared
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            FloatingClouds(theme: CloudsTheme.premium(scheme))
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "paintbrush.fill")
                            .font(.system(size: 50))
                            .foregroundColor(PremiumColors.gold)

                        Text("App Appearance")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Premium luxury theme")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)

                    // Live Preview Card
                    LivePreviewCard()
                        .padding(.horizontal, 24)

                    // Appearance Mode Picker
                    VStack(spacing: 16) {
                        HStack {
                            Text("Appearance Mode")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal, 24)

                        // Custom mode selector
                        HStack(spacing: 12) {
                            ForEach(AppearanceMode.allCases) { mode in
                                AppearanceModeButton(
                                    mode: mode,
                                    isSelected: appearanceManager.appearanceMode == mode
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        appearanceManager.appearanceMode = mode
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // Info note
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.secondary)
                            Text("System follows your device's appearance settings")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 24)
                    }

                    // Premium Theme Info
                    VStack(spacing: 16) {
                        HStack {
                            Text("Premium Theme")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal, 24)

                        HStack(spacing: 16) {
                            // Color swatches
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(PremiumColors.imperialBlue)
                                    .frame(width: 40, height: 40)
                                Text("Imperial")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            VStack(spacing: 8) {
                                Circle()
                                    .fill(PremiumColors.platinum)
                                    .frame(width: 40, height: 40)
                                Text("Platinum")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            VStack(spacing: 8) {
                                Circle()
                                    .fill(PremiumColors.deepImperial)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                    )
                                Text("Deep")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            VStack(spacing: 8) {
                                Circle()
                                    .fill(PremiumColors.ivory)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                    )
                                Text("Ivory")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 24)

                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(PremiumColors.platinum)
                            Text("Old Money Imperial Blue palette - classical luxury")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Live Preview Card
struct LivePreviewCard: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: 16) {
            Text("Preview")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Preview UI Elements
            VStack(spacing: 16) {
                // Button Preview
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Text("Primary Button")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(PremiumColors.gold)
                            .cornerRadius(12)
                    }

                    Button(action: {}) {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .foregroundColor(PremiumColors.gold)
                            .frame(width: 50, height: 50)
                            .background(Color.listRowBackground(for: scheme))
                            .cornerRadius(12)
                    }
                }

                // Progress Bar Preview
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Workout Progress")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("75%")
                            .font(.subheadline)
                            .foregroundColor(PremiumColors.gold)
                            .fontWeight(.semibold)
                    }

                    ProgressView(value: 0.75)
                        .tint(PremiumColors.gold)
                }

                // Badge Preview
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                        Text("7 day streak")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(PremiumColors.goldLight)
                    .foregroundColor(PremiumColors.gold)
                    .cornerRadius(8)

                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                        Text("New PR")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(PremiumColors.goldLight)
                    .foregroundColor(PremiumColors.gold)
                    .cornerRadius(8)

                    Spacer()
                }
            }
            .padding()
            .background(Color.listRowBackground(for: scheme))
            .cornerRadius(16)
        }
    }
}

// MARK: - Appearance Mode Button
struct AppearanceModeButton: View {
    @Environment(\.colorScheme) private var scheme
    let mode: AppearanceMode
    let isSelected: Bool
    let action: () -> Void

    private var modeColor: Color {
        switch mode {
        case .light: return .orange
        case .dark: return PremiumColors.imperialBlue
        case .system: return PremiumColors.platinum
        }
    }

    private var backgroundColor: Color {
        switch mode {
        case .light:
            return isSelected ? .orange.opacity(0.15) : Color.listRowBackground(for: scheme)
        case .dark:
            return isSelected ? PremiumColors.imperialBlue.opacity(0.15) : Color.listRowBackground(for: scheme)
        case .system:
            return isSelected ? PremiumColors.platinum.opacity(0.15) : Color.listRowBackground(for: scheme)
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // Icon with animated background
                ZStack {
                    // Outer glow when selected
                    Circle()
                        .fill(modeColor.opacity(isSelected ? 0.3 : 0))
                        .frame(width: 56, height: 56)
                        .blur(radius: 8)

                    // Background circle
                    Circle()
                        .fill(
                            isSelected
                                ? LinearGradient(
                                    colors: [modeColor.opacity(0.8), modeColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.listRowBackground(for: scheme), Color.listRowBackground(for: scheme)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? modeColor : Color.secondary.opacity(0.3),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )

                    // Icon
                    Image(systemName: mode.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .secondary)
                        .symbolEffect(.bounce, value: isSelected)
                }

                // Label
                Text(mode.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? modeColor : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? modeColor.opacity(0.5) : Color.clear,
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    NavigationView {
        AppearanceView()
    }
}
