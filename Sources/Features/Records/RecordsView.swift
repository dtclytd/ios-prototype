import SwiftUI

struct RecordsView: View {

    @EnvironmentObject private var store: RecordStore
    @Environment(\.hapticsEnabled) private var hapticsEnabled

    @State private var isAdding = false
    @State private var query = ""

    private var filtered: [RecordItem] {
        let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return store.items }
        return store.items.filter {
            $0.title.localizedCaseInsensitiveContains(keyword)
                || $0.detail.localizedCaseInsensitiveContains(keyword)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("记录")
            .searchable(text: $query, prompt: "搜索标题或内容")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if hapticsEnabled { Haptics.impact() }
                        isAdding = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                    }
                }
            }
            .sheet(isPresented: $isAdding) {
                AddRecordView { title, detail, pinned in
                    store.add(title: title, detail: detail, isPinned: pinned)
                    if hapticsEnabled { Haptics.success() }
                }
            }
        }
    }

    // MARK: - 列表

    private var list: some View {
        List {
            ForEach(filtered) { item in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        if item.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.orange)
                        }
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                    }

                    if !item.detail.isEmpty {
                        Text(item.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        store.togglePin(item)
                        if hapticsEnabled { Haptics.impact(.medium) }
                    } label: {
                        Label(item.isPinned ? "取消置顶" : "置顶", systemImage: "pin")
                    }
                    .tint(.orange)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        store.delete(item)
                        if hapticsEnabled { Haptics.warning() }
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - 空状态

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: query.isEmpty ? "tray" : "magnifyingglass")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.tertiary)

            Text(query.isEmpty ? "还没有记录" : "没有匹配的结果")
                .font(.headline)

            Text(query.isEmpty ? "点右上角的 + 添加第一条。" : "换个关键词试试。")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if query.isEmpty {
                Button {
                    isAdding = true
                } label: {
                    Text("新增记录")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Theme.accent))
                        .foregroundStyle(.white)
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
    }
}
