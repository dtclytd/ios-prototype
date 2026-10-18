import SwiftUI

struct RootView: View {

    enum Tab: Hashable {
        case home
        case records
        case settings
    }

    @State private var selection: Tab = .home
    @Environment(\.hapticsEnabled) private var hapticsEnabled

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "square.grid.2x2.fill")
                }
                .tag(Tab.home)

            RecordsView()
                .tabItem {
                    Label("记录", systemImage: "list.bullet.rectangle.portrait.fill")
                }
                .tag(Tab.records)

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .onChange(of: selection) { _ in
            if hapticsEnabled { Haptics.selection() }
        }
    }
}
