import Foundation
import SQLite3

struct ScriptureVerse: Identifiable {
    let id: String        // e.g. "GEN.1.1"
    let book: String      // e.g. "Genesis"
    let chapter: Int
    let verse: Int
    let text: String
    var reference: String { "\(book) \(chapter):\(verse)" }
}

class ScriptureDatabase {
    static let shared = ScriptureDatabase()
    private var db: OpaquePointer?
    private var isOpen = false

    private init() {
        openDatabase()
    }

    private func openDatabase() {
        guard let path = Bundle.main.path(forResource: "kjv", ofType: "sqlite") else {
            print("KJV database not found in bundle. Place kjv.sqlite in SermonPrep/Resources/Scripture/")
            return
        }
        if sqlite3_open(path, &db) == SQLITE_OK {
            isOpen = true
        }
    }

    func verses(book: String, chapter: Int) -> [ScriptureVerse] {
        guard isOpen, let db = db else { return [] }
        var results: [ScriptureVerse] = []
        let query = "SELECT b, c, v, t FROM verses WHERE b = ? AND c = ? ORDER BY v"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, book, -1, nil)
            sqlite3_bind_int(stmt, 2, Int32(chapter))
            while sqlite3_step(stmt) == SQLITE_ROW {
                let bookName = String(cString: sqlite3_column_text(stmt, 0))
                let ch = Int(sqlite3_column_int(stmt, 1))
                let v = Int(sqlite3_column_int(stmt, 2))
                let text = String(cString: sqlite3_column_text(stmt, 3))
                results.append(ScriptureVerse(id: "\(bookName).\(ch).\(v)", book: bookName, chapter: ch, verse: v, text: text))
            }
        }
        sqlite3_finalize(stmt)
        return results
    }

    func searchVerses(query: String) -> [ScriptureVerse] {
        guard isOpen, let db = db else { return [] }
        var results: [ScriptureVerse] = []
        let sql = "SELECT b, c, v, t FROM verses WHERE t LIKE ? LIMIT 50"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            let pattern = "%\(query)%"
            sqlite3_bind_text(stmt, 1, pattern, -1, nil)
            while sqlite3_step(stmt) == SQLITE_ROW {
                let bookName = String(cString: sqlite3_column_text(stmt, 0))
                let ch = Int(sqlite3_column_int(stmt, 1))
                let v = Int(sqlite3_column_int(stmt, 2))
                let text = String(cString: sqlite3_column_text(stmt, 3))
                results.append(ScriptureVerse(id: "\(bookName).\(ch).\(v)", book: bookName, chapter: ch, verse: v, text: text))
            }
        }
        sqlite3_finalize(stmt)
        return results
    }

    // API.Bible integration
    func fetchVerse(bookID: String, chapter: Int, verseStart: Int, verseEnd: Int?, translation: String, apiKey: String) async throws -> String {
        let bibleID = apiBibleID(for: translation)
        let verseRange: String
        if let end = verseEnd {
            verseRange = "\(bookID).\(chapter).\(verseStart)-\(bookID).\(chapter).\(end)"
        } else {
            verseRange = "\(bookID).\(chapter).\(verseStart)"
        }
        let urlString = "https://api.scripture.api.bible/v1/bibles/\(bibleID)/passages/\(verseRange)?content-type=text&include-verse-numbers=false"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dataObj = json["data"] as? [String: Any],
           let content = dataObj["content"] as? String {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        throw URLError(.cannotParseResponse)
    }

    private func apiBibleID(for translation: String) -> String {
        switch translation.uppercased() {
        case "ESV":  return "f421fe261da7624f-01"
        case "NIV":  return "78a9f6124f344018-01"
        case "KJV":  return "de4e12af7f28f599-01"
        case "CSB":  return "a556c5305ee15c3f-01"
        case "NKJV": return "40072c4a5aba4022-01"
        default:     return "de4e12af7f28f599-01"  // default to KJV
        }
    }
}
