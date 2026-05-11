import Foundation
import UniformTypeIdentifiers

// MARK: - ExportFormat

enum ExportFormat {
    case plainText
    case pdf
    case markdown

    var fileExtension: String {
        switch self {
        case .plainText: return "txt"
        case .pdf:       return "pdf"
        case .markdown:  return "md"
        }
    }
}

// MARK: - ExportManager

struct ExportManager {
    static func export(sermon: Sermon, format: ExportFormat) async throws -> URL {
        let content: Data
        let filename = "\(sanitizeFilename(sermon.title)).\(format.fileExtension)"

        switch format {
        case .plainText:
            let text = PlainTextExporter.export(sermon: sermon)
            content = text.data(using: .utf8) ?? Data()
        case .pdf:
            content = try await PDFExporter.export(sermon: sermon)
        case .markdown:
            let text = MarkdownExporter.export(sermon: sermon)
            content = text.data(using: .utf8) ?? Data()
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(filename)
        try content.write(to: url)
        return url
    }

    private static func sanitizeFilename(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\:*?\"<>|")
        return name
            .components(separatedBy: invalid)
            .joined(separator: "-")
            .trimmingCharacters(in: .whitespaces)
    }
}
