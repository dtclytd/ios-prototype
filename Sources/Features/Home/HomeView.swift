import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var store: RecordStore
    @Environment(\.hapticsEnabled) private var hapticsEnabled

    @State private var greeting = "你好"

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private let modules: [AppModule] = [
        AppModule(
            title: "记录",
            subtitle: "本地存储 · 增删改查",
            symbol: "square.and.pencil",
            colors: [Color(red: 0.42, green: 0.35, blue: 0.95), Color(red: 0.60, green: 0.44, blue: 0.98)]
        ),
        AppModule(
            title: "统计",
            subtitle: "把数据换成图表",
            symbol: "chart.bar.xaxis",
            colors: [Color(red: 0.05, green: 0.65, blue: 0.91), Color(red: 0.13, green: 0.83, blue: 0.93)]
        ),
        AppModule(
            title: "同步",
            subtitle: "iCloud / 自建后端",
            symbol: "arrow.triangle.2.circlepath",
            colors: [Color(red: 0.98, green: 0.45, blue: 0.32), Color(red: 0.98, green: 0.68, blue: 0.35)]
        ),
        AppModule(
            title: "扩展",
            subtitle: "小组件 · 快捷指令",
            symbol: "square.stack.3d.up.fill",
            colors: [Color(red: 0.13, green: 0.72, blue: 0.52), Color(red: 0.35, green: 0.85, blue: 0.55)]
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                heroCard
                statGrid
                sectionHeader("功能模块", trailing: "占位卡片")
                moduleScroller
                sectionHeader("最近记录", trailing: "\(store.items.count) 条")
                recentList
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Theme.background.ignoresSafeArea())
        .onAppear {
            greeting = Self.currentGreeting()
        }
    }

    // MARK: - 顶部主卡

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                Text(greeting)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white.opacity(0.85))

            Text("这是你的原型骨架")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("三个页面、本地持久化、深色模式都已经接好。把这里的文案和模块换掉，它就是你自己要的 App。")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Label("\(store.items.count) 条记录", systemImage: "tray.full.fill")
                Label("v1.0", systemImage: "number")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Theme.heroGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.20), .clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                )
        )
        .shadow(color: Theme.accent.opacity(0.30), radius: 18, x: 0, y: 10)
    }

    // MARK: - 数据小卡

    private var statGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            StatTile(title: "记录总数", value: "\(store.items.count)", symbol: "list.bullet", tint: Theme.accent)
            StatTile(title: "置顶", value: "\(store.pinnedCount)", symbol: "pin.fill", tint: .orange)
        }
    }

    // MARK: - 模块横滑

    private var moduleScroller: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(modules) { module in
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: module.symbol)
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(.white.opacity(0.22)))

                        Spacer(minLength: 0)

                        Text(module.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(module.subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(2)
                    }
                    .padding(14)
                    .frame(width: 156, height: 152, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Theme.gradient(module.colors))
                    )
                    .onTapGesture {
                        if hapticsEnabled { Haptics.impact(.soft) }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, -18)
    }

    // MARK: - 最近记录

    private var recentList: some View {
        VStack(spacing: 10) {
            if store.items.isEmpty {
                Text("还没有记录，去「记录」页加一条。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .card()
            } else {
                ForEach(store.recent(4)) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.isPinned ? "pin.fill" : "doc.text")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                            .frame(width: 34, height: 34)
                            .background(
                                Circle().fill(Theme.accent.opacity(0.14))
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)
                            Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .card(padding: 12, radius: 16)
                }
            }
        }
    }

    // MARK: - 小工具

    private func sectionHeader(_ title: String, trailing: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(.headline)
            Spacer()
            Text(trailing).font(.caption.weight(.medium)).foregroundStyle(.secondary)
        }
    }

    private static func currentGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<11: return "早上好"
        case 11..<14: return "中午好"
        case 14..<18: return "下午好"
        case 18..<23: return "晚上好"
        default: return "夜深了"
        }
    }
}

// MARK: - 子组件

private struct AppModule: Identifiable {
    let title: String
    let subtitle: String
    let symbol: String
    let colors: [Color]

    var id: String { title }
}

private struct StatTile: View {
    let title: String
    let value: String
    let symbol: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(Circle().fill(tint.opacity(0.14)))

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: 12, radius: 16)
    }
}
