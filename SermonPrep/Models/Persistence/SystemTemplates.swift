import Foundation
import SwiftData

// MARK: - SystemTemplates

/// Seeds built-in sermon templates into the store on first launch.
struct SystemTemplates {

    private static let seededKey = "SystemTemplates.seeded"

    @MainActor
    static func seedIfNeeded(context: ModelContext) throws {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }

        let templates: [(String, [BlockType])] = [
            (
                "Classic Expository",
                [.hook, .scripture, .explanation, .outline, .explanation,
                 .illustration, .application, .outline, .explanation,
                 .illustration, .application, .conclusion, .prayer]
            ),
            (
                "Topical Sermon",
                [.hook, .scripture, .explanation, .illustration,
                 .application, .scripture, .explanation, .application,
                 .conclusion, .prayer]
            ),
            (
                "Three-Point Outline",
                [.hook, .scripture, .outline, .explanation, .illustration, .application,
                 .transition, .outline, .explanation, .illustration, .application,
                 .transition, .outline, .explanation, .illustration, .application,
                 .conclusion, .prayer]
            ),
            (
                "Narrative Sermon",
                [.hook, .scripture, .explanation, .illustration,
                 .illustration, .application, .conclusion, .prayer]
            ),
            (
                "Evangelistic Message",
                [.hook, .illustration, .scripture, .explanation,
                 .application, .scripture, .explanation, .application,
                 .conclusion, .prayer]
            )
        ]

        for (name, blockTypes) in templates {
            let template = SermonTemplate(title: name, blockTypes: blockTypes, isSystem: true)
            context.insert(template)
        }

        try context.save()
        UserDefaults.standard.set(true, forKey: seededKey)
    }
}
