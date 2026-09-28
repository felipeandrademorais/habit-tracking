//
//  WatchHabitsTodayView.swift
//  Habit Tracking
//
//  Created by Felipe Morais on 23/01/25.
//

import SwiftUI

struct WatchHabitsTodayView: View {
    @EnvironmentObject var dataStore: HabitDataStore
    private let currentDate = Date()

    var body: some View {
        NavigationStack {
            Group {
                if todaysHabits.isEmpty {
                    ContentUnavailableView(
                        "Nenhum hábito para hoje.",
                        systemImage: "checklist",
                        description: Text("Os hábitos do iPhone aparecem aqui.")
                    )
                } else {
                    List(todaysHabits) { habit in
                        WatchHabitRowView(
                            habit: habit,
                            selectedDate: currentDate
                        )
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.carousel)
                    .scrollEdgeEffectStyle(.soft, for: .bottom)
                }
            }
            .navigationTitle("Hoje")
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var todaysHabits: [Habit] {
        dataStore.habits(for: currentDate)
    }
}

struct WatchHabitsTodayView_Previews: PreviewProvider {
    static var previews: some View {
        let dataStore = HabitDataStore.sampleDataStore
        return WatchHabitsTodayView()
            .environmentObject(dataStore)
    }
}
