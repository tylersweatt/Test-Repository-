import SwiftUI

// MARK: - ScripturePickerSheet

/// A sheet that lets the user build a ScriptureMetadata value (book, chapter, verse, translation)
/// and passes it back via the `onConfirm` closure.
struct ScripturePickerSheet: View {
    var onConfirm: (ScriptureMetadata) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings

    @State private var selectedBook: BibleBook = .john
    @State private var chapter: Int = 3
    @State private var verseStart: Int = 16
    @State private var verseEnd: Int = 16
    @State private var hasVerseEnd: Bool = false
    @State private var translation: String = "KJV"
    @State private var verseText: String = ""
    @State private var isKeyVerse: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Book & Passage") {
                    Picker("Book", selection: $selectedBook) {
                        ForEach(Testament.allCases, id: \.self) { testament in
                            ForEach(BibleBook.allCases.filter { $0.testament == testament }) { book in
                                Text(book.rawValue).tag(book)
                            }
                        }
                    }
                    .pickerStyle(.menu)

                    Stepper("Chapter: \(chapter)", value: $chapter, in: 1...selectedBook.chapterCount)
                    Stepper("Verse Start: \(verseStart)", value: $verseStart, in: 1...176)
                    Toggle("Verse Range", isOn: $hasVerseEnd)
                    if hasVerseEnd {
                        Stepper("Verse End: \(verseEnd)", value: $verseEnd, in: verseStart...176)
                    }
                }

                Section("Translation") {
                    Picker("Translation", selection: $translation) {
                        ForEach(["KJV", "NIV", "ESV", "NKJV", "NLT", "NASB", "CSB", "MSG"], id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Verse Text (optional)") {
                    TextEditor(text: $verseText)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                }

                Section("Options") {
                    Toggle("Mark as Key Verse", isOn: $isKeyVerse)
                }
            }
            .navigationTitle("Add Scripture")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Insert") { confirm() }
                }
            }
            .onAppear {
                translation = settings.defaultTranslation
            }
        }
    }

    private func confirm() {
        let meta = ScriptureMetadata(
            translation: translation,
            book: selectedBook.rawValue,
            chapter: chapter,
            verseStart: verseStart,
            verseEnd: hasVerseEnd ? verseEnd : nil,
            verseText: verseText,
            isKeyVerse: isKeyVerse
        )
        onConfirm(meta)
        dismiss()
    }
}
