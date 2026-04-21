import CryptoKit
import Foundation

public enum NoteCryptoError: Error {
    case malformedEnvelope
    case decryptionFailed
}

public struct NoteCryptoService: Sendable {
    public init() {}

    public func makeSymmetricKey(passphrase: String, salt: String) -> SymmetricKey {
        let material = Data("\(passphrase)::\(salt)".utf8)
        let digest = SHA256.hash(data: material)
        return SymmetricKey(data: Data(digest))
    }

    public func encrypt(_ note: SecureNote, using key: SymmetricKey) throws -> EncryptedNoteEnvelope {
        let plaintext = try JSONEncoder().encode(note)
        let sealed = try AES.GCM.seal(plaintext, using: key)

        return EncryptedNoteEnvelope(
            id: note.id,
            titleHint: note.title,
            updatedAt: note.updatedAt,
            tags: note.tags,
            nonce: sealed.nonce.withUnsafeBytes { Data($0) },
            ciphertext: sealed.ciphertext,
            tag: sealed.tag
        )
    }

    public func decrypt(_ envelope: EncryptedNoteEnvelope, using key: SymmetricKey) throws -> SecureNote {
        guard let nonce = try? AES.GCM.Nonce(data: envelope.nonce) else {
            throw NoteCryptoError.malformedEnvelope
        }

        let sealed = try AES.GCM.SealedBox(nonce: nonce, ciphertext: envelope.ciphertext, tag: envelope.tag)
        let plaintext = try AES.GCM.open(sealed, using: key)
        guard let note = try? JSONDecoder().decode(SecureNote.self, from: plaintext) else {
            throw NoteCryptoError.decryptionFailed
        }
        return note
    }
}
