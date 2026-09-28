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
            Color.color1
                .opacity(0.6)
                .ignoresSafeArea(.all)

            VStack(spacing: 8) {
                Text(monthName(for: currentWeekStart))
                    .font(Font.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.fontSoft)

                HStack(spacing: 8) {
                    ForEach(weekDays, id: \.self) { day in
                        VStack(spacing: 6) {
                            Text(shortWeekdayName(for: day))
                                .font(Font.custom("Poppins-Medium", size: 12))
                                .foregroundColor(.fontSoft)
                                .fontWeight(isSelected(day) ? .bold : .regular)
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 32, height: 32)

                                Text(dayNumber(for: day))
                                    .font(Font.custom("Poppins-Medium", size: 12))
                                    .foregroundColor(.black)
                                    .fontWeight(isSelected(day) ? .bold : .regular)
                            }
                        }
                        .padding(8)
                        .background {
                            if isSelected(day) {
                                Color.clear
                                    .habitGlassChip(tint: LiquidGlassStyle.primaryCapsuleTint)
                            } else {
                                RoundedRectangle(cornerRadius: LiquidGlassStyle.cardCornerRadius)
                                    .fill(Color.capsuleSecundary)
                            }
                        }
                        .onTapGesture {
                            selectedDate = calendar.startOfDay(for: day)
                        }
                    }
                }
            }
            .padding()
            .cornerRadius(12)
            .offset(x: slideOffset)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: slideOffset)
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
                            withAnimation {
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

    private func shiftWeek(by value: Int) {
        guard let newWeekStart = calendar.date(byAdding: .weekOfYear, value: value, to: currentWeekStart) else {
            withAnimation { slideOffset = 0 }
            return
        }

        let weekday = calendar.component(.weekday, from: selectedDate)
        withAnimation {
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
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
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
