import SwiftUI

struct EmptyHabitsView: View {
    var onAddHabit: () -> Void

    @State private var bounce = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 12)

            Image("Woman")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 260)
                .padding(.horizontal, 28)
                .scaleEffect(bounce ? 1.02 : 0.98)
                .animation(
                    .easeInOut(duration: 2.4).repeatForever(autoreverses: true),
                    value: bounce
                )
                .onAppear { bounce = true }

            VStack(spacing: 8) {
                Text("Comece um novo hábito")
                    .font(AppTheme.title(20))
                    .foregroundColor(.fontSoft)
                    .multilineTextAlignment(.center)

                Text("Toque no + para criar o primeiro e acompanhar seu progresso do dia.")
                    .font(AppTheme.caption(13))
                    .foregroundColor(.fontSoft.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            Button(action: onAddHabit) {
                Label("Criar hábito", systemImage: "plus")
                    .font(AppTheme.body(14))
                    .frame(maxWidth: 220)
            }
            .buttonStyle(.glassProminent)
            .tint(LiquidGlassStyle.brandTint)
            .padding(.top, 4)

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity)
        .appearSoftly(delay: 0.05)
    }
}
