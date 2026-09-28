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

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Medalhas")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.fontSoft)
                Spacer()
                Text("\(unlockedCount)/\(totalCount)")
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundColor(.defaultDark)
            }

            ForEach(groupedMedals, id: \.category) { group in
                VStack(alignment: .leading, spacing: 10) {
                    Text(group.category.rawValue)
                        .font(.custom("Poppins-Medium", size: 13))
                        .foregroundColor(.fontSoft.opacity(0.8))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(group.medals, id: \.medal.id) { medalStatus in
                                MedalCardView(medalStatus: medalStatus)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(.top, 12)
    }
}
