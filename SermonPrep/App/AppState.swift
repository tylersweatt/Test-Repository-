import SwiftUI
import Observation

// MARK: - AppState

@Observable
class AppState {
    var selectedSermonID: UUID?
    var sidebarSelection: SidebarSection? = .allSermons
    var isShowingNewSermonSheet = false
    var isShowingSettings = false
    var searchText = ""
    var filterStatus: SermonStatus? = nil
    var sortOrder: SermonSortOrder = .datePreparedDesc
}

// MARK: - SidebarSection

enum SidebarSection: Hashable, CaseIterable {
    case allSermons
    case bySeries
    case byBook
    case byStatus
    case templates
    case illustrations

    var displayName: String {
        switch self {
        case .allSermons:   return "All Sermons"
        case .bySeries:     return "By Series"
        case .byBook:       return "By Book"
        case .byStatus:     return "By Status"
        case .templates:    return "Templates"
        case .illustrations: return "Illustrations"
        }
    }

    var systemImage: String {
        switch self {
        case .allSermons:   return "doc.text.fill"
        case .bySeries:     return "folder.fill"
        case .byBook:       return "book.fill"
        case .byStatus:     return "tag.fill"
        case .templates:    return "square.grid.2x2.fill"
        case .illustrations: return "lightbulb.fill"
        }
    }
}

// MARK: - SermonSortOrder

enum SermonSortOrder: String, CaseIterable {
    case datePreparedDesc = "Date Prepared"
    case datePreparedAsc  = "Date Prepared (Oldest)"
    case titleAsc         = "Title A\u{2013}Z"
    case titleDesc        = "Title Z\u{2013}A"
    case bookOfBible      = "Book of Bible"
}
