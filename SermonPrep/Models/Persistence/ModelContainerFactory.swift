import Foundation
import SwiftData

// MARK: - ModelContainerFactory

struct ModelContainerFactory {

    // MARK: Schema

    static var allModels: [any PersistentModel.Type] {
        [
            Sermon.self,
            Series.self,
            SermonBlock.self,
            SermonTemplate.self,
            IllustrationLibrary.self
        ]
    }

    // MARK: Production container (CloudKit sync)

    /// Creates the production ModelContainer backed by CloudKit for cross-device sync.
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema(allModels)
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        let container = try ModelContainer(for: schema, configurations: [config])
        // Seed system templates on first launch (runs on the main actor asynchronously).
        Task { @MainActor in
            try? SystemTemplates.seedIfNeeded(context: container.mainContext)
        }
        return container
    }

    // MARK: Preview container (in-memory)

    /// Creates an ephemeral in-memory ModelContainer pre-populated with sample data for SwiftUI Previews.
    static func makePreviewContainer() throws -> ModelContainer {
        let schema = Schema(allModels)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        Task { @MainActor in
            SampleData.insertAll(context: container.mainContext)
        }
        return container
    }
}
