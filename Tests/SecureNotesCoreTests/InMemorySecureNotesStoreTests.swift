import Testing
@testable import SecureNotesCore

@Test
func saveListAndDeleteEnvelope() async throws {
    let crypto = NoteCryptoService()
    let key = crypto.makeSymmetricKey(passphrase: "store-key", salt: "tests")
    let store = InMemorySecureNotesStore()
    let note = SecureNote(title: "Pinned note", body: "This should stay safe.", isPinned: true)
    let envelope = try crypto.encrypt(note, using: key)

    await store.save(envelope)

    let list = await store.list()
    #expect(list.count == 1)
    #expect(list.first?.titleHint == "Pinned note")

    await store.delete(id: note.id)
    let updated = await store.list()
    #expect(updated.isEmpty)
}
