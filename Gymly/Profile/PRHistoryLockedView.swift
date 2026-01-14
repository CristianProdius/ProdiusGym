//
//  PRHistoryLockedView.swift
//  Gymly
//
//  Created by Claude Code on 27.11.2025.
//

import SwiftUI

struct PRHistoryLockedView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var showPremiumView = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Personal Records")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
            }
            .padding()
            .background(Color.black.opacity(0.05))

            // Locked Content
            VStack(spacing: 24) {
                Spacer()

                // Lock Icon
                ZStack {
                    Circle()
                        .fill(PremiumColors.gold.opacity(0.2))
                        .frame(width: 100, height: 100)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(PremiumColors.gold)
                }

                // Title
                Text("PR Tracking")
                    .font(.title2)
                    .bold()

                // Description
                Text("Track every personal record, analyze your strength gains, and celebrate your progress with detailed PR history.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    FeatureCheckmark(text: "Track all personal records")
                    FeatureCheckmark(text: "Weight, volume & 1RM PRs")
                    FeatureCheckmark(text: "PR history & trends")
                    FeatureCheckmark(text: "Muscle group filtering")
                    FeatureCheckmark(text: "Detailed PR analytics")
                }
                .padding(.horizontal, 40)
                .padding(.top, 12)

                // Upgrade Button
                Button(action: {
                    showPremiumView = true
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Upgrade to Pro")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(PremiumColors.gold)
                    .foregroundColor(.black)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.top, 24)

                Spacer()
            }
            .padding(.vertical, 40)
        }
        .background(Color.clear)
        .sheet(isPresented: $showPremiumView) {
            PremiumSubscriptionView()
        }
    }
}

#Preview {
    PRHistoryLockedView()
        .environmentObject(AppearanceManager())
}
