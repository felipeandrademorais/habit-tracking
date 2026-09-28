import SwiftUI

struct WeekView: View {
    let calendar = Calendar.current
    let today = Date()
    let onDaySelected: (Date) -> Void    

    @State private var selectedDate: Date?
    @State private var currentWeekStart: Date
    
    init(onDaySelected: @escaping (Date) -> Void) {
        self.onDaySelected = onDaySelected
        let calendar = Calendar.current
        if let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start {
            _currentWeekStart = State(initialValue: weekStart)
        } else {
            _currentWeekStart = State(initialValue: Date())
        }
    }

    var weekDays: [Date] {
        (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: currentWeekStart)
        }
    }

    @State private var slideOffset: CGFloat = 0
    @State private var isAnimating: Bool = false
    
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
                            selectedDate = day
                            onDaySelected(day)
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
                            // Swipe right - Previous week
                            slideOffset = 300
                            if let newDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) {
                                withAnimation {
                                    currentWeekStart = newDate
                                    slideOffset = 0
                                }
                            }
                        } else if value.translation.width < -threshold {
                            // Swipe left - Next week
                            slideOffset = -300
                            if let newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) {
                                withAnimation {
                                    currentWeekStart = newDate
                                    slideOffset = 0
                                }
                            }
                        } else {
                            // Reset if threshold not met
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
    }

    func isSelected(_ date: Date) -> Bool {
        selectedDate != nil ? calendar.isDate(selectedDate!, inSameDayAs: date) : isToday(date)
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

    func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: today)
    }
}

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        WeekView(onDaySelected: { selectedDate in
            print("Selected date: \(selectedDate)")
        })
        .previewLayout(.sizeThatFits)
    }
}
