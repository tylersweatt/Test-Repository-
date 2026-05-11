import SwiftUI
import SwiftData

struct SeriesListView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Series.sortOrder) private var allSeries: [Series]
    @State private var isShowingNewSeries = false

    var body: some View {
        List {
            ForEach(allSeries) { series in
                NavigationLink(destination: SeriesDetailView(series: series)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(series.title)
                                .font(.headline)
                            if let desc = series.sermonDescription, !desc.isEmpty {
                                Text(desc)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Text(series.dateRange)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        Text("\(series.sermonCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.quaternary)
                            .clipShape(Capsule())
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        modelContext.delete(series)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Series")
        .overlay {
            if allSeries.isEmpty {
                ContentUnavailableView(
                    "No Series",
                    systemImage: "folder",
                    description: Text("Create a series to group related sermons.")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingNewSeries = true
                } label: {
                    Label("New Series", systemImage: "folder.badge.plus")
                }
            }
            EditButton()
        }
        .sheet(isPresented: $isShowingNewSeries) {
            SeriesFormView { series in
                modelContext.insert(series)
                try? modelContext.save()
            }
        }
    }
}
