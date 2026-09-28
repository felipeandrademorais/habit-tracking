import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var habitDataStore: HabitDataStore
    @StateObject private var profileStore = UserProfileStore()
    @State private var showEditNameModal = false
    
    var body: some View {
        ZStack {
            Color(.color1).ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        ProfileSectionView(profileStore: profileStore, showEditNameModal: $showEditNameModal)
                        Spacer()
                        YearCalendarView(habitDataStore: habitDataStore)
                        StatsSectionView(habitDataStore: habitDataStore)
                        MedalsSectionView(profileStore: profileStore, habitDataStore: habitDataStore)
                    }
                    .padding()
                }
                .scrollEdgeEffectStyle(.soft, for: .bottom)
            }
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
