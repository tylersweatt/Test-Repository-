import SwiftUI
import SwiftData

struct SeriesDetailView: View {
    let series: Series
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    var sortedSermons: [Sermon] {
        series.sermons.sorted { $0.datePrepared ?? .distantPast < $1.datePrepared ?? .distantPast }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    if let desc = series.sermonDescription, !desc.isEmpty {
                        Text(desc)
                            .foregroundStyle(.secondary)
                    }
                    if let start = series.startDate {
                        Label(start.shortDisplay, systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Label(
                        "\(series.sermonCount) sermon\(series.sermonCount == 1 ? "" : "s")",
                        systemImage: "doc.text"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Sermons") {
                ForEach(sortedSermons) { sermon in
                    SermonCard(sermon: sermon)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appState.selectedSermonID = sermon.id
                        }
                }
            }
        }
        .navigationTitle(series.title)
    }
}
