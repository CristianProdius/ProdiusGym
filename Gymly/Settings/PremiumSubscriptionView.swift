//
//  PremiumSubscriptionView.swift
//  ShadowLift
//
//  Created by Sebastián Kučera on 20.10.2025.
//

import SwiftUI

struct PremiumSubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var config: Config
    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var showTermsOfService = false
    @State private var showPrivacyPolicy = false

    enum SubscriptionPlan {
        case monthly
        case yearly

        var price: String {
            switch self {
            case .monthly: return "2.99€"
            case .yearly: return "29.99€"
            }
        }

        var period: String {
            switch self {
            case .monthly: return "month"
            case .yearly: return "year"
            }
        }

        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Save 17%"
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                FloatingClouds(theme: CloudsTheme.premium(scheme))
                    .ignoresSafeArea()

                if config.isPremium {
                    premiumUserView
                } else {
                    upgradeView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showTermsOfService) {
                LegalDocumentView(documentName: "terms-of-service", title: "Terms of Service")
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                LegalDocumentView(documentName: "privacy-policy", title: "Privacy Policy")
            }
        }
    }

    // MARK: - Premium User View
    private var premiumUserView: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Success Header
                VStack(spacing: 20) {
                    Image(.shadowPremium)
                        .resizable()
                        .frame(width: 300, height: 300)

                    VStack(spacing: 8) {
                        Text("You're Pro!")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Enjoy all features unlocked")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 40)

                // Features List with Checkmarks
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Pro Features")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        PremiumFeatureRow(icon: "trophy.fill", title: "Automatic PR Tracking")
                        PremiumFeatureRow(icon: "camera.fill", title: "Progress Photo Timeline")
                        PremiumFeatureRow(icon: "apple.intelligence", title: "AI Workout Summary")
                        PremiumFeatureRow(icon: "book.fill", title: "Workout Templates")
                        PremiumFeatureRow(icon: "flame.fill", title: "Advanced Streak Analytics")
                        PremiumFeatureRow(icon: "figure.arms.open", title: "BMI Tracking & Analysis")
                        PremiumFeatureRow(icon: "calendar", title: "Unlimited History")
                        PremiumFeatureRow(icon: "paintbrush.fill", title: "Custom App Appearance")
                        PremiumFeatureRow(icon: "chart.bar.fill", title: "Advanced Graph Statistics")
                    }
                    .padding(.horizontal, 24)
                }

                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - Upgrade View
    private var upgradeView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(.shadowPremium)
                        .resizable()
                        .frame(width: 300, height: 300)

                    Text("ShadowLift Pro")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Unlock your full potential")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)

                        // Features List
                        VStack(spacing: 16) {
                            FeatureRow(
                                icon: "trophy.fill",
                                title: "Automatic PR Tracking",
                                description: "Never miss a personal record"
                            )

                            FeatureRow(
                                icon: "camera.fill",
                                title: "Progress Photo Timeline",
                                description: "Track your visual transformation"
                            )

                            FeatureRow(
                                icon: "apple.intelligence",
                                title: "AI Workout Summary",
                                description: "Weekly insights & recommendations \n(iPhones with Apple Inteligence only)"
                            )

                            FeatureRow(
                                icon: "book.fill",
                                title: "Workout Templates",
                                description: "Pre-built programs for your goals"
                            )

                            FeatureRow(
                                icon: "flame.fill",
                                title: "Advanced Streak Analytics",
                                description: "Motivation & predictions"
                            )

                            FeatureRow(
                                icon: "figure.arms.open",
                                title: "BMI Tracking & Analysis",
                                description: "Monitor your body composition"
                            )

                            FeatureRow(
                                icon: "calendar",
                                title: "Unlimited History",
                                description: "Lifetime workout access"
                            )

                            FeatureRow(
                                icon: "paintbrush.fill",
                                title: "Custom App Appearance",
                                description: "Choose your theme & colors"
                            )

                            FeatureRow(
                                icon: "chart.bar.fill",
                                title: "Advanced Graph Statistics",
                                description: "Week, month & all-time filtering"
                            )
                        }
                        .padding(.horizontal, 24)

                        // Pricing Plans
                        VStack(spacing: 12) {
                            Text("Choose Your Plan")
                                .font(.headline)
                                .padding(.top, 20)

                            // Monthly Plan
                            PlanCard(
                                plan: .monthly,
                                isSelected: selectedPlan == .monthly
                            ) {
                                selectedPlan = .monthly
                            }

                            // Yearly Plan
                            PlanCard(
                                plan: .yearly,
                                isSelected: selectedPlan == .yearly
                            ) {
                                selectedPlan = .yearly
                            }
                        }
                        .padding(.horizontal, 24)

                        // CTA Button
                        Button(action: {
                            // TODO: Implement subscription purchase
                            print("Starting subscription: \(selectedPlan)")
                        }) {
                            VStack(spacing: 8) {
                                Text("Start 7-Day Free Trial")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text("Then \(selectedPlan.price)/\(selectedPlan.period)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(appearanceManager.accentColor.color)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                        // Fine Print
                        VStack(spacing: 8) {
                            Text("Cancel anytime. No commitment.")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 16) {
                                Button("Terms of Service") {
                                    showTermsOfService = true
                                }
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                                Button("Privacy Policy") {
                                    showPrivacyPolicy = true
                                }
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                                Button("Restore Purchase") {
                                    // TODO: Restore purchase - requires StoreKit 2 implementation
                                }
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    


// MARK: - Premium Feature Row (Simple checkmark row for premium users)
struct PremiumFeatureRow: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(appearanceManager.accentColor.color.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .foregroundStyle(appearanceManager.accentColor.color)
            }

            Text(title)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(appearanceManager.accentColor.color)
                .font(.title3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(appearanceManager.accentColor.color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Plan Card Component
struct PlanCard: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    let plan: PremiumSubscriptionView.SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.period.capitalized)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let savings = plan.savings {
                            Text(savings)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(6)
                        }
                    }

                    Text("\(plan.price)/\(plan.period)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(appearanceManager.accentColor.color)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? appearanceManager.accentColor.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PremiumSubscriptionView()
}
