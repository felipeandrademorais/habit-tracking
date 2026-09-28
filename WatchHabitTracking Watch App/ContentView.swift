//
//  ContentView.swift
//  WatchHabitTracking Watch App
//
//  Created by Felipe Morais on 23/01/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = HabitDataStore()
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
                        HStack {
                            Text(habit.icon)
                                .font(.title3)

                            Text(habit.nome)
                                .font(.system(.body, design: .rounded))
                                .strikethrough(habit.isCompleted(on: currentDate), color: .secondary)

                            Spacer()

                            Button {
                                toggleCompletion(habit)
                            } label: {
                                Image(systemName: habit.isCompleted(on: currentDate)
                                      ? "checkmark.circle.fill"
                                      : "circle")
                                    .font(.title3)
                            }
                            .buttonStyle(.glass)
                            .tint(habit.isCompleted(on: currentDate)
                                  ? .green
                                  : Color(red: 0.67, green: 0.34, blue: 0.72))
                            .buttonBorderShape(.circle)
                        }
                        .padding(.vertical, 2)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(habit.cor).opacity(habit.isCompleted(on: currentDate) ? 0.25 : 0.75))
                        )
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

    private func toggleCompletion(_ habit: Habit) {
        var updatedHabit = habit
        let day = Calendar.current.startOfDay(for: currentDate)

        if habit.isCompleted(on: currentDate) {
            updatedHabit.datesCompleted.removeAll {
                Calendar.current.startOfDay(for: $0) == day
            }
        } else {
            updatedHabit.datesCompleted.append(day)
        }

        dataStore.updateHabit(updatedHabit)
    }
}

#Preview {
    ContentView()
}
