import Foundation
import SwiftData

// MARK: - SermonTemplate

@Model
final class SermonTemplate {

    // MARK: Identity
    @Attribute(.unique) var id: UUID

    // MARK: Core fields
    var title: String
    var templateDescription: String

    /// JSON-encoded array of BlockType rawValue strings defining the default block sequence.
    var defaultBlockSequence: Data

    var isSystemTemplate: Bool

    // MARK: Timestamps
    var createdAt: Date

    // MARK: - Initialiser

    init(title: String, blockTypes: [BlockType], isSystem: Bool = false) {
        self.id = UUID()
        self.title = title
        self.templateDescription = ""
        self.isSystemTemplate = isSystem
        self.createdAt = Date()

        let rawValues = blockTypes.map { $0.rawValue }
        self.defaultBlockSequence = (try? JSONEncoder().encode(rawValues)) ?? Data()
    }

    // MARK: - Computed

    /// Decoded array of BlockType values from the stored JSON sequence.
    var blockTypes: [BlockType] {
        guard
            let rawValues = try? JSONDecoder().decode([String].self, from: defaultBlockSequence)
        else { return [] }
        return rawValues.compactMap { BlockType(rawValue: $0) }
    }
}
