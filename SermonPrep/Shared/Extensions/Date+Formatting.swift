import Foundation

// MARK: - Date formatting helpers

extension Date {

    /// e.g. "Jan 12, 2025"
    var shortDisplay: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    /// e.g. "January 12, 2025"
    var mediumDisplay: String {
        formatted(date: .long, time: .omitted)
    }

    /// e.g. "yesterday", "2 days ago", "in 3 weeks"
    var relativeDisplay: String {
        formatted(.relative(presentation: .named))
    }
}

// MARK: - Optional<Date> helpers

extension Optional where Wrapped == Date {

    /// Returns the short display string for the date, or an em-dash when nil.
    var shortDisplay: String {
        self?.shortDisplay ?? "—"
    }
}
