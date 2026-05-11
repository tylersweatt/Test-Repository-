import SwiftUI
import SwiftData

// MARK: - SeriesListView

struct SeriesListView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Series.sortOrder) private var allSeries: [Series]
    @State private var isShowingNewSeries = false

    var body: some View {
        List {
            ForEach(allSeries) { series in
                SeriesRow(series: series)
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
                    description: Text("Tap + to create your first sermon series.")
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
        }
        .sheet(isPresented: $isShowingNewSeries) {
            NewSeriesSheet()
        }
    }
}

// MARK: - SeriesRow

struct SeriesRow: View {
    let series: Series

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(series.title)
                .font(.headline)
            if let desc = series.sermonDescription, !desc.isEmpty {
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            HStack {
                Text(series.dateRange)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("\(series.sermonCount) sermons")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - NewSeriesSheet

struct NewSeriesSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var hasStartDate = false

    var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Series") {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                Section("Schedule") {
                    Toggle("Has Start Date", isOn: $hasStartDate)
                    if hasStartDate {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Series")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createSeries() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private func createSeries() {
        let series = Series(title: title.trimmingCharacters(in: .whitespaces))
        series.sermonDescription = description.isEmpty ? nil : description
        series.startDate = hasStartDate ? startDate : nil
        modelContext.insert(series)
        dismiss()
    }
}
