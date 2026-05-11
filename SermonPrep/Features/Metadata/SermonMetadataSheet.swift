import SwiftUI
import SwiftData

struct SermonMetadataSheet: View {
    @Bindable var sermon: Sermon
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Series.title) private var allSeries: [Series]

    @State private var selectedBook: BibleBook
    @State private var isShowingNewSeries = false

    init(sermon: Sermon) {
        self.sermon = sermon
        self._selectedBook = State(initialValue: BibleBook(rawValue: sermon.bookOfBible) ?? .genesis)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Sermon Info") {
                    TextField("Title", text: $sermon.title)
                    TextField("Subtitle (optional)", text: $sermon.subtitle)
                }

                Section("Scripture") {
                    Picker("Book of Bible", selection: $selectedBook) {
                        ForEach(BibleBook.allCases) { book in
                            Text(book.rawValue).tag(book)
                        }
                    }
                    .onChange(of: selectedBook) { _, book in
                        sermon.bookOfBible = book.rawValue
                    }
                    TextField("Passage Reference", text: $sermon.passageReference)
                }

                Section("Status & Dates") {
                    Picker("Status", selection: Binding(
                        get: { sermon.statusEnum },
                        set: { sermon.status = $0.rawValue }
                    )) {
                        ForEach(SermonStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    DatePicker("Date Prepared", selection: Binding(
                        get: { sermon.datePrepared ?? Date() },
                        set: { sermon.datePrepared = $0 }
                    ), displayedComponents: .date)

                    if sermon.statusEnum == .preached || sermon.datePreached != nil {
                        DatePicker("Date Preached", selection: Binding(
                            get: { sermon.datePreached ?? Date() },
                            set: { sermon.datePreached = $0 }
                        ), displayedComponents: .date)
                    } else {
                        Button("Mark as Preached") {
                            sermon.status = SermonStatus.preached.rawValue
                            sermon.datePreached = Date()
                        }
                    }
                }

                Section("Organization") {
                    Picker("Series", selection: $sermon.series) {
                        Text("None").tag(nil as Series?)
                        ForEach(allSeries) { s in
                            Text(s.title).tag(s as Series?)
                        }
                    }
                    Button("New Series...") { isShowingNewSeries = true }
                        .font(.callout)

                    TagTokenField(tags: $sermon.tags, placeholder: "Add tags (comma-separated)...")
                }

                Section("Preparation") {
                    TextField("Big Idea (one sentence)", text: $sermon.bigIdea, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Aim / Purpose", text: $sermon.aim, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Target Audience", text: $sermon.targetAudience)
                }

                Section("Private Notes") {
                    TextEditor(text: $sermon.notes)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Sermon Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        sermon.updateTimestamp()
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingNewSeries) {
                SeriesFormView { newSeries in
                    modelContext.insert(newSeries)
                    sermon.series = newSeries
                    try? modelContext.save()
                }
            }
        }
    }
}
