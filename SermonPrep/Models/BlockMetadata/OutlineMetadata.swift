import CoreGraphics
import Foundation

// MARK: - OutlineMetadata

struct OutlineMetadata: Codable {

    /// Hierarchy depth: 1 = main point (I, II, III), 2 = sub-point (A, B, C), 3 = sub-sub-point (1, 2, 3).
    var level: Int

    /// The display prefix that should appear before the outline text (e.g. "I.", "A.", "1.").
    var pointNumber: String

    // MARK: Factory helpers

    /// Creates a top-level roman-numeral main point.
    static func main(number: Int) -> OutlineMetadata {
        OutlineMetadata(level: 1, pointNumber: romanNumeral(for: number) + ".")
    }

    /// Creates a second-level alphabetic sub-point.
    static func sub(number: Int) -> OutlineMetadata {
        OutlineMetadata(level: 2, pointNumber: letter(for: number) + ".")
    }

    /// Creates a third-level numeric sub-sub-point.
    static func subsub(number: Int) -> OutlineMetadata {
        OutlineMetadata(level: 3, pointNumber: "\(number).")
    }

    // MARK: Indentation

    /// Returns the leading padding (in points) appropriate for the outline level.
    var indentLevel: CGFloat { CGFloat((level - 1)) * 20 }

    // MARK: Private helpers

    private static func romanNumeral(for n: Int) -> String {
        let numerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
                        "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX"]
        guard n >= 1, n <= numerals.count else { return "\(n)" }
        return numerals[n - 1]
    }

    private static func letter(for n: Int) -> String {
        let letters = ["A","B","C","D","E","F","G","H","I","J","K","L","M",
                       "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        guard n >= 1, n <= letters.count else { return "\(n)" }
        return letters[n - 1]
    }
}
