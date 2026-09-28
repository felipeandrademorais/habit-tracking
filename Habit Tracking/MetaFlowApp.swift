import SwiftUI

@main
struct MetaFlowApp: App {
    @StateObject private var dataStore = HabitDataStore()
    @StateObject private var versionChecker = VersionChecker.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(dataStore)
                    .font(Font.custom("Poppins-Regular", size: 16))
                    .preferredColorScheme(.light)
                
                UpdateAlertView()
            }
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: String = "habits"

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Calendário", systemImage: "calendar", value: "calendar") {
                CalendarView()
            }

            Tab("Hábitos", systemImage: "checklist.checked", value: "habits") {
                HabitsTodayView()
            }

            Tab("Perfil", systemImage: "person", value: "profile") {
                UserProfileView()
            }
        }
        .tint(LiquidGlassStyle.brandTint)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

//Preview
struct MetaFlowApp_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HabitDataStore.sampleDataStore)
    }
}
