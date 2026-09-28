import SwiftUI

struct WatchHabitRowView: View {
    @EnvironmentObject var dataStore: HabitDataStore
    let habit: Habit
    let selectedDate: Date

    var body: some View {
        HStack {
            Text(habit.icon)
                .font(.title3)
                .padding(.trailing, 4)

            VStack(alignment: .leading) {
                Text(habit.nome)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(isCompletedOnSelectedDate ? .secondary : .primary)
                    .strikethrough(isCompletedOnSelectedDate, color: .secondary)
            }

            Spacer()

            Button(action: { toggleCompletion(habit) }) {
                Image(systemName: isCompletedOnSelectedDate
                        ? "checkmark.circle.fill"
                        : "circle")
                    .font(.title3)
            }
            .buttonStyle(.glass)
            .tint(isCompletedOnSelectedDate ? .green : Color(red: 0.67, green: 0.34, blue: 0.72))
            .buttonBorderShape(.circle)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        // Pastel content fill — identity stays in the content layer, not glass-on-glass.
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    Color(habit.cor).opacity(isCompletedOnSelectedDate ? 0.25 : 0.75)
                )
        )
    }

    private var isCompletedOnSelectedDate: Bool {
        habit.isCompleted(on: selectedDate)
    }

    private func toggleCompletion(_ habit: Habit) {
        var updatedHabit = habit
        let day = Calendar.current.startOfDay(for: selectedDate)

        if isCompletedOnSelectedDate {
            updatedHabit.datesCompleted.removeAll {
                Calendar.current.startOfDay(for: $0) == day
            }
        } else {
            updatedHabit.datesCompleted.append(day)
        }

        dataStore.updateHabit(updatedHabit)
    }
}

struct WatchHabitRowView_Previews: PreviewProvider {
    static var previews: some View {
        let dataStore = HabitDataStore.sampleDataStore
        let habitExample = dataStore.habits.first!

        return WatchHabitRowView(
            habit: habitExample,
            selectedDate: Date()
        )
        .environmentObject(dataStore)
        .previewLayout(.sizeThatFits)
    }
}
