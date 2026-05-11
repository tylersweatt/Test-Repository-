import Foundation

// MARK: - IllustrationMetadata

struct IllustrationMetadata: Codable {

    var sourceTitle: String?
    var sourceAuthor: String?

    /// The raw value of an IllustrationType case.
    var illustrationType: String

    var tags: [String]

    // MARK: Computed

    /// Returns the strongly-typed IllustrationType, defaulting to .story if unrecognised.
    var illustrationTypeEnum: IllustrationType {
        IllustrationType(rawValue: illustrationType) ?? .story
    }

    // MARK: Factory

    static var empty: IllustrationMetadata {
        IllustrationMetadata(
            sourceTitle: nil,
            sourceAuthor: nil,
            illustrationType: IllustrationType.story.rawValue,
            tags: []
        )
    }
}
