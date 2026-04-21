import Foundation

public actor InMemorySecureNotesStore {
    private var notes: [UUID: EncryptedNoteEnvelope] = [:]

    public init() {}

    public func save(_ envelope: EncryptedNoteEnvelope) {
        notes[envelope.id] = envelope
    }

    public func list() -> [EncryptedNoteEnvelope] {
        notes.values.sorted { left, right in
            left.updatedAt > right.updatedAt
        }
    }

    public func load(id: UUID) -> EncryptedNoteEnvelope? {
        notes[id]
    }

    public func delete(id: UUID) {
        notes.removeValue(forKey: id)
    }
}
