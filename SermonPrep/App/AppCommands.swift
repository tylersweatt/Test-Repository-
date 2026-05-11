import SwiftUI

// MARK: - AppCommands

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Sermon") {
                NotificationCenter.default.post(name: .newSermon, object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)

            Button("New Series") {
                NotificationCenter.default.post(name: .newSeries, object: nil)
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
        }

        CommandMenu("Sermon") {
            Button("Export as PDF...") {
                NotificationCenter.default.post(name: .exportPDF, object: nil)
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])

            Button("Export as Plain Text...") {
                NotificationCenter.default.post(name: .exportText, object: nil)
            }

            Divider()

            Button("Presentation Mode") {
                NotificationCenter.default.post(name: .presentationMode, object: nil)
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])
        }
    }
}

// MARK: - Notification.Name extensions

extension Notification.Name {
    static let newSermon        = Notification.Name("newSermon")
    static let newSeries        = Notification.Name("newSeries")
    static let exportPDF        = Notification.Name("exportPDF")
    static let exportText       = Notification.Name("exportText")
    static let presentationMode = Notification.Name("presentationMode")
}
