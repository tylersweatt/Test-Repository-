import Foundation

// MARK: - String word-count helpers

extension String {

    /// The number of whitespace-separated words in the string.
    var wordCount: Int {
        let words = components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }

    /// An estimate of how many minutes the text takes to read aloud (average reading rate).
    var estimatedReadingMinutes: Int {
        max(1, wordCount / 130)
    }

    /// An estimate of how many minutes the text takes to preach (slower than reading).
    var estimatedPreachingMinutes: Int {
        max(1, wordCount / 100)
    }
}
