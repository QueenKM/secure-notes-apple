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
                        onTogglePin: { feature.togglePin(note) },
                        onArchive: { feature.archive(note) }
                    )
                }
            }

            Section("Security Posture") {
                Label("Local-first storage keeps notes available offline.", systemImage: "internaldrive")
                Label("Future milestones include Keychain-backed keys and biometric gating.", systemImage: "faceid")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New") {
                    feature.beginNewNote()
                }
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
