import Foundation
import SwiftData

// MARK: - SermonBlock

@Model
final class SermonBlock {

    // MARK: Identity
    @Attribute(.unique) var id: UUID

    // MARK: Relationships
    var sermon: Sermon?

    // MARK: Core fields
    var blockType: String   // BlockType.rawValue
    var sortOrder: Int
    var content: String
    var metadata: Data?     // JSON-encoded block-specific metadata struct
    var isPinned: Bool

    // MARK: Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialiser

    init(
        blockType: BlockType = .explanation,
        sortOrder: Int = 0,
        sermon: Sermon? = nil
    ) {
        self.id = UUID()
        self.sermon = sermon
        self.blockType = blockType.rawValue
        self.sortOrder = sortOrder
        self.content = ""
        self.metadata = nil
        self.isPinned = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed

    var blockTypeEnum: BlockType {
        BlockType(rawValue: blockType) ?? .explanation
    }

    // MARK: - Helpers

    func updateTimestamp() {
        updatedAt = Date()
    }

    // MARK: - Generic metadata coding

    func decodeMetadata<T: Codable>(as type: T.Type) -> T? {
        guard let data = metadata else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    func encodeMetadata<T: Codable>(_ value: T) {
        metadata = try? JSONEncoder().encode(value)
    }

    // MARK: - Typed metadata accessors

    var scriptureMetadata: ScriptureMetadata? {
        get { decodeMetadata(as: ScriptureMetadata.self) }
        set {
            if let value = newValue {
                encodeMetadata(value)
            } else {
                metadata = nil
            }
        }
    }

    var illustrationMetadata: IllustrationMetadata? {
        get { decodeMetadata(as: IllustrationMetadata.self) }
        set {
            if let value = newValue {
                encodeMetadata(value)
            } else {
                metadata = nil
            }
        }
    }

    var outlineMetadata: OutlineMetadata? {
        get { decodeMetadata(as: OutlineMetadata.self) }
        set {
            if let value = newValue {
                encodeMetadata(value)
            } else {
                metadata = nil
            }
        }
    }
}
