import SwiftUI

struct MedalsSectionView: View {
    @ObservedObject var profileStore: UserProfileStore
    var habitDataStore: HabitDataStore

    private var groupedMedals: [(category: MedalCategory, medals: [MedalStatus])] {
        profileStore.getMedalsStatusByCategory(habitDataStore: habitDataStore)
    }

    private var unlockedCount: Int {
        groupedMedals.flatMap(\.medals).filter(\.isUnlocked).count
    }

    private var totalCount: Int {
        groupedMedals.flatMap(\.medals).count
    }

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalCount)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                Text("Medalhas")
                    .font(AppTheme.headline(16))
                    .foregroundColor(.fontSoft)

                Spacer()

                Text("\(unlockedCount)/\(totalCount)")
                    .font(AppTheme.body(12))
                    .foregroundColor(LiquidGlassStyle.brandTint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(LiquidGlassStyle.brandTint.opacity(0.12))
                    )
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.12))
                        .frame(height: 6)

                    Capsule()
                        .fill(LiquidGlassStyle.brandTint)
                        .frame(width: max(geo.size.width * progress, progress > 0 ? 8 : 0), height: 6)
                        .animation(AppTheme.softSpring, value: progress)
                }
            }
            .frame(height: 6)

            ForEach(groupedMedals, id: \.category) { group in
                VStack(alignment: .leading, spacing: 10) {
                    Text(group.category.rawValue)
                        .font(AppTheme.body(13))
                        .foregroundColor(.fontSoft.opacity(0.7))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(group.medals, id: \.medal.id) { medalStatus in
                                MedalCardView(medalStatus: medalStatus)
                            }
                        }
                        .padding(.vertical, 2)
                        .padding(.trailing, 4)
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}
