import SwiftUI
import SwiftData

struct IllustrationLibraryView: View {
    @Query(sort: \IllustrationLibrary.createdAt, order: .reverse) private var illustrations: [IllustrationLibrary]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var filterType: IllustrationType? = nil
    @State private var isShowingNew = false

    var filtered: [IllustrationLibrary] {
        illustrations.filter { ill in
            let matchSearch = searchText.isEmpty ||
                ill.title.localizedCaseInsensitiveContains(searchText) ||
                ill.content.localizedCaseInsensitiveContains(searchText)
            let matchType = filterType == nil || ill.illustrationType == filterType?.rawValue
            return matchSearch && matchType
        }
    }

    var body: some View {
        List {
            ForEach(filtered) { ill in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(ill.title)
                            .font(.headline)
                            .lineLimit(1)
                        Spacer()
                        if ill.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                        }
                        if let type = IllustrationType(rawValue: ill.illustrationType) {
                            Label(type.displayName, systemImage: type.systemImage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text(ill.content)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                    if let author = ill.sourceAuthor ?? ill.sourceTitle {
                        Text("— \(author)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
                .swipeActions {
                    Button(role: .destructive) {
                        modelContext.delete(ill)
                    } label: { Label("Delete", systemImage: "trash") }

                    Button {
                        ill.isFavorite.toggle()
                    } label: {
                        Label(
                            ill.isFavorite ? "Unfavorite" : "Favorite",
                            systemImage: ill.isFavorite ? "star.slash" : "star"
                        )
                    }
                    .tint(.yellow)
                }
            }
        }
        .navigationTitle("Illustrations")
        .searchable(text: $searchText, prompt: "Search illustrations...")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { isShowingNew = true } label: {
                    Label("New", systemImage: "plus")
                }
            }
            ToolbarItem {
                Menu {
                    Picker("Filter", selection: $filterType) {
                        Text("All").tag(nil as IllustrationType?)
                        ForEach(IllustrationType.allCases) { t in
                            Label(t.displayName, systemImage: t.systemImage).tag(t as IllustrationType?)
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .overlay {
            if filtered.isEmpty {
                ContentUnavailableView(
                    "No Illustrations",
                    systemImage: "lightbulb",
                    description: Text("Illustrations you save from sermons will appear here.")
                )
            }
        }
        .sheet(isPresented: $isShowingNew) {
            NewIllustrationSheet()
        }
    }
}

// MARK: - NewIllustrationSheet

struct NewIllustrationSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var author = ""
    @State private var source = ""
    @State private var type = IllustrationType.story

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)
                }
                Section("Source") {
                    Picker("Type", selection: $type) {
                        ForEach(IllustrationType.allCases) { t in
                            Label(t.displayName, systemImage: t.systemImage).tag(t)
                        }
                    }
                    TextField("Author", text: $author)
                    TextField("Source / Title", text: $source)
                }
            }
            .navigationTitle("New Illustration")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let ill = IllustrationLibrary(
                            title: title.isEmpty ? "Untitled" : title,
                            content: content,
                            illustrationType: type,
                            sourceTitle: source.isEmpty ? nil : source,
                            sourceAuthor: author.isEmpty ? nil : author,
                            tags: []
                        )
                        modelContext.insert(ill)
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
