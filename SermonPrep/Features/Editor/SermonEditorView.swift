import SwiftUI
import SwiftData

// MARK: - SermonEditorView

struct SermonEditorView: View {
    let sermonID: UUID

    @Environment(\.modelContext) private var modelContext
    @Query private var sermons: [Sermon]

    var sermon: Sermon? { sermons.first { $0.id == sermonID } }

    var body: some View {
        if let sermon = sermon {
            SermonEditorContentView(sermon: sermon)
        } else {
            ContentUnavailableView(
                "Sermon Not Found",
                systemImage: "doc.text.magnifyingglass",
                description: Text("This sermon may have been deleted.")
            )
        }
    }
}

// MARK: - SermonEditorContentView

struct SermonEditorContentView: View {
    @Bindable var sermon: Sermon
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SermonEditorViewModel?
    @FocusState private var focusedBlockID: UUID?

    // Provides a stable ViewModel, creating it on first access via .onAppear.
    private var vm: SermonEditorViewModel {
        viewModel ?? SermonEditorViewModel(sermon: sermon, modelContext: modelContext)
    }

    var body: some View {
        let vm = self.vm
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Editor header
                    editorHeader(vm: vm)
                        .padding(.bottom, 8)

                    Divider()

                    // Block list
                    let sortedBlocks = vm.sortedBlocks
                    ForEach(sortedBlocks) { block in
                        VStack(spacing: 0) {
                            AddBlockButton(afterBlockID: block.id) { type, afterID in
                                vm.insertBlock(type: type, afterBlockID: afterID)
                            }

                            BlockView(
                                block: block,
                                focusedBlockID: Binding(
                                    get: { focusedBlockID },
                                    set: { focusedBlockID = $0 }
                                ),
                                onDelete: { vm.deleteBlock(id: block.id) },
                                onDuplicate: { vm.duplicateBlock(id: block.id) },
                                onInsertBelow: { type in
                                    vm.insertBlock(type: type, afterBlockID: block.id)
                                },
                                onMoveUp: {
                                    let sorted = vm.sortedBlocks
                                    if let idx = sorted.firstIndex(where: { $0.id == block.id }),
                                       idx > 0 {
                                        vm.moveBlock(
                                            fromOffsets: IndexSet(integer: idx),
                                            toOffset: idx - 1
                                        )
                                    }
                                },
                                onMoveDown: {
                                    let sorted = vm.sortedBlocks
                                    if let idx = sorted.firstIndex(where: { $0.id == block.id }),
                                       idx < sorted.count - 1 {
                                        vm.moveBlock(
                                            fromOffsets: IndexSet(integer: idx),
                                            toOffset: idx + 2
                                        )
                                    }
                                },
                                onChangeType: { newType in
                                    block.blockType = newType.rawValue
                                    vm.save()
                                },
                                onSaveToLibrary: {
                                    vm.saveBlockToIllustrationLibrary(blockID: block.id)
                                }
                            )
                            .id(block.id)
                        }
                    }

                    // Add block button at the bottom
                    AddBlockButton(afterBlockID: vm.sortedBlocks.last?.id) { type, afterID in
                        vm.insertBlock(type: type, afterBlockID: afterID)
                    }
                    .padding(.vertical, 8)

                    // Empty state
                    if vm.sortedBlocks.isEmpty {
                        emptyEditorPrompt
                    }

                    Spacer(minLength: 100)
                }
            }
        }
        .navigationTitle(sermon.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            editorToolbar(vm: vm)
        }
        .sheet(isPresented: Binding(
            get: { vm.isShowingMetadata },
            set: { vm.isShowingMetadata = $0 }
        )) {
            SermonMetadataSheet(sermon: sermon)
        }
        .sheet(isPresented: Binding(
            get: { vm.isShowingPresentation },
            set: { vm.isShowingPresentation = $0 }
        )) {
            PresentationView(sermon: sermon)
        }
        .sheet(isPresented: Binding(
            get: { vm.isShowingScripturePicker },
            set: { vm.isShowingScripturePicker = $0 }
        )) {
            ScripturePickerSheet { meta in
                vm.insertBlock(
                    type: .scripture,
                    afterBlockID: vm.scriptureInsertAfterID ?? vm.sortedBlocks.last?.id
                )
                if let newBlock = vm.sortedBlocks.last(where: { $0.blockTypeEnum == .scripture }) {
                    newBlock.scriptureMetadata = meta
                }
                vm.isShowingScripturePicker = false
            }
        }
        .onChange(of: focusedBlockID) { _, newID in
            vm.focusedBlockID = newID
        }
        .onAppear {
            if viewModel == nil {
                viewModel = SermonEditorViewModel(sermon: sermon, modelContext: modelContext)
            }
        }
    }

    // MARK: - Header

    @ViewBuilder
    func editorHeader(vm: SermonEditorViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Sermon Title", text: $sermon.title, axis: .vertical)
                .font(.largeTitle.bold())
                .textFieldStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .onChange(of: sermon.title) { _, _ in vm.save() }

            if !sermon.subtitle.isEmpty {
                TextField(
                    "Subtitle",
                    text: Binding(
                        get: { sermon.subtitle },
                        set: { sermon.subtitle = $0 }
                    )
                )
                .font(.title3)
                .foregroundStyle(.secondary)
                .textFieldStyle(.plain)
                .padding(.horizontal, 20)
            }

            HStack(spacing: 12) {
                Label(sermon.passageReference, systemImage: "book.closed.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let series = sermon.series {
                    Label(series.title, systemImage: "folder.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                StatusBadge(status: sermon.statusEnum)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            vm.isShowingMetadata = true
        }
    }

    // MARK: - Empty state

    var emptyEditorPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle")
                .font(.system(size: 48))
                .foregroundStyle(.quaternary)
            Text("Start writing your sermon")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Tap + above to add your first block")
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    func editorToolbar(vm: SermonEditorViewModel) -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                vm.isShowingPresentation = true
            } label: {
                Label("Present", systemImage: "play.rectangle.fill")
            }
        }

        ToolbarItem(placement: .automatic) {
            Menu {
                Button {
                    vm.isShowingMetadata = true
                } label: {
                    Label("Sermon Details", systemImage: "info.circle")
                }
                Divider()
                Button {
                    Task { await exportSermon(sermon: sermon, format: .plainText) }
                } label: {
                    Label("Export as Text", systemImage: "doc.text")
                }
                Button {
                    Task { await exportSermon(sermon: sermon, format: .pdf) }
                } label: {
                    Label("Export as PDF", systemImage: "doc.richtext")
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }

        ToolbarItem(placement: .status) {
            Text("\(vm.wordCount) words \u{00B7} ~\(vm.estimatedMinutes) min")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Export

    private func exportSermon(sermon: Sermon, format: ExportFormat) async {
        guard let url = try? await ExportManager.export(sermon: sermon, format: format) else { return }
        #if os(iOS)
        await MainActor.run {
            let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                root.present(av, animated: true)
            }
        }
        #else
        await MainActor.run {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
}
