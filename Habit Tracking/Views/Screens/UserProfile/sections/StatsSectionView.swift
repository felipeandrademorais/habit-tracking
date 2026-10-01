import SwiftUI

struct StatsSectionView: View {
    var habitDataStore: HabitDataStore

    var body: some View {
        VStack(spacing: 14) {
            Text("Estatísticas")
                .font(AppTheme.headline(16))
                .foregroundColor(.fontSoft)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                StatCardView(
                    title: "Hábitos criados",
                    value: habitDataStore.createdHabitsCount(),
                    systemImage: "plus.circle.fill"
                )
                StatCardView(
                    title: "Hábitos completos",
                    value: habitDataStore.completedHabitsCount(),
                    systemImage: "checkmark.seal.fill"
                )
            }
        }
    }
}
