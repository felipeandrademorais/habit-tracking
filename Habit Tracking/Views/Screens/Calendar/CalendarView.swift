import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var dataStore: HabitDataStore
    @State private var currentMonth: Date = Date()

    var body: some View {
        VStack() {
            VStack {
                headerView
                daysOfWeekView
                daysInMonthView
            }
            .padding()
            .background(Color.calendarBackground)
            .cornerRadius(20)

            habitsListView(for: dataStore.selectedDate)
        }
        .padding()
        .background(Color.blueSoft)
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .onAppear {
            syncMonth(to: dataStore.selectedDate)
        }
        .onChange(of: dataStore.selectedDate) { _, newDate in
            syncMonth(to: newDate)
        }
    }
}

// MARK: - Subviews / Computed properties
extension CalendarView {
    private var headerView: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.fontSoft)
            }
            Spacer()
            Text(formattedDate(currentMonth, format: "LLLL"))
                .font(Font.custom("Poppins-Regular", size: 16))
            Spacer()
            Text(formattedDate(currentMonth, format: "yyyy"))
                .font(Font.custom("Poppins-Regular", size: 12))
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.fontSoft)
            }
        }
        .padding()
    }

    private var daysOfWeekView: some View {
        let weekDays = Calendar.current.shortWeekdaySymbols
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(weekDays, id: \.self) { day in
                Text(day.capitalized)
                    .font(Font.custom("Poppins-Thin", size: 12))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black)
            }
        }
    }

    private var daysInMonthView: some View {
        let daysInMonth = generateDaysInMonth(for: currentMonth)
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(daysInMonth.indices, id: \.self) { index in
                if let date = daysInMonth[index] {
                    CalendarDayCell(
                        date: date,
                        isSelected: Calendar.current.isDate(dataStore.selectedDate, inSameDayAs: date)
                    ) {
                        dataStore.selectDate(date)
                    }
                } else {
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    private func habitsListView(for date: Date) -> some View {
        let habitsForSelectedDate = dataStore.habits(for: date)
        VStack(spacing: 20) {
            Text(formattedDate(date, format: "MMMM d, EEEE").capitalized)
                .font(.headline)
                .foregroundColor(.fontSoft)
                .padding(.vertical)

            if habitsForSelectedDate.isEmpty {
                Text("Nenhum Hábito para essa data")
                    .foregroundColor(.fontSoft)
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(habitsForSelectedDate, id: \.id) { habit in
                            HabitRowView(
                                habit: habit,
                                selectedDate: date,
                                showCheckbox: false
                            )
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Funções auxiliares
extension CalendarView {
    private func syncMonth(to date: Date) {
        if !Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month) {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentMonth = date
            }
        }
    }

    private func generateDaysInMonth(for date: Date) -> [Date?] {
        guard
            let range = Calendar.current.range(of: .day, in: .month, for: date),
            let monthStart = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))
        else { return [] }

        let firstDayOfMonthWeekday = Calendar.current.component(.weekday, from: monthStart)
        let emptyDays = Array(repeating: nil as Date?, count: firstDayOfMonthWeekday - 1)

        let days = range.compactMap { day -> Date? in
            Calendar.current.date(byAdding: .day, value: day - 1, to: monthStart)
        }

        return emptyDays + days
    }

    private func previousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func nextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func formattedDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        return CalendarView()
            .environmentObject(HabitDataStore.sampleDataStore)
    }
}
