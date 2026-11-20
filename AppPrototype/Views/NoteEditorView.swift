import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let feature: NotesFeature
    let mode: EditorMode

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Note title", text: Binding(
                        get: { feature.draftTitle },
                        set: { feature.draftTitle = $0 }
                    ))
                }

                Section("Body") {
                    TextEditor(text: Binding(
                        get: { feature.draftBody },
                        set: { feature.draftBody = $0 }
                    ))
                    .frame(minHeight: 220)
                }

                Section("Tags") {
                    TextField("comma, separated, tags", text: Binding(
                        get: { feature.draftTags },
                        set: { feature.draftTags = $0 }
                    ))
                }
            }
            .disabled(feature.isBusy)
            .interactiveDismissDisabled(feature.isBusy)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await feature.saveDraft() }
                    }
                    .disabled(feature.isBusy || feature.draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var title: String {
        switch mode {
        case .create:
            return "New Note"
        case .edit:
            return "Edit Note"
        }
    }
}
