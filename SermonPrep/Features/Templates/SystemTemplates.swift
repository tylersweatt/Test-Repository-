import SwiftData
import Foundation

struct SystemTemplates {
    static let all: [(title: String, description: String, blocks: [BlockType])] = [
        (
            title: "Expository",
            description: "Verse-by-verse through a passage with explanation and application",
            blocks: [.hook, .scripture, .explanation, .illustration, .application,
                     .scripture, .explanation, .application, .conclusion, .prayer]
        ),
        (
            title: "Topical (3-Point)",
            description: "Three main points each with scripture, illustration, and application",
            blocks: [.hook, .outline, .scripture, .explanation, .illustration, .application,
                     .outline, .scripture, .explanation, .illustration, .application,
                     .outline, .scripture, .explanation, .illustration, .application,
                     .conclusion, .prayer]
        ),
        (
            title: "Narrative",
            description: "Story arc structure — setting, conflict, climax, resolution",
            blocks: [.hook, .illustration, .scripture, .explanation, .illustration,
                     .scripture, .explanation, .application, .conclusion, .prayer]
        ),
        (
            title: "Evangelistic",
            description: "Gospel presentation for outreach services",
            blocks: [.hook, .illustration, .scripture, .explanation, .scripture,
                     .explanation, .illustration, .application, .scripture, .conclusion, .prayer]
        )
    ]

    @MainActor
    static func seedIfNeeded(context: ModelContext) throws {
        let descriptor = FetchDescriptor<SermonTemplate>(predicate: #Predicate { $0.isSystemTemplate == true })
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        for template in all {
            let t = SermonTemplate(title: template.title, blockTypes: template.blocks, isSystem: true)
            t.templateDescription = template.description
            context.insert(t)
        }
        try context.save()
    }
}
