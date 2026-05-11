import SwiftUI

struct ScripturePickerSheet: View {
    var onSelect: (ScriptureMetadata) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings

    @State private var selectedBook: BibleBook = .john
    @State private var chapter = 3
    @State private var verseStart = 16
    @State private var verseEnd: Int? = nil
    @State private var searchText = ""
    @State private var searchResults: [ScriptureVerse] = []
    @State private var verses: [ScriptureVerse] = []
    @State private var isSearchMode = false
    @State private var selectedTranslation: String = "KJV"
    @State private var esvPreviewText: String = ""
    @State private var esvFetchTask: Task<Void, Never>? = nil
    @State private var isFetchingESV = false
    @State private var esvFetchError: String? = nil

    var chapterCount: Int { selectedBook.chapterCount }
    var verseCount: Int { verses.count }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Translation picker
                Picker("Translation", selection: $selectedTranslation) {
                    ForEach(["KJV", "ESV", "NIV", "CSB", "NKJV"], id: \.self) { t in
                        Text(t).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if isSearchMode {
                    searchResultsView
                } else {
                    referencePickerView
                }
            }
            .navigationTitle("Scripture Lookup")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .searchable(text: $searchText, isPresented: $isSearchMode, prompt: "Search for a verse...")
            .onChange(of: searchText) { _, q in
                if q.count >= 3 {
                    searchResults = ScriptureDatabase.shared.searchVerses(query: q)
                }
            }
            .onChange(of: selectedBook) { _, _ in loadVerses(); fetchESVPreviewIfNeeded() }
            .onChange(of: chapter) { _, _ in loadVerses(); fetchESVPreviewIfNeeded() }
            .onChange(of: verseStart) { _, _ in fetchESVPreviewIfNeeded() }
            .onChange(of: selectedTranslation) { _, _ in fetchESVPreviewIfNeeded() }
            .onAppear {
                loadVerses()
                selectedTranslation = settings.defaultTranslation
                fetchESVPreviewIfNeeded()
            }
            .onDisappear { esvFetchTask?.cancel() }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Insert") { insertScripture() }
                }
            }
        }
    }

    var referencePickerView: some View {
        VStack {
            HStack {
                Picker("Book", selection: $selectedBook) {
                    ForEach(BibleBook.allCases) { book in
                        Text(book.rawValue).tag(book)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("Chapter", selection: $chapter) {
                    ForEach(1...max(1, chapterCount), id: \.self) { ch in
                        Text("\(ch)").tag(ch)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)

                Picker("Verse", selection: $verseStart) {
                    ForEach(1...max(1, verseCount == 0 ? 176 : verseCount), id: \.self) { v in
                        Text("\(v)").tag(v)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
            }
            .frame(height: 200)
            .padding(.horizontal)

            // Verse preview
            versePreviewBox

            Spacer()
        }
    }

    var searchResultsView: some View {
        List(searchResults) { verse in
            VStack(alignment: .leading, spacing: 4) {
                Text(verse.reference)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(verse.text)
                    .lineLimit(3)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                var meta = ScriptureMetadata.empty(translation: selectedTranslation)
                meta.book = verse.book
                meta.chapter = verse.chapter
                meta.verseStart = verse.verse
                meta.verseText = verse.text
                onSelect(meta)
            }
        }
    }

    @ViewBuilder
    var versePreviewBox: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(selectedBook.rawValue) \(chapter):\(verseStart)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if selectedTranslation == "ESV" {
                if !settings.hasESVKey {
                    Label("Add your ESV API key in Settings to preview ESV text.", systemImage: "key")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if isFetchingESV {
                    HStack(spacing: 8) {
                        ProgressView().controlSize(.small)
                        Text("Fetching ESV…").font(.caption).foregroundStyle(.secondary)
                    }
                } else if let err = esvFetchError {
                    Label(err, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else if !esvPreviewText.isEmpty {
                    Text("\"\(esvPreviewText)\"")
                        .font(.body.italic())
                }
            } else if let verse = verses.first(where: { $0.verse == verseStart }) {
                Text("\"\(verse.text)\"")
                    .font(.body.italic())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
        .animation(.easeInOut(duration: 0.2), value: isFetchingESV)
    }

    private func fetchESVPreviewIfNeeded() {
        guard selectedTranslation == "ESV", settings.hasESVKey else {
            esvPreviewText = ""
            esvFetchError = nil
            return
        }
        esvFetchTask?.cancel()
        esvFetchTask = Task {
            // Small debounce so rapid picker scrolling doesn't fire many requests
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            let reference = "\(selectedBook.rawValue) \(chapter):\(verseStart)"
            await MainActor.run { isFetchingESV = true; esvFetchError = nil }
            do {
                let text = try await ScriptureDatabase.shared.fetchESVPassage(
                    reference: reference,
                    apiKey: settings.esvApiKey
                )
                await MainActor.run {
                    esvPreviewText = text
                    isFetchingESV = false
                }
            } catch {
                await MainActor.run {
                    esvFetchError = error.localizedDescription
                    isFetchingESV = false
                }
            }
        }
    }

    private func loadVerses() {
        verses = ScriptureDatabase.shared.verses(book: selectedBook.rawValue, chapter: chapter)
    }

    private func insertScripture() {
        // Use the fetched ESV text when available; fall back to offline KJV
        let verseText: String
        if selectedTranslation == "ESV", !esvPreviewText.isEmpty {
            verseText = esvPreviewText
        } else {
            verseText = verses.first(where: { $0.verse == verseStart })?.text ?? ""
        }
        var meta = ScriptureMetadata.empty(translation: selectedTranslation)
        meta.book = selectedBook.rawValue
        meta.chapter = chapter
        meta.verseStart = verseStart
        meta.verseEnd = verseEnd
        meta.verseText = verseText
        onSelect(meta)
    }
}
