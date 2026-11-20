import SwiftUI
import SecureNotesCore

struct NotesHomeView: View {
    let feature: NotesFeature

    var body: some View {
        NavigationStack {
            Group {
                switch feature.unlockState {
                case .locked:
                    UnlockGateView(feature: feature)
                case .unlocked:
                    content
                }
            }
            .navigationTitle("Secure Notes")
            .alert("Secure Notes", isPresented: Binding(
                get: { feature.errorMessage != nil },
                set: { if !$0 { feature.errorMessage = nil } }
            )) {
                Button("OK") { feature.errorMessage = nil }
            } message: {
                Text(feature.errorMessage ?? "")
            }
        }
    }

    private var content: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Search")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    TextField("Titles, tags, or note content", text: Binding(
                        get: { feature.searchText },
                        set: { feature.searchText = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
            }

            Section("Encrypted Notes") {
                ForEach(feature.visibleNotes) { note in
                    NoteRowView(
                        note: note,
                        onOpen: { feature.select(note) },
                        onTogglePin: { Task { await feature.togglePin(note) } },
                        onArchive: { Task { await feature.archive(note) } }
                    )
                }
            }

        }
        .disabled(feature.isBusy)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Lock") { feature.lock() }
                    .disabled(feature.isBusy)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("New") {
                    feature.beginNewNote()
                }
                .disabled(feature.isBusy)
            }
        }
        .sheet(item: Binding(
            get: { feature.editorMode },
            set: { feature.editorMode = $0 }
        )) { note in
            NoteEditorView(feature: feature, mode: note)
        }
    }
}
