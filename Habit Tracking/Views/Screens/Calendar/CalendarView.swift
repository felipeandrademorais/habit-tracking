import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var dataStore: HabitDataStore
    @State private var currentMonth: Date = Date()

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                headerView
                daysOfWeekView
                daysInMonthView
            }
            .padding(16)
            .habitSoftSurface()

            habitsListView(for: dataStore.selectedDate)
        }
        .padding(AppTheme.screenPadding)
        .habitPageBackground()
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
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.fontSoft)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.blueSoft.opacity(0.7)))
            }

            Spacer()

            VStack(spacing: 2) {
                Text(formattedDate(currentMonth, format: "LLLL").capitalized)
                    .font(AppTheme.headline(17))
                    .foregroundColor(.fontSoft)
                Text(formattedDate(currentMonth, format: "yyyy"))
                    .font(AppTheme.caption(12))
                    .foregroundColor(.fontSoft.opacity(0.55))
            }

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.fontSoft)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.blueSoft.opacity(0.7)))
            }
        }
    }

    private var daysOfWeekView: some View {
        let weekDays = Calendar.current.shortWeekdaySymbols
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(weekDays, id: \.self) { day in
                Text(day.prefix(3).capitalized)
                    .font(AppTheme.micro(11))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.fontSoft.opacity(0.5))
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
                        withAnimation(AppTheme.snappySpring) {
                            dataStore.selectDate(date)
                        }
                    }
                } else {
                    Color.clear
                        .frame(minWidth: 40, minHeight: 40)
                }
            }
        }
    }

    @ViewBuilder
    private func habitsListView(for date: Date) -> some View {
        let habitsForSelectedDate = dataStore.habits(for: date)
        VStack(spacing: 14) {
            Text(formattedDate(date, format: "MMMM d, EEEE").capitalized)
                .font(AppTheme.body(14))
                .foregroundColor(.fontSoft.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)

            if habitsForSelectedDate.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.minus")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.fontSoft.opacity(0.35))
                    Text("Nenhum hábito para essa data")
                        .font(AppTheme.caption(13))
                        .foregroundColor(.fontSoft.opacity(0.55))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .habitSoftSurface(fill: Color.calendarBackground.opacity(0.7))
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.rowSpacing) {
                        ForEach(habitsForSelectedDate, id: \.id) { habit in
                            HabitRowView(
                                habit: habit,
                                selectedDate: date,
                                showCheckbox: false
                            )
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.bottom, 24)
                }
            }

            Spacer(minLength: 0)
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
            withAnimation(AppTheme.softSpring) {
                currentMonth = newMonth
            }
        }
    }

    private func nextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            withAnimation(AppTheme.softSpring) {
                currentMonth = newMonth
            }
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
        CalendarView()
            .environmentObject(HabitDataStore.sampleDataStore)
    }
}
