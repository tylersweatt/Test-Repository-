import Foundation

// MARK: - ScriptureMetadata

struct ScriptureMetadata: Codable {

    /// Bible translation abbreviation, e.g. "KJV", "ESV", "NIV".
    var translation: String

    /// The raw value of a BibleBook case, e.g. "John".
    var book: String

    var chapter: Int
    var verseStart: Int
    var verseEnd: Int?
    var verseText: String
    var isKeyVerse: Bool

    // MARK: Computed

    /// Returns a human-readable reference string such as "John 3:16" or "Romans 8:1-11".
    var referenceString: String {
        var ref = "\(book) \(chapter):\(verseStart)"
        if let end = verseEnd, end > verseStart {
            ref += "-\(end)"
        }
        return ref
    }

    // MARK: Factory

    /// Returns an empty ScriptureMetadata defaulting to John 1:1 in the given translation.
    static func empty(translation: String = "KJV") -> ScriptureMetadata {
        ScriptureMetadata(
            translation: translation,
            book: BibleBook.john.rawValue,
            chapter: 1,
            verseStart: 1,
            verseEnd: nil,
            verseText: "",
            isKeyVerse: false
        )
    }
}
