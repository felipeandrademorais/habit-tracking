import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var habitDataStore: HabitDataStore
    @StateObject private var profileStore = UserProfileStore()
    @State private var showEditNameModal = false

    var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.sectionSpacing) {
                    ProfileSectionView(
                        profileStore: profileStore,
                        showEditNameModal: $showEditNameModal
                    )
                    .appearSoftly()

                    YearCalendarView(habitDataStore: habitDataStore)
                        .padding(16)
                        .habitSoftSurface()
                        .appearSoftly(delay: 0.05)

                    StatsSectionView(habitDataStore: habitDataStore)
                        .appearSoftly(delay: 0.1)

                    MedalsSectionView(profileStore: profileStore, habitDataStore: habitDataStore)
                        .appearSoftly(delay: 0.15)
                }
                .padding(AppTheme.screenPadding)
                .padding(.bottom, 28)
            }
            .scrollEdgeEffectStyle(.soft, for: .bottom)
        }
        .sheet(isPresented: $showEditNameModal) {
            EditNameModalView()
                .environmentObject(profileStore)
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Preview

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
            .environmentObject(UserProfileStore())
            .environmentObject(HabitDataStore.sampleDataStore)
    }
}
