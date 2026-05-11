import Foundation
import WebKit
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct PDFExporter {
    static func export(sermon: Sermon) async throws -> Data {
        let html = generateHTML(sermon: sermon)
        return await renderHTMLToPDF(html: html)
    }

    private static func generateHTML(sermon: Sermon) -> String {
        var body = ""

        for block in sermon.blocksSorted {
            guard block.blockTypeEnum.showInPresentation else { continue }

            switch block.blockTypeEnum {
            case .scripture:
                if let meta = block.scriptureMetadata {
                    body += "<div class='scripture'>"
                    body += "<div class='scripture-ref'>\(meta.referenceString) (\(meta.translation))</div>"
                    body += "<div class='scripture-text'>&ldquo;\(htmlEscape(meta.verseText))&rdquo;</div>"
                    if !block.content.isEmpty {
                        body += "<div class='scripture-note'>\(htmlEscape(block.content))</div>"
                    }
                    body += "</div>"
                }
            case .outline:
                if let meta = block.outlineMetadata {
                    let tag: String
                    switch meta.level {
                    case 1:  tag = "h2"
                    case 2:  tag = "h3"
                    default: tag = "h4"
                    }
                    body += "<\(tag) class='outline'>\(meta.pointNumber). \(htmlEscape(block.content))</\(tag)>"
                }
            case .illustration:
                body += "<div class='illustration'><strong>Illustration:</strong> \(htmlEscape(block.content))</div>"
            case .quote:
                body += "<blockquote>\(htmlEscape(block.content))"
                if let author = block.illustrationMetadata?.sourceAuthor {
                    body += "<cite>— \(htmlEscape(author))</cite>"
                }
                body += "</blockquote>"
            default:
                body += "<div class='\(block.blockTypeEnum.rawValue)'>\(htmlEscape(block.content))</div>"
            }
        }

        let seriesLine = sermon.series.map { "<div class='meta'>Series: \($0.title)</div>" } ?? ""
        let dateStr: String
        if let date = sermon.datePrepared {
            dateStr = "<div class='meta'>Date: \(date.mediumDisplay)</div>"
        } else {
            dateStr = ""
        }

        return """
        <!DOCTYPE html><html><head><style>
        body { font-family: Georgia, serif; max-width: 700px; margin: 40px auto; color: #1a1a1a; line-height: 1.6; }
        h1 { font-size: 28px; margin-bottom: 4px; }
        .meta { color: #666; font-size: 14px; margin-bottom: 2px; }
        hr { margin: 24px 0; border: none; border-top: 1px solid #ddd; }
        .scripture { background: #f5f0ff; border-left: 4px solid #7c3aed; padding: 12px 16px; margin: 16px 0; border-radius: 4px; }
        .scripture-ref { font-weight: bold; color: #7c3aed; margin-bottom: 6px; }
        .scripture-text { font-style: italic; }
        .scripture-note { margin-top: 8px; color: #444; }
        h2.outline { color: #4f46e5; font-size: 22px; margin-top: 24px; }
        h3.outline { color: #4f46e5; font-size: 18px; margin-left: 20px; }
        h4.outline { color: #4f46e5; font-size: 16px; margin-left: 40px; }
        .illustration { background: #f0fdf4; border-left: 4px solid #16a34a; padding: 12px 16px; margin: 16px 0; border-radius: 4px; }
        blockquote { border-left: 4px solid #92400e; padding: 12px 16px; background: #fffbeb; margin: 16px 0; }
        blockquote cite { display: block; margin-top: 8px; font-size: 14px; color: #666; }
        div { margin: 12px 0; }
        </style></head><body>
        <h1>\(htmlEscape(sermon.title))</h1>
        <div class='meta'>Passage: \(htmlEscape(sermon.passageReference))</div>
        \(seriesLine)
        \(dateStr)
        <hr>
        \(body)
        </body></html>
        """
    }

    private static func htmlEscape(_ str: String) -> String {
        str.replacingOccurrences(of: "&", with: "&amp;")
           .replacingOccurrences(of: "<", with: "&lt;")
           .replacingOccurrences(of: ">", with: "&gt;")
           .replacingOccurrences(of: "\"", with: "&quot;")
    }

    @MainActor
    private static func renderHTMLToPDF(html: String) async -> Data {
        #if os(iOS)
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 612, height: 792))
        webView.loadHTMLString(html, baseURL: nil)
        try? await Task.sleep(for: .seconds(0.5))
        let config = WKPDFConfiguration()
        config.rect = CGRect(x: 0, y: 0, width: 612, height: 792)
        return (try? await webView.pdf(configuration: config)) ?? Data()
        #else
        // macOS: return UTF-8 encoded HTML as a simplified fallback
        return html.data(using: .utf8) ?? Data()
        #endif
    }
}
