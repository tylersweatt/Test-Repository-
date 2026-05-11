import SwiftUI

// MARK: - PassageReferenceField

struct PassageReferenceField: View {
    @Binding var reference: String
    @Binding var bookOfBible: String

    @State private var isShowingBookPicker = false

    var selectedBook: BibleBook? { BibleBook(rawValue: bookOfBible) }

    var body: some View {
        HStack {
            Button {
                isShowingBookPicker = true
            } label: {
                HStack {
                    Text(selectedBook?.rawValue ?? "Select Book")
                        .foregroundStyle(selectedBook == nil ? .secondary : .primary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            TextField("Reference (e.g. 8:1-11)", text: $reference)
                .textFieldStyle(.roundedBorder)
        }
        .sheet(isPresented: $isShowingBookPicker) {
            NavigationStack {
                List {
                    ForEach(Testament.allCases, id: \.self) { testament in
                        Section(testament.rawValue) {
                            ForEach(BibleBook.allCases.filter { $0.testament == testament }) { book in
                                Button(book.rawValue) {
                                    bookOfBible = book.rawValue
                                    isShowingBookPicker = false
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                }
                .navigationTitle("Select Book")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { isShowingBookPicker = false }
                    }
                }
            }
        }
    }
}
