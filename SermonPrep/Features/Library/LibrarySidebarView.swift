import SwiftUI
import SwiftData

// MARK: - LibrarySidebarView

struct LibrarySidebarView: View {
    @Environment(AppState.self) private var appState
    @Query private var sermons: [Sermon]
    @Query private var series: [Series]
    @State private var isShowingNewSermon = false
    @State private var isShowingSettings = false

    var body: some View {
        @Bindable var state = appState
        List(selection: $state.sidebarSelection) {
            Section("Library") {
                ForEach(
                    SidebarSection.allCases.filter { $0 != .templates && $0 != .illustrations },
                    id: \.self
                ) { section in
                    Label {
                        HStack {
                            Text(section.displayName)
                            Spacer()
                            if section == .allSermons {
                                Text("\(sermons.count)")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            } else if section == .bySeries {
                                Text("\(series.count)")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    } icon: {
                        Image(systemName: section.systemImage)
                    }
                    .tag(section as SidebarSection?)
                }
            }

            Section("Create") {
                Label(SidebarSection.templates.displayName, systemImage: SidebarSection.templates.systemImage)
                    .tag(SidebarSection.templates as SidebarSection?)
                Label(SidebarSection.illustrations.displayName, systemImage: SidebarSection.illustrations.systemImage)
                    .tag(SidebarSection.illustrations as SidebarSection?)
            }
        }
        .navigationTitle("SermonPrep")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingNewSermon = true
                } label: {
                    Label("New Sermon", systemImage: "square.and.pencil")
                }
            }
            #if os(macOS)
            ToolbarItem(placement: .automatic) {
                Button {
                    isShowingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }
            }
            #endif
        }
        .sheet(isPresented: $isShowingNewSermon) {
            NewSermonSheet()
        }
        .sheet(isPresented: $isShowingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
    }
}
