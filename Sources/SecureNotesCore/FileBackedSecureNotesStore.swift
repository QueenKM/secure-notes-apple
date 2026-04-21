import Foundation

public actor FileBackedSecureNotesStore {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(fileURL: URL) {
        self.fileURL = fileURL
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    public func list() throws -> [EncryptedNoteEnvelope] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([EncryptedNoteEnvelope].self, from: data)
    }

    public func save(_ envelope: EncryptedNoteEnvelope) throws {
        var current = try list().filter { $0.id != envelope.id }
        current.append(envelope)
        current.sort { $0.updatedAt > $1.updatedAt }
        try persist(current)
    }

    public func delete(id: UUID) throws {
        let remaining = try list().filter { $0.id != id }
        try persist(remaining)
    }

    private func persist(_ envelopes: [EncryptedNoteEnvelope]) throws {
        let parent = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        let data = try encoder.encode(envelopes)
        try data.write(to: fileURL, options: .atomic)
    }
}
