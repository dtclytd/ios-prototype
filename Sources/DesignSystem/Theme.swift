import SwiftUI

/// 全局配色与通用样式。
/// 想换风格只改这里：改 `accent` 和 `heroGradient` 就能整体变样。
enum Theme {

    // MARK: - 主色

    static let accent = Color(red: 0.42, green: 0.35, blue: 0.95)
    static let accentAlt = Color(red: 0.13, green: 0.83, blue: 0.93)

    // MARK: - 表面

    static var background: Color { Color(uiColor: .systemGroupedBackground) }
    static var card: Color { Color(uiColor: .secondarySystemGroupedBackground) }
    static var hairline: Color { Color.primary.opacity(0.07) }

    // MARK: - 渐变

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.20, green: 0.13, blue: 0.45),
            Color(red: 0.42, green: 0.35, blue: 0.95)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func gradient(_ colors: [Color]) -> LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - 外观设置

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "跟随系统"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }

    var symbol: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - 触感反馈开关（通过 Environment 下发）

private struct HapticsEnabledKey: EnvironmentKey {
    static var defaultValue: Bool { true }
}

extension EnvironmentValues {
    var hapticsEnabled: Bool {
        get { self[HapticsEnabledKey.self] }
        set { self[HapticsEnabledKey.self] = newValue }
    }
}

// MARK: - 卡片样式

struct CardModifier: ViewModifier {
    var padding: CGFloat = 16
    var radius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Theme.hairline, lineWidth: 1)
            )
    }
}

extension View {
    func card(padding: CGFloat = 16, radius: CGFloat = 20) -> some View {
        modifier(CardModifier(padding: padding, radius: radius))
    }
}
