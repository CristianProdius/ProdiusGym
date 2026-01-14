//
//  CalendarView.swift
//  ProdiusGym
//
//  Created by Sebastián Kučera on 30.08.2024.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var currentMonth = Date()
    @EnvironmentObject var config: Config
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var appearanceManager: AppearanceManager
    let calendar = Calendar.current
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // MARK: - Performance Optimization: Cache today's date string and recorded days set
    @State private var todayDateString: String = ""
    @State private var recordedDaysSet: Set<String> = []

    var body: some View {
        NavigationView {
            ZStack {
                FloatingClouds(theme: CloudsTheme.graphite(scheme))
                    .ignoresSafeArea()
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            HStack {
                                Button(action: {
                                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                                }) {
                                    Image(systemName: "chevron.left")
                                        .bold()
                                        .foregroundStyle(PremiumColors.gold)
                                }
                                .accessibilityLabel("Previous month")
                                .accessibilityHint("Double tap to view the previous month")
                                Spacer()
                                Text(viewModel.monthAndYearString(from: currentMonth))
                                    .font(.title)
                                    .accessibilityLabel("Current month: \(viewModel.monthAndYearString(from: currentMonth))")
                                Spacer()
                                Button(action: {
                                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                                }) {
                                    Image(systemName: "chevron.right")
                                        .bold()
                                        .foregroundStyle(PremiumColors.gold)
                                }
                                .accessibilityLabel("Next month")
                                .accessibilityHint("Double tap to view the next month")
                            }
                            .padding()

                        VStack {
                            HStack {
                                ForEach(daysOfWeek, id: \.self) { day in
                                    Spacer()
                                    Text(day)
                                        .frame(width: geometry.size.width * 0.085)
                                        .bold()
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                            .padding(5)
                            .background(PremiumColors.gold)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(PremiumColors.gold, lineWidth: 4)
                            )
                            .padding(.bottom, 10)

                            let daysInMonth = viewModel.getDaysInMonth(for: currentMonth)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                ForEach(daysInMonth.indices, id: \.self) { index in
                                    let day = daysInMonth[index]

                                    if day.day != 0 {
                                        let dayDateString = viewModel.formattedDateString(from: day.date)
                                        // Use cached Set for O(1) lookup - no database queries per day
                                        let hasWorkout = recordedDaysSet.contains(dayDateString)
                                        // Use cached todayDateString instead of recomputing
                                        if dayDateString == todayDateString {
                                            NavigationLink("\(day.day)") {
                                                CalendarDayView(viewModel: viewModel, date: dayDateString)
                                            }
                                            .frame(width: geometry.size.width * 0.085, height: geometry.size.width * 0.085)
                                            .font(.title3)
                                            .foregroundColor(Color.white)
                                            .padding(.horizontal, 3)
                                            .padding(.vertical, 2)
                                            .background(PremiumColors.gold)
                                            .cornerRadius(25)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .stroke(PremiumColors.gold, lineWidth: 4)
                                            )
                                            .fontWeight(.bold)
                                            .padding(3)
                                            .accessibilityLabel("Today, \(day.day)\(hasWorkout ? ", workout recorded" : "")")
                                            .accessibilityHint("Double tap to view workout details")
                                        } else {
                                            ZStack {
                                                // dayDateString already computed above - no duplicate needed

                                                NavigationLink("\(day.day)") {
                                                    CalendarDayView(viewModel: viewModel, date: dayDateString)
                                                }
                                                .frame(width: geometry.size.width * 0.085, height: geometry.size.width * 0.085)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.primary)
                                                .padding(3)
                                                .accessibilityLabel("Day \(day.day)\(hasWorkout ? ", workout recorded" : "")")
                                                .accessibilityHint("Double tap to view workout details")

                                                // Use cached Set for O(1) lookup instead of O(n) array contains
                                                if hasWorkout {
                                                    Circle()
                                                        .frame(width: 10, height: 10)
                                                        .foregroundColor(PremiumColors.gold)
                                                        .offset(x: 0, y: 20)
                                                        .accessibilityHidden(true)
                                                }
                                            }
                                        }
                                    } else {
                                        /// Empty day so the calendar is alligned right
                                        Text("")
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 6)
                                    }
                                }
                            }
                            .padding(2)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .listRowBackground(Color.listRowBackground(for: scheme))

                            // Progress Photos Timeline
                            if config.isPremium {
                                ProgressPhotoTimelineView()
                                    .frame(minHeight: 400)
                            } else {
                                ProgressPhotosLockedView()
                                    .frame(minHeight: 400)
                            }
                        }
                        .frame(maxWidth: geometry.size.width * 0.92)
                        }
                    }
                    .navigationTitle("Calendar")
                    .onAppear() {
                        currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? currentMonth
                        // Clean up any duplicate dates in the daysRecorded array
                        viewModel.cleanupDuplicateDates()

                        // Initialize cached values for performance
                        todayDateString = viewModel.formattedDateString(from: Date())
                        // Merge config.daysRecorded with all DayStorage dates for complete coverage
                        let storageDates = viewModel.getAllWorkoutDates()
                        recordedDaysSet = Set(config.daysRecorded).union(storageDates)
                    }
                    .onChange(of: config.daysRecorded) { _, newValue in
                        // Update cached Set when daysRecorded changes
                        recordedDaysSet = Set(newValue)
                    }
                }
            }
        }
    }
}

struct DayCalendar: Hashable {
    var id = UUID()
    let day: Int
    let date: Date
}

