import Foundation
import SwiftData

// MARK: - SermonStatus

enum SermonStatus: String, Codable, CaseIterable, Identifiable {
    case draft     = "draft"
    case inProgress = "inProgress"
    case ready     = "ready"
    case preached  = "preached"
    case archived  = "archived"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .draft:       return "Draft"
        case .inProgress:  return "In Progress"
        case .ready:       return "Ready"
        case .preached:    return "Preached"
        case .archived:    return "Archived"
        }
    }

    var systemImage: String {
        switch self {
        case .draft:       return "pencil.circle"
        case .inProgress:  return "clock.arrow.circlepath"
        case .ready:       return "checkmark.circle"
        case .preached:    return "speaker.wave.2"
        case .archived:    return "archivebox"
        }
    }
}

// MARK: - Sermon

@Model
final class Sermon {

    // MARK: Identity
    @Attribute(.unique) var id: UUID

    // MARK: Core fields
    var title: String
    var subtitle: String
    var passageReference: String
    var bookOfBible: String     // BibleBook.rawValue

    // MARK: Status & scheduling
    var status: String          // SermonStatus.rawValue
    var datePrepared: Date?
    var datePreached: Date?

    // MARK: Speaker & location
    var speakerName: String
    var location: String

    // MARK: Preparation notes
    var bigIdea: String         // The "one sentence" central proposition
    var aim: String             // What the sermon intends to accomplish in listeners
    var targetAudience: String
    var tags: [String]

    // MARK: Relationships
    @Relationship(deleteRule: .cascade, inverse: \SermonBlock.sermon)
    var blocks: [SermonBlock]

    @Relationship(inverse: \Series.sermons)
    var series: Series?

    // MARK: Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: Presentation / export
    var estimatedDurationMinutes: Int
    var notes: String           // General preparation notes / scratch pad
    var isFavorite: Bool

    // MARK: - Initialiser

    init(
        title: String,
        passageReference: String = "",
        bookOfBible: BibleBook? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.subtitle = ""
        self.passageReference = passageReference
        self.bookOfBible = bookOfBible?.rawValue ?? ""
        self.status = SermonStatus.draft.rawValue
        self.datePrepared = nil
        self.datePreached = nil
        self.speakerName = ""
        self.location = ""
        self.bigIdea = ""
        self.aim = ""
        self.targetAudience = ""
        self.tags = []
        self.blocks = []
        self.series = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.estimatedDurationMinutes = 30
        self.notes = ""
        self.isFavorite = false
    }

    // MARK: - Computed properties

    var statusEnum: SermonStatus {
        SermonStatus(rawValue: status) ?? .draft
    }

    /// Blocks sorted by their sortOrder, ascending.
    var blocksSorted: [SermonBlock] {
        blocks.sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Total word count across all block content.
    var wordCount: Int {
        blocks.reduce(0) { $0 + $1.content.wordCount }
    }

    // MARK: - Helpers

    func updateTimestamp() {
        updatedAt = Date()
    }
}
