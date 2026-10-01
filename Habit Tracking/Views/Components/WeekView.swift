import SwiftUI

struct WeekView: View {
    @Binding var selectedDate: Date

    private let calendar = Calendar.current

    @State private var currentWeekStart: Date
    @State private var slideOffset: CGFloat = 0
    @State private var isAnimating: Bool = false

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        let calendar = Calendar.current
        let anchor = selectedDate.wrappedValue
        if let weekStart = calendar.dateInterval(of: .weekOfYear, for: anchor)?.start {
            _currentWeekStart = State(initialValue: weekStart)
        } else {
            _currentWeekStart = State(initialValue: calendar.startOfDay(for: anchor))
        }
    }

    var weekDays: [Date] {
        (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: currentWeekStart)
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.habitsHeaderGradient
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 10) {
                Text(monthName(for: currentWeekStart))
                    .font(AppTheme.body(13))
                    .foregroundColor(.fontSoft.opacity(0.75))
                    .tracking(0.6)
                    .textCase(.uppercase)

                HStack(spacing: 6) {
                    ForEach(weekDays, id: \.self) { day in
                        dayChip(for: day)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .offset(x: slideOffset)
            .animation(AppTheme.softSpring, value: slideOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isAnimating {
                            slideOffset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        isAnimating = true

                        if value.translation.width > threshold {
                            slideOffset = 300
                            shiftWeek(by: -1)
                        } else if value.translation.width < -threshold {
                            slideOffset = -300
                            shiftWeek(by: 1)
                        } else {
                            withAnimation(AppTheme.softSpring) {
                                slideOffset = 0
                            }
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isAnimating = false
                        }
                    }
            )
        }
        .onAppear {
            syncWeek(to: selectedDate)
        }
        .onChange(of: selectedDate) { _, newDate in
            syncWeek(to: newDate)
        }
    }

    @ViewBuilder
    private func dayChip(for day: Date) -> some View {
        let selected = isSelected(day)
        let today = calendar.isDateInToday(day)

        VStack(spacing: 6) {
            Text(shortWeekdayName(for: day))
                .font(AppTheme.micro(11))
                .foregroundColor(selected ? .fontSoft : .fontSoft.opacity(0.55))
                .fontWeight(selected ? .semibold : .regular)

            ZStack {
                if today && !selected {
                    Circle()
                        .stroke(LiquidGlassStyle.brandTint.opacity(0.45), lineWidth: 1.5)
                        .frame(width: 32, height: 32)
                }

                Circle()
                    .fill(selected ? Color.white.opacity(0.95) : Color.white.opacity(0.55))
                    .frame(width: 32, height: 32)

                Text(dayNumber(for: day))
                    .font(AppTheme.body(12))
                    .foregroundColor(.fontSoft)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity)
        .background {
            if selected {
                Color.clear
                    .habitGlassChip(tint: LiquidGlassStyle.primaryCapsuleTint)
            } else {
                RoundedRectangle(cornerRadius: AppTheme.chipCornerRadius, style: .continuous)
                    .fill(Color.capsuleSecundary.opacity(0.55))
            }
        }
        .scaleEffect(selected ? 1.04 : 1)
        .animation(AppTheme.snappySpring, value: selected)
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation(AppTheme.snappySpring) {
                selectedDate = calendar.startOfDay(for: day)
            }
        }
    }

    private func shiftWeek(by value: Int) {
        guard let newWeekStart = calendar.date(byAdding: .weekOfYear, value: value, to: currentWeekStart) else {
            withAnimation { slideOffset = 0 }
            return
        }

        let weekday = calendar.component(.weekday, from: selectedDate)
        withAnimation(AppTheme.softSpring) {
            currentWeekStart = newWeekStart
            slideOffset = 0
            if let matchingDay = (0..<7).compactMap({
                calendar.date(byAdding: .day, value: $0, to: newWeekStart)
            }).first(where: {
                calendar.component(.weekday, from: $0) == weekday
            }) {
                selectedDate = calendar.startOfDay(for: matchingDay)
            }
        }
    }

    private func syncWeek(to date: Date) {
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start else { return }
        if !calendar.isDate(weekStart, inSameDayAs: currentWeekStart) {
            withAnimation(AppTheme.softSpring) {
                currentWeekStart = weekStart
            }
        }
    }

    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(selectedDate, inSameDayAs: date)
    }

    func shortWeekdayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "E"
        return formatter.string(from: date).prefix(3).capitalized
    }

    func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    func monthName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date).capitalized
    }
}

struct WeekView_Previews: PreviewProvider {
    @State static var selectedDate = Date()

    static var previews: some View {
        WeekView(selectedDate: $selectedDate)
            .previewLayout(.sizeThatFits)
    }
}
