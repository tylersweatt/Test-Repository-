import Foundation

struct PlainTextExporter {
    static func export(sermon: Sermon) -> String {
        var lines: [String] = []
        lines.append(sermon.title.uppercased())
        lines.append(String(repeating: "=", count: sermon.title.count))
        lines.append("")
        lines.append("Passage: \(sermon.passageReference)")
        if let series = sermon.series { lines.append("Series: \(series.title)") }
        if let date = sermon.datePrepared {
            lines.append("Date: \(date.mediumDisplay)")
        }
        lines.append("")
        lines.append(String(repeating: "-", count: 60))
        lines.append("")

        for block in sermon.blocksSorted {
            guard block.blockTypeEnum.showInPresentation else { continue }

            switch block.blockTypeEnum {
            case .scripture:
                if let meta = block.scriptureMetadata {
                    lines.append("[\(meta.referenceString) — \(meta.translation)]")
                    lines.append("  \"\(meta.verseText)\"")
                }
                if !block.content.isEmpty { lines.append("  \(block.content)") }
            case .outline:
                if let meta = block.outlineMetadata {
                    let indent = String(repeating: "  ", count: meta.level - 1)
                    lines.append("\(indent)\(meta.pointNumber). \(block.content)")
                } else {
                    lines.append(block.content)
                }
            default:
                lines.append("[\(block.blockTypeEnum.displayName.uppercased())]")
                lines.append(block.content)
            }
            lines.append("")
        }

        if !sermon.notes.isEmpty {
            lines.append(String(repeating: "-", count: 60))
            lines.append("PRIVATE NOTES")
            lines.append(sermon.notes)
        }

        return lines.joined(separator: "\n")
    }
}
