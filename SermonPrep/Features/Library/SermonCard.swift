import SwiftUI
import SwiftData

// MARK: - SermonCard

struct SermonCard: View {
    let sermon: Sermon

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(sermon.title)
                        .font(.headline)
                        .lineLimit(2)
                    if !sermon.subtitle.isEmpty {
                        Text(sermon.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                StatusBadge(status: sermon.statusEnum)
            }

            HStack(spacing: 12) {
                Label(sermon.passageReference, systemImage: "book.closed")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let series = sermon.series {
                    Label(series.title, systemImage: "folder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            HStack {
                Text(sermon.datePrepared.shortDisplay)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                Spacer()

                if sermon.wordCount > 0 {
                    Text("\(sermon.wordCount) words")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            if !sermon.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(sermon.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.quaternary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - NewSermonSheet

struct NewSermonSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Query private var allSeries: [Series]

    @State private var title = ""
    @State private var passageReference = ""
    @State private var selectedBook: BibleBook = .john
    @State private var selectedSeries: Series? = nil
    @State private var datePrepared = Date()

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !passageReference.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Sermon") {
                    TextField("Title", text: $title)
                    TextField("Passage (e.g. Romans 8:1-11)", text: $passageReference)
                }

                Section("Scripture") {
                    Picker("Book of Bible", selection: $selectedBook) {
                        ForEach(BibleBook.allCases) { book in
                            Text(book.rawValue).tag(book)
                        }
                    }
                }

                Section("Details") {
                    DatePicker("Date Prepared", selection: $datePrepared, displayedComponents: .date)
                    Picker("Series", selection: $selectedSeries) {
                        Text("None").tag(nil as Series?)
                        ForEach(allSeries) { s in
                            Text(s.title).tag(s as Series?)
                        }
                    }
                }
            }
            .navigationTitle("New Sermon")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createSermon() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private func createSermon() {
        let sermon = Sermon(
            title: title.trimmingCharacters(in: .whitespaces),
            passageReference: passageReference.trimmingCharacters(in: .whitespaces),
            bookOfBible: selectedBook
        )
        sermon.series = selectedSeries
        sermon.datePrepared = datePrepared
        modelContext.insert(sermon)
        appState.selectedSermonID = sermon.id
        dismiss()
    }
}
