import Foundation

public struct SecureNote: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var body: String
    public var tags: [String]
    public var isPinned: Bool
    public var isArchived: Bool
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        body: String,
        tags: [String] = [],
        isPinned: Bool = false,
        isArchived: Bool = false,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.tags = tags
        self.isPinned = isPinned
        self.isArchived = isArchived
        self.updatedAt = updatedAt
    }
}

public struct EncryptedNoteEnvelope: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let titleHint: String
    public let updatedAt: Date
    public let tags: [String]
    public let nonce: Data
    public let ciphertext: Data
    public let tag: Data

    public init(
        id: UUID,
        titleHint: String,
        updatedAt: Date,
        tags: [String],
        nonce: Data,
        ciphertext: Data,
        tag: Data
    ) {
        self.id = id
        self.titleHint = titleHint
        self.updatedAt = updatedAt
        self.tags = tags
        self.nonce = nonce
        self.ciphertext = ciphertext
        self.tag = tag
    }
}
