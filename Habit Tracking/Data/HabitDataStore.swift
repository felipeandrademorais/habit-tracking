import SwiftUI

class HabitDataStore: ObservableObject {
    @Published var habits: [Habit] = []
    /// Shared selection used by the month calendar and the habits week strip.
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    
    private let habitsKey = "habitsKey"

    init() {
        loadHabits()
    }

    func selectDate(_ date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        guard !Calendar.current.isDate(selectedDate, inSameDayAs: day) else { return }
        selectedDate = day
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

    func totalCompletionsCount() -> Int {
        habits.reduce(0) { $0 + $1.datesCompleted.count }
    }

    func distinctColorsCount() -> Int {
        Set(habits.map(\.cor)).count
    }

    func completions(on date: Date) -> Int {
        habits.reduce(0) { partial, habit in
            partial + (habit.isCompleted(on: date) ? 1 : 0)
        }
    }

    /// Consecutive days ending today (or yesterday if today is still empty) with ≥1 check-in.
    func activityStreakDays() -> Int {
        let calendar = Calendar.current
        var day = calendar.startOfDay(for: Date())
        var streak = 0

        if completions(on: day) == 0 {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }

        while completions(on: day) > 0 {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }

        return streak
    }

    /// Days where every scheduled habit was completed.
    func perfectDaysCount() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let earliest = habits.map({ calendar.startOfDay(for: $0.dataInicio) }).min() else {
            return 0
        }

        var count = 0
        var day = earliest
        while day <= today {
            let scheduled = habits(for: day)
            if !scheduled.isEmpty && scheduled.allSatisfy({ $0.isCompleted(on: day) }) {
                count += 1
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return count
    }

    /// True when the user has completed habits on both a Saturday and a Sunday.
    func hasWeekendWarriorCompletions() -> Bool {
        let calendar = Calendar.current
        var hasSaturday = false
        var hasSunday = false

        for habit in habits {
            for date in habit.datesCompleted {
                switch calendar.component(.weekday, from: date) {
                case 1: hasSunday = true
                case 7: hasSaturday = true
                default: break
                }
                if hasSaturday && hasSunday { return true }
            }
        }

        return false
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
