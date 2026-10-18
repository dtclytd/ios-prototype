import Combine
import Foundation

// MARK: - 数据模型

struct RecordItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var detail: String
    var isPinned: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        detail: String = "",
        isPinned: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.isPinned = isPinned
        self.createdAt = createdAt
    }
}

// MARK: - 数据仓库

/// 本地持久化（UserDefaults + JSON）。
/// 需要换成 Core Data / SwiftData / 云同步时，只替换这个类即可，界面层不用动。
final class RecordStore: ObservableObject {

    @Published private(set) var items: [RecordItem] = []

    private let storageKey = "prototype.records.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    // MARK: - 增删改

    func add(title: String, detail: String, isPinned: Bool = false) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.append(
            RecordItem(
                title: trimmed,
                detail: detail.trimmingCharacters(in: .whitespacesAndNewlines),
                isPinned: isPinned
            )
        )
        sortAndSave()
    }

    func delete(_ item: RecordItem) {
        items.removeAll { $0.id == item.id }
        sortAndSave()
    }

    func togglePin(_ item: RecordItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isPinned.toggle()
        sortAndSave()
    }

    func reset() {
        items = []
        defaults.removeObject(forKey: storageKey)
    }

    // MARK: - 派生数据

    var pinnedCount: Int {
        items.filter { $0.isPinned }.count
    }

    func recent(_ limit: Int) -> [RecordItem] {
        Array(items.prefix(limit))
    }

    // MARK: - 持久化

    private func sortAndSave() {
        items.sort { lhs, rhs in
            if lhs.isPinned != rhs.isPinned { return lhs.isPinned }
            return lhs.createdAt > rhs.createdAt
        }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = defaults.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([RecordItem].self, from: data)
        else {
            items = Self.sampleData
            return
        }
        items = decoded
    }

    /// 首次启动的示例数据，删掉这段就不会有默认内容。
    private static var sampleData: [RecordItem] {
        [
            RecordItem(title: "欢迎使用原型", detail: "这一条是首次启动时自动生成的示例记录，左滑可以删除。", isPinned: true, createdAt: Date()),
            RecordItem(title: "点右上角 + 新增", detail: "支持标题、正文和置顶。", createdAt: Date().addingTimeInterval(-3600)),
            RecordItem(title: "设置里可以换深色", detail: "外观跟随系统 / 浅色 / 深色三档。", createdAt: Date().addingTimeInterval(-86400))
        ]
    }
}
