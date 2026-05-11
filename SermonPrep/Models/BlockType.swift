import SwiftUI

// MARK: - BlockType

enum BlockType: String, Codable, CaseIterable, Identifiable {
    case hook        = "hook"
    case outline     = "outline"
    case scripture   = "scripture"
    case explanation = "explanation"
    case illustration = "illustration"
    case application = "application"
    case quote       = "quote"
    case prayer      = "prayer"
    case transition  = "transition"
    case conclusion  = "conclusion"
    case note        = "note"

    var id: String { rawValue }

    // MARK: Display name

    var displayName: String {
        switch self {
        case .hook:         return "Hook"
        case .outline:      return "Outline Point"
        case .scripture:    return "Scripture"
        case .explanation:  return "Explanation"
        case .illustration: return "Illustration"
        case .application:  return "Application"
        case .quote:        return "Quote"
        case .prayer:       return "Prayer"
        case .transition:   return "Transition"
        case .conclusion:   return "Conclusion"
        case .note:         return "Note"
        }
    }

    // MARK: SF Symbol

    var systemImage: String {
        switch self {
        case .hook:         return "arrow.hook"
        case .outline:      return "list.bullet.indent"
        case .scripture:    return "book.closed"
        case .explanation:  return "text.alignleft"
        case .illustration: return "photo"
        case .application:  return "hand.raised"
        case .quote:        return "quote.bubble"
        case .prayer:       return "hands.sparkles"
        case .transition:   return "arrow.right.circle"
        case .conclusion:   return "checkmark.circle"
        case .note:         return "note.text"
        }
    }

    // MARK: Short label

    var shortLabel: String {
        switch self {
        case .hook:         return "HOOK"
        case .outline:      return "OUTLINE"
        case .scripture:    return "SCRIPTURE"
        case .explanation:  return "EXPLAIN"
        case .illustration: return "ILLUSTR"
        case .application:  return "APPLY"
        case .quote:        return "QUOTE"
        case .prayer:       return "PRAYER"
        case .transition:   return "TRANS"
        case .conclusion:   return "CONCL"
        case .note:         return "NOTE"
        }
    }

    // MARK: Accent color — delegates to Color+BlockTypes extension

    var accentColor: Color { color }

    // MARK: Description

    var description: String {
        switch self {
        case .hook:
            return "An opening statement or question designed to capture the audience's attention."
        case .outline:
            return "A structured main point or sub-point that organises the flow of the sermon."
        case .scripture:
            return "A Bible passage that forms the foundation or support for the sermon's message."
        case .explanation:
            return "Expository content that unpacks the meaning of a text or theological concept."
        case .illustration:
            return "A story, analogy, or example that makes an abstract truth concrete and memorable."
        case .application:
            return "Practical guidance on how the congregation can live out the sermon's truth."
        case .quote:
            return "A citation from a theologian, author, or other source that supports a point."
        case .prayer:
            return "A written prayer to lead the congregation in worship or response."
        case .transition:
            return "A bridging statement that moves the sermon smoothly from one section to the next."
        case .conclusion:
            return "The closing summary or call to action that brings the sermon to a powerful finish."
        case .note:
            return "A private reminder or research note visible only during preparation, not in presentation."
        }
    }

    // MARK: Presentation visibility

    var showInPresentation: Bool {
        switch self {
        case .note: return false
        default:    return true
        }
    }
}

// MARK: - IllustrationType

enum IllustrationType: String, Codable, CaseIterable, Identifiable {
    case story     = "story"
    case statistic = "statistic"
    case quote     = "quote"
    case video     = "video"
    case personal  = "personal"
    case analogy   = "analogy"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .story:     return "Story"
        case .statistic: return "Statistic"
        case .quote:     return "Quote"
        case .video:     return "Video Clip"
        case .personal:  return "Personal Experience"
        case .analogy:   return "Analogy"
        }
    }

    var systemImage: String {
        switch self {
        case .story:     return "book"
        case .statistic: return "chart.bar"
        case .quote:     return "quote.closing"
        case .video:     return "play.rectangle"
        case .personal:  return "person"
        case .analogy:   return "arrow.triangle.2.circlepath"
        }
    }
}
