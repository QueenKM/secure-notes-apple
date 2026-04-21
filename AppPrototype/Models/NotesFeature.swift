import Foundation
import Observation
import SecureNotesCore

@MainActor
@Observable
final class NotesFeature {
    var unlockState: UnlockState = .locked
    var notes: [SecureNote] = [
        SecureNote(title: "Board meeting prep", body: "Summarize security posture for Friday.", tags: ["work"], isPinned: true),
        SecureNote(title: "Travel checklist", body: "Passport, charger, hotel reservation.", tags: ["personal"]),
        SecureNote(title: "Vendor review", body: "Check encryption-at-rest answers and SSO support.", tags: ["security", "review"])
    ]
    var editorMode: EditorMode?
    var searchText = ""
    var draftTitle = ""
    var draftBody = ""
    var draftTags = ""

    func unlock() {
        unlockState = .unlocked
    }

    func beginNewNote() {
        draftTitle = ""
        draftBody = ""
        draftTags = ""
        editorMode = .create
    }

    func select(_ note: SecureNote) {
        draftTitle = note.title
        draftBody = note.body
        draftTags = note.tags.joined(separator: ", ")
        editorMode = .edit(note.id)
    }

    var visibleNotes: [SecureNote] {
        notes
            .filter { !$0.isArchived }
            .filter { note in
                guard !searchText.isEmpty else { return true }
                return note.title.localizedCaseInsensitiveContains(searchText)
                    || note.body.localizedCaseInsensitiveContains(searchText)
                    || note.tags.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
            }
            .sorted { left, right in
                if left.isPinned != right.isPinned {
                    return left.isPinned && !right.isPinned
                }
                return left.updatedAt > right.updatedAt
            }
    }

    func saveDraft() {
        let tags = draftTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        switch editorMode {
        case .create:
            notes.insert(
                SecureNote(
                    title: draftTitle,
                    body: draftBody,
                    tags: tags,
                    updatedAt: .now
                ),
                at: 0
            )
        case let .edit(id):
            guard let index = notes.firstIndex(where: { $0.id == id }) else { break }
            notes[index].title = draftTitle
            notes[index].body = draftBody
            notes[index].tags = tags
            notes[index].updatedAt = .now
        case .none:
            break
        }

        editorMode = nil
    }

    func togglePin(_ note: SecureNote) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].isPinned.toggle()
        notes[index].updatedAt = .now
    }

    func archive(_ note: SecureNote) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].isArchived = true
        notes[index].updatedAt = .now
    }
}

enum UnlockState {
    case locked
    case unlocked
}

enum EditorMode: Identifiable {
    case create
    case edit(UUID)

    var id: String {
        switch self {
        case .create:
            return "create"
        case let .edit(id):
            return "edit-\(id.uuidString)"
        }
    }
}
