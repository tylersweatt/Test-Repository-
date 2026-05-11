import Foundation

struct MarkdownExporter {
    static func export(sermon: Sermon) -> String {
        var lines: [String] = []
        lines.append("# \(sermon.title)")
        lines.append("")
        lines.append("**Passage:** \(sermon.passageReference)")
        if let series = sermon.series { lines.append("**Series:** \(series.title)") }
        if let date = sermon.datePrepared {
            lines.append("**Date:** \(date.mediumDisplay)")
        }
        if !sermon.tags.isEmpty { lines.append("**Tags:** \(sermon.tags.joined(separator: ", "))") }
        lines.append("")
        lines.append("---")
        lines.append("")

        for block in sermon.blocksSorted {
            guard block.blockTypeEnum.showInPresentation else { continue }

            switch block.blockTypeEnum {
            case .scripture:
                if let meta = block.scriptureMetadata {
                    lines.append("> **\(meta.referenceString)** *(\(meta.translation))*")
                    lines.append("> ")
                    lines.append("> \(meta.verseText)")
                }
                if !block.content.isEmpty { lines.append(""); lines.append(block.content) }
            case .outline:
                if let meta = block.outlineMetadata {
                    let prefix: String
                    switch meta.level {
                    case 1:  prefix = "## "
                    case 2:  prefix = "### "
                    default: prefix = "#### "
                    }
                    lines.append("\(prefix)\(meta.pointNumber). \(block.content)")
                }
            case .hook, .conclusion:
                lines.append("*\(block.content)*")
            case .illustration:
                lines.append("**Illustration:** \(block.content)")
                if let meta = block.illustrationMetadata, let author = meta.sourceAuthor {
                    lines.append("— *\(author)*")
                }
            case .quote:
                lines.append("> \(block.content)")
                if let author = block.illustrationMetadata?.sourceAuthor {
                    lines.append("> — *\(author)*")
                }
            default:
                lines.append(block.content)
            }
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }
}
