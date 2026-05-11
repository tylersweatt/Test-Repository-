import SwiftUI
import SwiftData

// MARK: - SermonListView

struct SermonListView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Sermon.datePrepared, order: .reverse) private var allSermons: [Sermon]
    @State private var searchText = ""
    @State private var filterStatus: SermonStatus? = nil
    @State private var isShowingNewSermon = false

    var filteredSermons: [Sermon] {
        allSermons.filter { sermon in
            let matchesSearch = searchText.isEmpty
                || sermon.title.localizedCaseInsensitiveContains(searchText)
                || sermon.passageReference.localizedCaseInsensitiveContains(searchText)
                || sermon.tags.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
            let matchesFilter = filterStatus == nil || sermon.statusEnum == filterStatus
            return matchesSearch && matchesFilter
        }
    }

    var body: some View {
        @Bindable var state = appState
        List(selection: $state.selectedSermonID) {
            ForEach(filteredSermons) { sermon in
                SermonCard(sermon: sermon)
                    .tag(sermon.id)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteSermon(sermon)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            sermon.status = SermonStatus.archived.rawValue
                            sermon.updateTimestamp()
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        .tint(.orange)
                    }
            }
        }
        .navigationTitle("All Sermons")
        .searchable(text: $searchText, prompt: "Search sermons...")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingNewSermon = true
                } label: {
                    Label("New Sermon", systemImage: "square.and.pencil")
                }
            }
            ToolbarItem(placement: .automatic) {
                Menu {
                    Picker("Filter by Status", selection: $filterStatus) {
                        Text("All").tag(nil as SermonStatus?)
                        ForEach(SermonStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status as SermonStatus?)
                        }
                    }
                } label: {
                    Label(
                        "Filter",
                        systemImage: filterStatus == nil
                            ? "line.3.horizontal.decrease.circle"
                            : "line.3.horizontal.decrease.circle.fill"
                    )
                }
            }
        }
        .overlay {
            if filteredSermons.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "No Sermons" : "No Results",
                    systemImage: searchText.isEmpty ? "doc.text" : "magnifyingglass",
                    description: Text(
                        searchText.isEmpty
                            ? "Tap + to create your first sermon."
                            : "Try a different search term."
                    )
                )
            }
        }
        .sheet(isPresented: $isShowingNewSermon) {
            NewSermonSheet()
        }
    }

    private func deleteSermon(_ sermon: Sermon) {
        modelContext.delete(sermon)
    }
}

// MARK: - ByBookListView

struct ByBookListView: View {
    @Query private var sermons: [Sermon]
    @Environment(AppState.self) private var appState

    var sermonsByBook: [(book: BibleBook, sermons: [Sermon])] {
        let grouped = Dictionary(grouping: sermons) {
            BibleBook(rawValue: $0.bookOfBible) ?? .genesis
        }
        return BibleBook.allCases.compactMap { book in
            guard let bookSermons = grouped[book], !bookSermons.isEmpty else { return nil }
            return (book: book, sermons: bookSermons)
        }
    }

    var body: some View {
        List {
            ForEach(sermonsByBook, id: \.book) { item in
                DisclosureGroup {
                    ForEach(item.sermons) { sermon in
                        SermonCard(sermon: sermon)
                            .onTapGesture {
                                appState.selectedSermonID = sermon.id
                            }
                    }
                } label: {
                    HStack {
                        Text(item.book.rawValue)
                        Spacer()
                        Text("\(item.sermons.count)")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("By Book")
    }
}
