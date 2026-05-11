import SwiftUI
import SwiftData

@main
struct SermonPrepApp: App {
    @StateObject private var settings = AppSettings.shared
    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainerFactory.makeContainer()
        } catch {
            // Fallback to local-only if CloudKit unavailable
            let schema = Schema([
                Sermon.self,
                Series.self,
                SermonBlock.self,
                SermonTemplate.self,
                IllustrationLibrary.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try! ModelContainer(for: schema, configurations: [config])
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environmentObject(settings)
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .commands {
            AppCommands()
        }
        #endif

        #if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(settings)
        }
        #endif
    }
}
