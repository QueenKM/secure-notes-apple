import CryptoKit
import Testing
@testable import SecureNotesCore

@Test
func encryptDecryptRoundTrip() throws {
    let crypto = NoteCryptoService()
    let key = crypto.makeSymmetricKey(passphrase: "super-secret-passphrase", salt: "local-device")
    let original = SecureNote(
        title: "SOC onboarding notes",
        body: "Capture new analyst checklist and high-value bookmarks.",
        tags: ["work", "security"],
        isPinned: true,
        isArchived: false
    )

    let envelope = try crypto.encrypt(original, using: key)
    let decrypted = try crypto.decrypt(envelope, using: key)

    #expect(decrypted == original)
}

@Test
func decryptWithWrongKeyFails() throws {
    let crypto = NoteCryptoService()
    let goodKey = crypto.makeSymmetricKey(passphrase: "correct", salt: "local-device")
    let badKey = crypto.makeSymmetricKey(passphrase: "wrong", salt: "local-device")
    let note = SecureNote(title: "Private note", body: "Do not leak this.")

    let envelope = try crypto.encrypt(note, using: goodKey)

    do {
        _ = try crypto.decrypt(envelope, using: badKey)
        Issue.record("Expected decrypt to fail with the wrong key.")
    } catch {
        #expect(Bool(true))
    }
}
