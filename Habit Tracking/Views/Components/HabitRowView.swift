import SwiftUI

struct HabitRowView: View {
    @EnvironmentObject var dataStore: HabitDataStore
    @State private var showAnimation: Bool = false
    @State private var isPressed: Bool = false
    var habit: Habit
    var selectedDate: Date
    var showCheckbox: Bool = true
    var onHabitCompleted: ((Bool) -> Void)? = nil

    var body: some View {
        ZStack {
            HStack(spacing: 14) {
                iconWell

                VStack(alignment: .leading, spacing: 3) {
                    Text(habit.nome)
                        .font(AppTheme.body(15))
                        .strikethrough(isCompletedOnSelectedDate, color: .blackSoft)
                        .foregroundColor(isCompletedOnSelectedDate ? .fontSoft.opacity(0.55) : .fontSoft)
                        .lineLimit(2)

                    if showCheckbox {
                        Text(isCompletedOnSelectedDate ? "Concluído" : "Pendente")
                            .font(AppTheme.micro(11))
                            .foregroundColor(
                                isCompletedOnSelectedDate
                                ? LiquidGlassStyle.brandTint
                                : .fontSoft.opacity(0.45)
                            )
                    }
                }

                Spacer(minLength: 8)

                if showCheckbox {
                    completionButton
                } else if isCompletedOnSelectedDate {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(LiquidGlassStyle.brandTint)
                        .symbolEffect(.bounce, value: isCompletedOnSelectedDate)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.rowCornerRadius, style: .continuous)
                    .fill(Color(habit.cor))
                    .opacity(isCompletedOnSelectedDate ? 0.72 : 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.rowCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: AppTheme.softShadow, radius: isCompletedOnSelectedDate ? 2 : 8, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(AppTheme.snappySpring, value: isPressed)
            .animation(AppTheme.softSpring, value: isCompletedOnSelectedDate)
            .overlay(alignment: .trailing) {
                if showAnimation {
                    LottieView(animationName: "Check.json")
                        .frame(width: 150, height: 150)
                        .offset(x: 45, y: 0)
                        .allowsHitTesting(false)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            if isCompletedOnSelectedDate {
                showAnimation = false
            }
        }
    }

    private var iconWell: some View {
        Text(habit.icon)
            .font(.system(size: 24))
            .frame(width: AppTheme.iconWellSize, height: AppTheme.iconWellSize)
            .background(
                Circle()
                    .fill(Color.white.opacity(0.55))
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
            )
    }

    private var completionButton: some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            toggleCompletion(for: habit)
        }) {
            Image(systemName: isCompletedOnSelectedDate ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(isCompletedOnSelectedDate ? LiquidGlassStyle.brandTint : .fontSoft.opacity(0.35))
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    private var isCompletedOnSelectedDate: Bool {
        habit.isCompleted(on: selectedDate)
    }

    private func toggleCompletion(for habit: Habit) {
        var updatedHabit = habit
        let day = Calendar.current.startOfDay(for: selectedDate)

        if isCompletedOnSelectedDate {
            updatedHabit.datesCompleted.removeAll { date in
                Calendar.current.startOfDay(for: date) == day
            }
            onHabitCompleted?(false)
        } else {
            updatedHabit.datesCompleted.append(day)
            onHabitCompleted?(true)
            withAnimation(AppTheme.softSpring) {
                showAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.25)) {
                    showAnimation = false
                }
            }
        }

        dataStore.updateHabit(updatedHabit)
    }
}

// MARK: - Preview
struct HabitRowView_Previews: PreviewProvider {
    static var previews: some View {
        let dataStore = HabitDataStore()

        let habitExample = Habit(
            nome: "Beber 2L de água",
            cor: "color2",
            dataInicio: Date().addingTimeInterval(-86400 * 5),
            repeticoes: .daily,
            datesCompleted: [Calendar.current.startOfDay(for: Date())],
            icon: "⭐️"
        )

        dataStore.habits = [habitExample]

        return HabitRowView(
            habit: habitExample,
            selectedDate: Date()
        )
        .environmentObject(dataStore)
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Habit Row com Checkbox e Validação")
    }
}
