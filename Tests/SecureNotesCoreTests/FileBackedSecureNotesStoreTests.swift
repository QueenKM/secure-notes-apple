import Foundation
import Testing
@testable import SecureNotesCore

@Test
func fileBackedStorePersistsEnvelope() async throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
    let fileURL = directory.appending(path: "notes.json")
    let store = FileBackedSecureNotesStore(fileURL: fileURL)
    let crypto = NoteCryptoService()
    let key = crypto.makeSymmetricKey(passphrase: "file-store", salt: "tests")
    let note = SecureNote(title: "Persisted note", body: "Should survive a reload.")
    let envelope = try crypto.encrypt(note, using: key)

    try await store.save(envelope)

    let loaded = try await store.list()
    #expect(loaded.count == 1)
    #expect(loaded.first?.id == note.id)

    try await store.delete(id: note.id)
    let cleared = try await store.list()
    #expect(cleared.isEmpty)
}
