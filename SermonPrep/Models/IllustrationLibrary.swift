import Foundation
import SwiftData

// MARK: - IllustrationLibrary

@Model
final class IllustrationLibrary {

    // MARK: Identity
    @Attribute(.unique) var id: UUID

    // MARK: Core fields
    var title: String
    var content: String

    /// The raw value of an IllustrationType case.
    var illustrationType: String

    // MARK: Source attribution
    var sourceTitle: String?
    var sourceAuthor: String?
    var sourceURL: String?

    // MARK: Organisation
    var tags: [String]
    var isFavorite: Bool

    // MARK: Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialiser

    init(
        title: String,
        content: String,
        illustrationType: IllustrationType = .story,
        sourceTitle: String? = nil,
        sourceAuthor: String? = nil,
        sourceURL: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.illustrationType = illustrationType.rawValue
        self.sourceTitle = sourceTitle
        self.sourceAuthor = sourceAuthor
        self.sourceURL = sourceURL
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed

    var illustrationTypeEnum: IllustrationType {
        IllustrationType(rawValue: illustrationType) ?? .story
    }

    // MARK: - Helpers

    func updateTimestamp() {
        updatedAt = Date()
    }
}
