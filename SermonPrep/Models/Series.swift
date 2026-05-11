import Foundation
import SwiftData

// MARK: - Series

@Model
final class Series {

    // MARK: Identity
    @Attribute(.unique) var id: UUID

    // MARK: Core fields
    var title: String

    /// A brief description of the sermon series.
    /// Named `sermonDescription` to avoid conflict with the Swift `description` property.
    var sermonDescription: String?

    var startDate: Date?
    var sortOrder: Int

    // MARK: Timestamps
    var createdAt: Date

    // MARK: Relationships
    @Relationship(inverse: \Sermon.series)
    var sermons: [Sermon]

    // MARK: - Initialiser

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.sermonDescription = nil
        self.startDate = nil
        self.sortOrder = 0
        self.createdAt = Date()
        self.sermons = []
    }

    // MARK: - Computed properties

    var sermonCount: Int {
        sermons.count
    }

    /// A formatted representation of the series start date, or an em-dash if unavailable.
    var dateRange: String {
        guard let start = startDate else { return "—" }
        return start.shortDisplay
    }
}
