import SwiftUI

/// Legacy floating tab bar kept for previews/reference.
/// Production navigation uses the system `TabView` Liquid Glass chrome in `ContentView`.
struct CustomTabBar: View {
    @Binding var selectedTab: String
    let tabs: [TabItem]

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                ForEach(tabs) { tab in
                    Button(action: {
                        if selectedTab != tab.tag {
                            selectedTab = tab.tag
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }
                    }) {
                        VStack {
                            Image(systemName: tab.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 22)
                                .foregroundColor(selectedTab == tab.tag ? LiquidGlassStyle.brandTint : .fontSoft)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 100)
            .habitGlassPanel(cornerRadius: LiquidGlassStyle.chromeCornerRadius)
        }
        .zIndex(100)
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    @State static private var selectedTab: String = "calendar"

    static var previews: some View {
        CustomTabBar(
            selectedTab: $selectedTab,
            tabs: [
                TabItem(tag: "calendar", icon: "calendar", content: AnyView(Text("Calendario"))),
                TabItem(tag: "habits", icon: "checklist.checked", content: AnyView(Text("Habitos"))),
                TabItem(tag: "profile", icon: "person", content: AnyView(Text("Perfil")))
            ]
        )
    }
}
