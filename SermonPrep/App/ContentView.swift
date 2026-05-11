import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            SplitLayoutView()
        } else {
            PhoneLayoutView()
        }
        #else
        SplitLayoutView()
        #endif
    }
}

// MARK: - SplitLayoutView

struct SplitLayoutView: View {
    @Environment(AppState.self) private var appState
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic

    var body: some View {
        @Bindable var state = appState
        NavigationSplitView(columnVisibility: $columnVisibility) {
            LibrarySidebarView()
        } content: {
            switch appState.sidebarSelection {
            case .allSermons, .byStatus, nil:
                SermonListView()
            case .bySeries:
                SeriesListView()
            case .byBook:
                ByBookListView()
            case .templates:
                TemplateListView()
            case .illustrations:
                IllustrationLibraryView()
            }
        } detail: {
            if let id = appState.selectedSermonID {
                SermonEditorView(sermonID: id)
            } else {
                EmptyDetailView()
            }
        }
    }
}

// MARK: - PhoneLayoutView

struct PhoneLayoutView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: SidebarSection = .allSermons

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                SermonListView()
            }
            .tabItem { Label("Sermons", systemImage: "doc.text.fill") }
            .tag(SidebarSection.allSermons)

            NavigationStack {
                SeriesListView()
            }
            .tabItem { Label("Series", systemImage: "folder.fill") }
            .tag(SidebarSection.bySeries)

            NavigationStack {
                IllustrationLibraryView()
            }
            .tabItem { Label("Illustrations", systemImage: "lightbulb.fill") }
            .tag(SidebarSection.illustrations)

            NavigationStack {
                TemplateListView()
            }
            .tabItem { Label("Templates", systemImage: "square.grid.2x2.fill") }
            .tag(SidebarSection.templates)
        }
    }
}

// MARK: - EmptyDetailView

struct EmptyDetailView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 64))
                .foregroundStyle(.quaternary)
            Text("Select a sermon to begin editing")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("or create a new one from the list")
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
