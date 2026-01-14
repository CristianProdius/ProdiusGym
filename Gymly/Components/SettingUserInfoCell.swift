//
//  SettingUserInfoCell.swift
//  ProdiusGym
//
//  Created by Sebastián Kučera on 25.03.2025.
//

import SwiftUI
import SwiftData

struct SettingUserInfoCell: View {
    @Environment(\.modelContext) var context
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject var config: Config
    @EnvironmentObject var userProfileManager: UserProfileManager

    @State var value: String = "20"
    @State var metric: String = "Kg"
    @State var headerColor: Color = .green
    @State var additionalInfo: String = "Normal Weight"
    @State var icon: String = "figure.run"
    @State var compareWeight: Double? = nil
    @State var compareText: String = ""
    @State private var hasLoadedWeightData = false
    @State private var isPressed = false

    /// Computed weight change for display
    private var weightChange: Double? {
        guard (metric == "Kg" || metric == "Lbs"),
              let compareWt = compareWeight, compareWt > 0, !compareText.isEmpty else {
            return nil
        }
        let conversionFactor = userProfileManager.currentProfile?.weightUnit ?? "Kg" == "Kg" ? 1.0 : 2.20462
        let currentWeight = Double(value) ?? 0.0
        let compareConverted = compareWt * conversionFactor
        return currentWeight - compareConverted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Top row: Icon badge + Label
            HStack(spacing: 8) {
                // Icon in circular badge
                ZStack {
                    Circle()
                        .fill(headerColor.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Circle()
                        .stroke(headerColor.opacity(0.3), lineWidth: 1)
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(headerColor)
                }

                Text(additionalInfo)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()
            }

            Spacer()

            // Change indicator (for weight) - positioned ABOVE the value
            if let change = weightChange {
                HStack(spacing: 4) {
                    Image(systemName: change > 0.1 ? "arrow.up.right" : (change < -0.1 ? "arrow.down.right" : "minus"))
                        .font(.system(size: 9, weight: .semibold))

                    Text("\(String(format: "%.1f", abs(change))) \(compareText)")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(change > 0.1 ? .orange : (change < -0.1 ? .green : .secondary))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill((change > 0.1 ? Color.orange : (change < -0.1 ? Color.green : Color.secondary)).opacity(0.1))
                )
            }

            // Main value - Hero typography (always at bottom)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .foregroundStyle(.primary)

                Text(metric)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(width: 160, height: 130)
        .background(
            ZStack {
                // Frosted glass effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)

                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                headerColor.opacity(scheme == .dark ? 0.08 : 0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                headerColor.opacity(0.3),
                                headerColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: headerColor.opacity(0.15), radius: 12, x: 0, y: 6)
        .shadow(color: Color.black.opacity(scheme == .dark ? 0.3 : 0.08), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear() {
            guard (metric == "Kg" || metric == "Lbs") && !hasLoadedWeightData else { return }
            hasLoadedWeightData = true
            getWeightComparison()
        }
    }

    func getWeightComparison() {
        let now = Date()
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: now)!

        let descriptor = FetchDescriptor<WeightPoint>(
            predicate: #Predicate { point in
                point.date >= tenDaysAgo && point.date <= now
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            let recentPoints = try context.fetch(descriptor)

            if !recentPoints.isEmpty {
                let targetDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                let closestTo7Days = recentPoints.min(by: {
                    abs($0.date.timeIntervalSince(targetDate)) < abs($1.date.timeIntervalSince(targetDate))
                })

                if let point = closestTo7Days {
                    let daysDiff = abs(Calendar.current.dateComponents([.day], from: point.date, to: targetDate).day ?? 0)

                    if daysDiff <= 3 {
                        self.compareWeight = point.weight
                        self.compareText = "vs last week"
                        return
                    }
                }
            }

            let allDescriptor = FetchDescriptor<WeightPoint>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )

            let allPoints = try context.fetch(allDescriptor)

            guard allPoints.count >= 2 else { return }

            let secondLastWeight = allPoints[1].weight
            self.compareWeight = secondLastWeight
            self.compareText = "vs last time"

        } catch {
            debugLog("❌ SettingUserInfoCell: Error fetching weight points: \(error)")
        }
    }
}

#Preview {
    SettingUserInfoCell()
}
