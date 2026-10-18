import SwiftUI

@main
struct PrototypeApp: App {

    @StateObject private var store = RecordStore()

    @AppStorage("prototype.appearance") private var appearanceRaw: String = AppAppearance.system.rawValue
    @AppStorage("prototype.haptics") private var hapticsEnabled: Bool = true

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environment(\.hapticsEnabled, hapticsEnabled)
                .preferredColorScheme(AppAppearance(rawValue: appearanceRaw)?.colorScheme)
                .tint(Theme.accent)
        }
    }
}
