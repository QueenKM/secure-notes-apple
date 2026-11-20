import CryptoKit
import Foundation
import LocalAuthentication
import Security

enum VaultKeychain {
    enum KeyError: Error {
        case keychain(OSStatus)
        case invalidKey
        case missingKey
        case accessControl
    }

    @MainActor
    static func unlockKey(existingNotes: Bool) async throws -> SymmetricKey {
        let context = LAContext()
        let authenticated = try await context.evaluatePolicy(
            .deviceOwnerAuthentication, localizedReason: "Unlock your encrypted notes."
        )
        guard authenticated else { throw KeyError.accessControl }
        defer { context.invalidate() }

        let identity: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "dev.kristinam.SecureNotes",
            kSecAttrAccount as String: "note-encryption-key"
        ]
        var lookup = identity
        lookup[kSecReturnData as String] = true
        lookup[kSecUseAuthenticationContext as String] = context

        var result: CFTypeRef?
        let status = SecItemCopyMatching(lookup as CFDictionary, &result)
        if status == errSecSuccess {
            guard let bytes = result as? Data, bytes.count == 32 else { throw KeyError.invalidKey }
            return SymmetricKey(data: bytes)
        }
        guard status == errSecItemNotFound else { throw KeyError.keychain(status) }
        guard !existingNotes else { throw KeyError.missingKey }

        guard let access = SecAccessControlCreateWithFlags(
            nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, nil
        ) else { throw KeyError.accessControl }

        let key = SymmetricKey(size: .bits256)
        var item = identity
        item[kSecAttrAccessControl as String] = access
        item[kSecValueData as String] = key.withUnsafeBytes { Data($0) }
        let addStatus = SecItemAdd(item as CFDictionary, nil)
        guard addStatus == errSecSuccess else { throw KeyError.keychain(addStatus) }
        return key
    }
}
