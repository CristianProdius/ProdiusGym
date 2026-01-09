//
//  CalendarDayView.swift
//  ShadowLift
//
//  Created by Sebastián Kučera on 30.09.2024.
//


import SwiftUI
import Foundation
import SwiftData

struct CalendarDayView: View {
    /// Environment and observed objects
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.modelContext) var context: ModelContext
    @Environment(\.colorScheme) var scheme

    /// Bindings for exercise data
    @State var date: String
    @State var day: Day = Day(name: "", dayOfSplit: 0, exercises: [], date: "")
    @State var muscleGroups:[MuscleGroup] = []

    var body: some View {
        ZStack {
            FloatingClouds(theme: CloudsTheme.graphite(scheme))
                .ignoresSafeArea()
            if muscleGroups.isEmpty {
                /// If there is no recorded day display text
                VStack {
                    Spacer()
                    Text("Workout not recorded for the date")
                        .foregroundStyle(Color.adaptiveSecondaryText(for: scheme))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            /// Else display the day name and all the exercises
            VStack {
                HStack {
                    Text(day.name)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
                List {
                    ForEach(muscleGroups) { group in
                        if !group.exercises.isEmpty {
                            Section(header: Text(group.name)) {
                                ForEach(group.exercises, id: \.id) { exercise in
                                    NavigationLink(destination: CalendarExerciseView(viewModel: WorkoutViewModel(config: config, context: context), exercise: exercise)) {
                                        Text(exercise.name)
                                    }
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .listRowBackground(Color.listRowBackground(for: scheme))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listRowBackground(Color.clear)
                .navigationTitle("\(date)")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    await refreshMuscleGroups()
                }
            }
        }
    }

    func refreshMuscleGroups() async {
        debugPrint("🔍 CalendarDayView: Fetching data for date '\(date)'")
        // OPTIMIZATION: Fetch day data once and reuse it for sorting
        day = await viewModel.fetchCalendarDay(date: date)
        debugPrint("📋 CalendarDayView: Day name: '\(day.name)', exercises count: \(day.exercises?.count ?? 0)")

        // OPTIMIZATION: Sort from already-fetched day data instead of fetching again
        let groups = sortExercisesIntoGroups(day.exercises ?? [])
        muscleGroups = groups
        debugPrint("💪 CalendarDayView: Found \(muscleGroups.count) muscle groups with exercises")
    }

    /// OPTIMIZATION: Sort exercises locally instead of making another database fetch
    private func sortExercisesIntoGroups(_ exercises: [Exercise]) -> [MuscleGroup] {
        var order: [String] = []
        var dict: [String: [Exercise]] = [:]

        for ex in exercises.sorted(by: { $0.exerciseOrder < $1.exerciseOrder }) {
            if dict[ex.muscleGroup] == nil {
                order.append(ex.muscleGroup)
                dict[ex.muscleGroup] = []
            }
            dict[ex.muscleGroup]!.append(ex)
        }

        return order.map { MuscleGroup(name: $0, exercises: dict[$0]!) }
    }
}
