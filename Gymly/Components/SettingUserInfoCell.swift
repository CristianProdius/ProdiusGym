//
//  SettingUserInfoCell.swift
//  ShadowLift
//
//  Created by Sebastián Kučera on 25.03.2025.
//

import SwiftUI
import SwiftData

struct SettingUserInfoCell: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject var config: Config
    @EnvironmentObject var userProfileManager: UserProfileManager

    @State var value: String = "20"
    @State var metric: String = "Kg"
    @State var headerColor: Color = .green
    @State var additionalInfo: String = "Normal Weight"
    @State var icon: String = "figure.run"
    @State var compareWeight: Double? = nil  // Weight to compare against
    @State var compareText: String = ""  // Text to display (e.g., "last week" or "last weigh-in")
    @State private var hasLoadedWeightData = false  // Prevent multiple loads

    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack {
                    Rectangle()
                        .fill(headerColor)
                        .frame(height: geo.size.height * 0.4) // 30% of HStack height
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.2) // center it vertically
                    Text(additionalInfo)
                         .foregroundColor(.black)
                         .bold()
                         .position(x: geo.size.width / 2, y: geo.size.height * 0.2)
                    HStack {
                        VStack {
                            HStack {
                                Text("\(value) \(metric)")
                                    .bold()
                                Image(systemName: icon)
                            }
                            // Show weight change
                            if (metric == "Kg" || metric == "Lbs"), let compareWt = compareWeight, compareWt > 0, !compareText.isEmpty {
                                let conversionFactor = userProfileManager.currentProfile?.weightUnit ?? "Kg" == "Kg" ? 1.0 : 2.20462
                                let currentWeight = Double(value) ?? 0.0
                                let compareConverted = compareWt * conversionFactor
                                let change = currentWeight - compareConverted

                                HStack(spacing: 3) {
                                    if change > 0.1 {
                                       Image(systemName: "arrow.up")
                                    } else if change < -0.1 {
                                        Image(systemName: "arrow.down")
                                    } else {
                                        Image(systemName: "minus")
                                    }
                                    Text("\(String(format: "%.1f", abs(change))) \(metric) \(compareText)")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 65)

                }
                .background(Color.black.opacity(0.2))
            }
        }
        .onAppear() {
            // Only fetch last week's weight if this is a weight cell and we haven't loaded yet
            guard (metric == "Kg" || metric == "Lbs") && !hasLoadedWeightData else { return }
            hasLoadedWeightData = true

            getWeightComparison()
        }
        .frame(width: 160, height: 120)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    func getWeightComparison() {
        // Get recent weight points from database (last 10 days)
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

            print("📊 SettingUserInfoCell: Found \(recentPoints.count) weight entries in last 10 days")

            if !recentPoints.isEmpty {
                // Try to find weight from ~7 days ago (with 3 day tolerance)
                let targetDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                let closestTo7Days = recentPoints.min(by: {
                    abs($0.date.timeIntervalSince(targetDate)) < abs($1.date.timeIntervalSince(targetDate))
                })

                if let point = closestTo7Days {
                    let daysDiff = abs(Calendar.current.dateComponents([.day], from: point.date, to: targetDate).day ?? 0)

                    // If within 3 days of 7 days ago, use "vs last week"
                    if daysDiff <= 3 {
                        self.compareWeight = point.weight
                        self.compareText = "vs last week"
                        print("✅ SettingUserInfoCell: Using last week weight: \(point.weight)kg (from \(daysDiff) days ago)")
                        return
                    }
                }
            }

            // No weight from last week, get last 2 weights from all history
            let allDescriptor = FetchDescriptor<WeightPoint>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )

            let allPoints = try context.fetch(allDescriptor)

            print("📊 SettingUserInfoCell: Found \(allPoints.count) total weight entries in database")

            guard allPoints.count >= 2 else {
                print("⚠️ SettingUserInfoCell: Not enough weight data (need at least 2 entries)")
                return
            }

            // Compare last weight to 2nd last weight
            let secondLastWeight = allPoints[1].weight

            self.compareWeight = secondLastWeight
            self.compareText = "vs last time"

            print("✅ SettingUserInfoCell: Comparing to 2nd last weight: \(secondLastWeight)kg")

        } catch {
            print("❌ SettingUserInfoCell: Error fetching weight points: \(error)")
        }
    }
}

#Preview {
    SettingUserInfoCell()
}
