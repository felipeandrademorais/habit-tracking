import SwiftUI

class HabitDataStore: ObservableObject {
    @Published var habits: [Habit] = []
    
    private let habitsKey = "habitsKey"

    init() {
        loadHabits()
    }

    func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: habitsKey) else { return }
        do {
            let decoded = try Migration.migrateIfNeeded(data)
            self.habits = decoded
        } catch {
            print("Error decoding habits: \(error)")
        }
    }

    func saveHabits() {
        do {
            let encoded = try JSONEncoder().encode(habits)
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        } catch {
            print("Error encoding habits: \(error)")
        }
    }

    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
        if habit.notificationsEnabled {
            NotificationManager.shared.scheduleNotification(for: habit) { success, error in
                if !success, let errorMessage = error {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ShowNotificationError"),
                        object: nil,
                        userInfo: ["message": errorMessage]
                    )
                } else if success {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ShowNotificationSuccess"),
                        object: nil
                    )
                }
            }
        }
    }

    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].nome = habit.nome
            habits[index].cor = habit.cor
            habits[index].dataInicio = habit.dataInicio
            habits[index].repeticoes = habit.repeticoes
            habits[index].diasDoHabito = habit.diasDoHabito
            habits[index].icon = habit.icon
            habits[index].notificationsEnabled = habit.notificationsEnabled
            habits[index].notificationTime = habit.notificationTime
            if !habit.datesCompleted.isEmpty {
                habits[index].datesCompleted = habit.datesCompleted
            }

            saveHabits()
            if habit.notificationsEnabled {
                NotificationManager.shared.scheduleNotification(for: habit) { success, error in
                    if !success, let errorMessage = error {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("ShowNotificationError"),
                            object: nil,
                            userInfo: ["message": errorMessage]
                        )
                    } else if success {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("ShowNotificationSuccess"),
                            object: nil
                        )
                    }
                }
            } else {
                NotificationManager.shared.removeNotifications(for: habit)
            }
        }
    }
    
    func habits(for date: Date) -> [Habit] {
        let startOfSelectedDate = Calendar.current.startOfDay(for: date)
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)

        return habits.filter { habit in
            let startOfHabitDate = calendar.startOfDay(for: habit.dataInicio)

            switch habit.repeticoes {
            case .daily:
                return startOfHabitDate <= startOfSelectedDate

            case .weekly:
                return startOfHabitDate <= startOfSelectedDate && habit.diasDoHabito.contains(weekday)

            case .monthly:
                let startDay = calendar.component(.day, from: startOfHabitDate)
                let selectedDay = calendar.component(.day, from: startOfSelectedDate)
                return startOfHabitDate <= startOfSelectedDate && startDay == selectedDay
            }
        }
        .sorted { $0.datesCompleted.isEmpty && !$1.datesCompleted.isEmpty }
    }

    func removeHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
        NotificationManager.shared.removeNotifications(for: habit)
    }
    
    func debugClearAllData() {
        UserDefaults.standard.removeObject(forKey: habitsKey)
        self.habits = []
    }
    
    func createdHabitsCount() -> Int {
        return habits.count
    }

    func completedHabitsCount() -> Int {
        return habits.filter { !$0.datesCompleted.isEmpty }.count
    }
    
    /// Completion ratio for habits scheduled on `date` (0...1).
    /// Example: 2 of 10 completed → `0.2`.
    func getCompletionRateForDate(_ date: Date) -> Double {
        let activeHabits = habits(for: date)
        let totalHabits = activeHabits.count
        guard totalHabits > 0 else { return 0 }

        let completedHabits = activeHabits.filter { $0.isCompleted(on: date) }.count
        return Double(completedHabits) / Double(totalHabits)
    }
}

extension HabitDataStore {
    static var sampleDataStore: HabitDataStore {
        let store = HabitDataStore()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startOfYear = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: today),
            month: 1,
            day: 1
        )) ?? today

        var partialCompletions: [Date] = []
        var fullCompletions: [Date] = []
        for offset in 0..<40 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today),
                  date >= startOfYear else { continue }
            if offset % 3 == 0 {
                fullCompletions.append(date)
            }
            if offset % 2 == 0 {
                partialCompletions.append(date)
            }
        }

        store.habits = [
            Habit(
                nome: "Read",
                cor: "color1",
                dataInicio: startOfYear,
                repeticoes: .daily,
                datesCompleted: partialCompletions,
                icon: "⭐️"
            ),
            Habit(
                nome: "Exercise",
                cor: "color2",
                dataInicio: startOfYear,
                repeticoes: .daily,
                datesCompleted: fullCompletions,
                icon: "🔥"
            )
        ]
        return store
    }
}
