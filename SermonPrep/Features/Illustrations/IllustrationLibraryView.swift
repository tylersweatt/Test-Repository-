import SwiftUI
import SwiftData

// MARK: - IllustrationLibraryView

struct IllustrationLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \IllustrationLibrary.createdAt, order: .reverse) private var illustrations: [IllustrationLibrary]
    @State private var searchText = ""
    @State private var filterType: IllustrationType? = nil
    @State private var isShowingNewIllustration = false

    var filtered: [IllustrationLibrary] {
        illustrations.filter { illus in
            let matchesSearch = searchText.isEmpty
                || illus.title.localizedCaseInsensitiveContains(searchText)
                || illus.content.localizedCaseInsensitiveContains(searchText)
                || illus.tags.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
            let matchesType = filterType == nil || illus.illustrationTypeEnum == filterType
            return matchesSearch && matchesType
        }
    }

    var body: some View {
        List {
            ForEach(filtered) { illus in
                IllustrationRow(illustration: illus)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            modelContext.delete(illus)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            illus.isFavorite.toggle()
                            illus.updateTimestamp()
                        } label: {
                            Label(
                                illus.isFavorite ? "Unfavourite" : "Favourite",
                                systemImage: illus.isFavorite ? "star.slash" : "star"
                            )
                        }
                        .tint(.yellow)
                    }
            }
        }
        .navigationTitle("Illustration Library")
        .searchable(text: $searchText, prompt: "Search illustrations...")
        .overlay {
            if filtered.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "No Illustrations" : "No Results",
                    systemImage: "lightbulb",
                    description: Text(
                        searchText.isEmpty
                            ? "Save illustrations from sermon blocks or tap + to add one."
                            : "Try a different search term."
                    )
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingNewIllustration = true
                } label: {
                    Label("New Illustration", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .automatic) {
                Menu {
                    Picker("Filter by Type", selection: $filterType) {
                        Text("All").tag(nil as IllustrationType?)
                        ForEach(IllustrationType.allCases) { type in
                            Label(type.displayName, systemImage: type.systemImage).tag(type as IllustrationType?)
                        }
                    }
                } label: {
                    Label(
                        "Filter",
                        systemImage: filterType == nil
                            ? "line.3.horizontal.decrease.circle"
                            : "line.3.horizontal.decrease.circle.fill"
                    )
                }
            }
        }
        .sheet(isPresented: $isShowingNewIllustration) {
            NewIllustrationSheet()
        }
    }
}

// MARK: - IllustrationRow

struct IllustrationRow: View {
    let illustration: IllustrationLibrary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(illustration.title)
                        .font(.headline)
                        .lineLimit(2)
                    Label(
                        illustration.illustrationTypeEnum.displayName,
                        systemImage: illustration.illustrationTypeEnum.systemImage
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                Spacer()
                if illustration.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }

            Text(illustration.content)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            if let author = illustration.sourceAuthor, !author.isEmpty {
                Text("— \(author)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if !illustration.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(illustration.tags, id: \.self) { tag in
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

// MARK: - NewIllustrationSheet

struct NewIllustrationSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var content = ""
    @State private var illustrationType: IllustrationType = .story
    @State private var sourceTitle = ""
    @State private var sourceAuthor = ""
    @State private var tags: [String] = []

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Illustration") {
                    TextField("Title", text: $title)
                    Picker("Type", selection: $illustrationType) {
                        ForEach(IllustrationType.allCases) { type in
                            Label(type.displayName, systemImage: type.systemImage).tag(type)
                        }
                    }
                }
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)
                }
                Section("Source") {
                    TextField("Source Title", text: $sourceTitle)
                    TextField("Author / Speaker", text: $sourceAuthor)
                }
                Section("Tags") {
                    TagTokenField(tags: $tags)
                }
            }
            .navigationTitle("New Illustration")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveIllustration() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private func saveIllustration() {
        let illus = IllustrationLibrary(
            title: title.trimmingCharacters(in: .whitespaces),
            content: content.trimmingCharacters(in: .whitespaces),
            illustrationType: illustrationType,
            sourceTitle: sourceTitle.isEmpty ? nil : sourceTitle,
            sourceAuthor: sourceAuthor.isEmpty ? nil : sourceAuthor,
            tags: tags
        )
        modelContext.insert(illus)
        dismiss()
    }
}
