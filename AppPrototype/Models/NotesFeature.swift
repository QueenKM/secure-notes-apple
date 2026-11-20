import CryptoKit
import Foundation
import Observation
import SecureNotesCore

@MainActor
@Observable
final class NotesFeature {
    var unlockState: UnlockState = .locked
    private(set) var notes: [SecureNote] = []
    private(set) var isBusy = false
    var errorMessage: String?
    private let store: FileBackedSecureNotesStore
    private let crypto = NoteCryptoService()
    private var key: SymmetricKey?
    private var lockPending = false

    init(store: FileBackedSecureNotesStore) {
        self.store = store
    }
    var editorMode: EditorMode?
    var searchText = ""
    var draftTitle = ""
    var draftBody = ""
    var draftTags = ""

    func unlock() async {
        guard !isBusy, unlockState == .locked else { return }
        isBusy = true
        defer { finishActivity() }
        do {
            let envelopes = try await store.list()
            let unlockedKey = try await VaultKeychain.unlockKey(existingNotes: !envelopes.isEmpty)
            let decrypted = try envelopes.map { try crypto.decrypt($0, using: unlockedKey) }
            for (envelope, note) in zip(envelopes, decrypted)
                where !envelope.titleHint.isEmpty || !envelope.tags.isEmpty {
                try await store.save(crypto.encrypt(note, using: unlockedKey))
            }
            notes = decrypted
            key = unlockedKey
            unlockState = .unlocked
        } catch {
            errorMessage = "Could not unlock the vault. Check device authentication and try again."
        }
    }

    func lock() {
        if isBusy {
            lockPending = true
            return
        }
        lockPending = false
        unlockState = .locked
        key = nil
        notes.removeAll()
        editorMode = nil
        searchText = ""
        draftTitle = ""
        draftBody = ""
        draftTags = ""
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

    func saveDraft() async {
        let tags = draftTags.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var note: SecureNote
        switch editorMode {
        case .create:
            note = SecureNote(title: draftTitle, body: draftBody, tags: tags)
        case let .edit(id):
            guard let existing = notes.first(where: { $0.id == id }) else { return }
            note = existing
            note.title = draftTitle
            note.body = draftBody
            note.tags = tags
            note.updatedAt = .now
        case .none:
            return
        }

        if await persist(note) {
            editorMode = nil
            draftTitle = ""
            draftBody = ""
            draftTags = ""
        }
    }

    func togglePin(_ note: SecureNote) async {
        guard var existing = notes.first(where: { $0.id == note.id }) else { return }
        existing.isPinned.toggle()
        existing.updatedAt = .now
        _ = await persist(existing)
    }

    func archive(_ note: SecureNote) async {
        guard var existing = notes.first(where: { $0.id == note.id }) else { return }
        existing.isArchived = true
        existing.updatedAt = .now
        _ = await persist(existing)
    }

    private func finishActivity() {
        isBusy = false
        if lockPending { lock() }
    }

    private func persist(_ note: SecureNote) async -> Bool {
        guard let key, !isBusy else { return false }
        isBusy = true
        defer { finishActivity() }
        do {
            try await store.save(crypto.encrypt(note, using: key))
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = note
            } else {
                notes.append(note)
            }
            return true
        } catch {
            errorMessage = "Could not save the encrypted note. Please try again."
            return false
        }
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
