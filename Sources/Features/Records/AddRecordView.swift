import SwiftUI

struct AddRecordView: View {

    @Environment(\.dismiss) private var dismiss
    @FocusState private var titleFocused: Bool

    @State private var title = ""
    @State private var detail = ""
    @State private var pinned = false

    /// 保存回调：(标题, 正文, 是否置顶)
    let onSave: (String, String, Bool) -> Void

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("标题") {
                    TextField("给它起个名字", text: $title)
                        .focused($titleFocused)
                        .submitLabel(.done)
                }

                Section("正文") {
                    TextEditor(text: $detail)
                        .frame(minHeight: 110)
                        .overlay(alignment: .topLeading) {
                            if detail.isEmpty {
                                Text("补充说明（可留空）")
                                    .font(.body)
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                Section {
                    Toggle(isOn: $pinned) {
                        Label("置顶", systemImage: "pin")
                    }
                }
            }
            .navigationTitle("新增记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(title, detail, pinned)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                titleFocused = true
            }
        }
    }
}
