import SwiftUI

struct CalendarDayCell: View {
    @EnvironmentObject var dataStore: HabitDataStore

    let date: Date
    let isSelected: Bool
    let onSelect: () -> Void

    private var completionOpacity: Double {
        dataStore.getCompletionRateForDate(date)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var shouldShowMedal: Bool {
        completionOpacity == 1.0
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(AppTheme.body(15))
                .foregroundColor(isSelected ? .white : .fontSoft)
                .frame(minWidth: 40, minHeight: 40)
                .background(cellBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    if isToday && !isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(LiquidGlassStyle.brandTint.opacity(0.55), lineWidth: 1.5)
                    }
                }
                .scaleEffect(isSelected ? 1.06 : 1)
                .animation(AppTheme.snappySpring, value: isSelected)
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    onSelect()
                }

            if shouldShowMedal {
                Image("reward1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .offset(x: 3, y: -3)
            }
        }
    }

    @ViewBuilder
    private var cellBackground: some View {
        if isSelected {
            LiquidGlassStyle.brandTint
        } else if completionOpacity > 0 {
            LiquidGlassStyle.brandTint.opacity(0.15 + completionOpacity * 0.55)
        } else {
            Color.blueSoft.opacity(0.45)
        }
    }
}

struct CalendarDayCell_Previews: PreviewProvider {
    static var previews: some View {
        let mockDataStore = HabitDataStore()

        return Group {
            CalendarDayCell(
                date: Date(),
                isSelected: false,
                onSelect: {}
            )
            .environmentObject(mockDataStore)
            .previewDisplayName("Dia Normal")

            CalendarDayCell(
                date: Date(),
                isSelected: true,
                onSelect: {}
            )
            .environmentObject(mockDataStore)
            .previewDisplayName("Dia Selecionado")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
