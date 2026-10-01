import SwiftUI

struct YearCalendarView: View {
    var habitDataStore: HabitDataStore

    private let cellSize: CGFloat = 10
    private let cellSpacing: CGFloat = 4
    private let rows = Array(repeating: GridItem(.fixed(10), spacing: 4), count: 7)
    private let weekdayLabels = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]

    var body: some View {
        VStack(spacing: 12) {
            Text("Atividade Anual")
                .font(AppTheme.headline(16))
                .foregroundColor(.fontSoft)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .top, spacing: cellSpacing) {
                VStack(spacing: cellSpacing) {
                    ForEach(weekdayLabels, id: \.self) { day in
                        Text(day)
                            .font(AppTheme.micro(8))
                            .foregroundColor(.fontSoft.opacity(0.55))
                            .frame(width: 30, height: cellSize, alignment: .trailing)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 4) {
                        monthLabelsRow

                        LazyHGrid(rows: rows, spacing: cellSpacing) {
                            ForEach(yearGridCells) { cell in
                                dayCell(for: cell)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Cells

    /// Continuous Sunday-start grid covering every day of the current year (with leading/trailing pads).
    private var yearGridCells: [YearDayCell] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())

        guard
            let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
            let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))
        else {
            return []
        }

        // Match Dom…Sáb labels: weekday 1 = Sunday.
        let jan1Weekday = calendar.component(.weekday, from: startOfYear)
        let leadingEmpty = jan1Weekday - 1

        var cells: [YearDayCell] = []
        var index = 0

        for _ in 0..<leadingEmpty {
            cells.append(YearDayCell(id: index, date: nil))
            index += 1
        }

        var cursor = startOfYear
        while cursor <= endOfYear {
            cells.append(YearDayCell(id: index, date: cursor))
            index += 1
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }

        while cells.count % 7 != 0 {
            cells.append(YearDayCell(id: index, date: nil))
            index += 1
        }

        return cells
    }

    private var monthLabelsRow: some View {
        let labels = monthLabelOffsets
        return HStack(spacing: 0) {
            ForEach(labels, id: \.weekIndex) { item in
                Text(item.title)
                    .font(AppTheme.micro(9))
                    .foregroundColor(.fontSoft.opacity(0.55))
                    .frame(
                        width: CGFloat(item.widthInWeeks) * (cellSize + cellSpacing) - cellSpacing,
                        alignment: .leading
                    )
            }
        }
        .padding(.leading, 0)
    }

    /// Month abbreviations as contiguous week spans across the horizontal grid.
    private var monthLabelOffsets: [(weekIndex: Int, title: String, widthInWeeks: Int)] {
        let calendar = Calendar.current
        let cells = yearGridCells
        let weekCount = max(cells.count / 7, 1)

        var firstWeekForMonth: [Int: Int] = [:]
        for (index, cell) in cells.enumerated() {
            guard let date = cell.date else { continue }
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            if day == 1 {
                firstWeekForMonth[month] = index / 7
            }
        }

        let formatter = DateFormatter()
        formatter.locale = Locale.current

        let starts: [(month: Int, week: Int)] = (1...12).compactMap { month in
            guard let week = firstWeekForMonth[month] else { return nil }
            return (month, week)
        }

        var result: [(weekIndex: Int, title: String, widthInWeeks: Int)] = []
        var cursor = 0

        for (index, item) in starts.enumerated() {
            if item.week > cursor {
                result.append((weekIndex: cursor, title: "", widthInWeeks: item.week - cursor))
            }

            let nextWeek = index + 1 < starts.count ? starts[index + 1].week : weekCount
            let title = formatter.shortMonthSymbols[item.month - 1].capitalized
            result.append((
                weekIndex: item.week,
                title: title,
                widthInWeeks: max(nextWeek - item.week, 1)
            ))
            cursor = nextWeek
        }

        return result
    }

    @ViewBuilder
    private func dayCell(for cell: YearDayCell) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color(for: cell.date))
            .frame(width: cellSize, height: cellSize)
    }

    /// Opacity equals completion rate for that day (e.g. 2/10 → 20%).
    private func color(for date: Date?) -> Color {
        guard let date else {
            return .clear
        }

        let scheduled = habitDataStore.habits(for: date)
        guard !scheduled.isEmpty else {
            return Color.gray.opacity(0.12)
        }

        let completed = scheduled.filter { $0.isCompleted(on: date) }.count
        let rate = Double(completed) / Double(scheduled.count)

        if rate <= 0 {
            return Color.gray.opacity(0.12)
        }

        return Color.defaultDark.opacity(rate)
    }
}

private struct YearDayCell: Identifiable {
    let id: Int
    let date: Date?
}

#Preview {
    YearCalendarView(habitDataStore: HabitDataStore.sampleDataStore)
        .padding()
        .background(Color.color1)
}
