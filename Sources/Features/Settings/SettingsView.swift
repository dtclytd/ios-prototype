import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var store: RecordStore

    @AppStorage("prototype.appearance") private var appearanceRaw: String = AppAppearance.system.rawValue
    @AppStorage("prototype.haptics") private var hapticsEnabled: Bool = true

    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("外观") {
                    Picker("主题", selection: $appearanceRaw) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.title).tag(appearance.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("交互") {
                    Toggle(isOn: $hapticsEnabled) {
                        Label("触感反馈", systemImage: "hand.tap")
                    }
                }

                Section("数据") {
                    HStack {
                        Label("记录条数", systemImage: "tray.full")
                        Spacer()
                        Text("\(store.items.count)")
                            .foregroundStyle(.secondary)
                    }

                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("清空所有记录", systemImage: "trash")
                    }
                }

                Section("关于") {
                    HStack {
                        Label("版本", systemImage: "number")
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("包名", systemImage: "shippingbox")
                        Spacer()
                        Text(Bundle.main.bundleIdentifier ?? "-")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }

                Section {
                    Text("这是一个可运行的骨架：界面、本地存储、深色模式、触感反馈都已接好。替换 Sources/Features 下的页面内容，就是你的 App。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("设置")
            .alert("清空所有记录？", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) {}
                Button("清空", role: .destructive) {
                    store.reset()
                }
            } message: {
                Text("清空后无法恢复。")
            }
        }
    }
}
