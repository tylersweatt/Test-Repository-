import SwiftUI
import UniformTypeIdentifiers

// MARK: - ExportFormat

enum ExportFormat {
    case plainText
    case pdf
}

// MARK: - ExportManager

struct ExportManager {

    // MARK: - Main export entry point

    static func export(sermon: Sermon, format: ExportFormat) async throws -> URL {
        switch format {
        case .plainText:
            return try exportPlainText(sermon: sermon)
        case .pdf:
            return try exportPDF(sermon: sermon)
        }
    }

    // MARK: - Plain text export

    private static func exportPlainText(sermon: Sermon) throws -> URL {
        let text = buildPlainText(sermon: sermon)
        let fileName = sanitizeFilename(sermon.title) + ".txt"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try text.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func buildPlainText(sermon: Sermon) -> String {
        var lines: [String] = []
        lines.append(sermon.title.uppercased())
        if !sermon.subtitle.isEmpty {
            lines.append(sermon.subtitle)
        }
        lines.append(sermon.passageReference)
        lines.append(sermon.datePrepared.shortDisplay)
        lines.append(String(repeating: "=", count: 60))
        lines.append("")

        for block in sermon.blocksSorted {
            guard block.blockTypeEnum.showInPresentation else { continue }
            lines.append("[\(block.blockTypeEnum.displayName.uppercased())]")
            if block.blockTypeEnum == .outline,
               let meta = block.outlineMetadata {
                lines.append("\(meta.pointNumber) \(block.content)")
            } else if block.blockTypeEnum == .scripture,
                      let meta = block.scriptureMetadata {
                lines.append("\(meta.referenceString) (\(meta.translation))")
                lines.append(block.content)
            } else if block.blockTypeEnum == .quote {
                lines.append("\"\(block.content)\"")
                let meta = block.illustrationMetadata
                if let author = meta?.sourceAuthor, !author.isEmpty {
                    lines.append("  — \(author)")
                }
                if let src = meta?.sourceTitle, !src.isEmpty {
                    lines.append("  \(src)")
                }
            } else {
                lines.append(block.content)
            }
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - PDF export

    private static func exportPDF(sermon: Sermon) throws -> URL {
        let plainText = buildPlainText(sermon: sermon)
        let fileName = sanitizeFilename(sermon.title) + ".pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        #if os(iOS)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.label
            ]
            let attrStr = NSAttributedString(string: plainText, attributes: attrs)
            let margin: CGFloat = 40
            let rect = CGRect(x: margin, y: margin,
                              width: 612 - margin * 2,
                              height: 792 - margin * 2)
            attrStr.draw(in: rect)
        }
        try data.write(to: url)
        #else
        // macOS: use NSAttributedString + NSPrintOperation via a temporary view
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12)
        ]
        let attrStr = NSAttributedString(string: plainText, attributes: attrs)
        let data = try attrStr.data(
            from: NSRange(location: 0, length: attrStr.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.plain]
        )
        try data.write(to: url)
        #endif

        return url
    }

    // MARK: - Helpers

    private static func sanitizeFilename(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\:*?\"<>|")
        return name
            .components(separatedBy: invalid)
            .joined(separator: "-")
            .trimmingCharacters(in: .whitespaces)
    }
}
