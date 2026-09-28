import SwiftUI

struct TaskCycleCardView: View {
    @Binding var selectedCycle: Repeticao
    @Binding var selectedDays: [Int]

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Defina o ciclo do seu Hábito")
                .font(Font.custom("Poppins-Regular", size: 14))
                .foregroundColor(.fontSoft)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: LiquidGlassStyle.chromeCornerRadius)
                    .fill(Color.grayLigth)
                    .frame(height: 40)

                GeometryReader { geometry in
                    let segmentWidth = geometry.size.width / CGFloat(Repeticao.allCases.count)
                    let index = Repeticao.allCases.firstIndex(of: selectedCycle) ?? 0

                    Color.clear
                        .frame(width: segmentWidth, height: 40)
                        .glassEffect(
                            .regular.tint(Color.color3).interactive(),
                            in: .rect(cornerRadius: LiquidGlassStyle.chromeCornerRadius)
                        )
                        .offset(x: segmentWidth * CGFloat(index))
                        .animation(.spring(), value: selectedCycle)
                }
                .frame(height: 40)

                HStack(spacing: 0) {
                    ForEach(Repeticao.allCases, id: \.self) { cycle in
                        Button(action: {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            withAnimation(.spring()) {
                                selectedCycle = cycle
                            }
                        }) {
                            Text(cycle.rawValue)
                                .font(Font.custom("Poppins-Medium", size: 14))
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.black)
                    }
                }
            }

            HStack(spacing: 12) {
                ForEach(WeekDayHelper.localizedWeekdays(), id: \.dayNumber) { day in
                    let isSelected = selectedDays.contains(day.dayNumber)
                    Button(action: {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        toggleDaySelection(day)
                    }) {
                        Text(day.dayName.capitalized)
                            .font(Font.custom("Poppins-Regular", size: 10))
                            .frame(width: 32, height: 32)
                            .foregroundColor(.black)
                            .background {
                                if isSelected {
                                    Color.clear.habitGlassCircle(tint: .color3)
                                } else {
                                    Circle().fill(Color.grayLigth)
                                }
                            }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets())
        .buttonStyle(PlainButtonStyle())
    }

    private func toggleDaySelection(_ day: (dayNumber: Int, dayName: String)) {
        if selectedDays.contains(day.dayNumber) {
            selectedDays.removeAll { $0 == day.dayNumber }
        } else {
            selectedDays.append(day.dayNumber)
        }
    }
}
