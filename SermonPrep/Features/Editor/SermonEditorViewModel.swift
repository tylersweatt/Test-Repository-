import SwiftUI
import SwiftData
import Observation

// MARK: - SermonEditorViewModel

@Observable
class SermonEditorViewModel {
    var sermon: Sermon
    var focusedBlockID: UUID? = nil
    var isShowingMetadata = false
    var isShowingScripturePicker = false
    var scriptureInsertAfterID: UUID? = nil
    var isShowingExportMenu = false
    var isShowingPresentation = false
    var isReordering = false
    var isDragging = false

    private var modelContext: ModelContext

    init(sermon: Sermon, modelContext: ModelContext) {
        self.sermon = sermon
        self.modelContext = modelContext
    }

    // MARK: - Computed

    var sortedBlocks: [SermonBlock] {
        sermon.blocks.sorted { $0.sortOrder < $1.sortOrder }
    }

    var wordCount: Int { sermon.wordCount }

    var estimatedMinutes: Int {
        sermon.blocks
            .reduce("") { $0 + " " + $1.content }
            .estimatedPreachingMinutes
    }

    // MARK: - Block operations

    func insertBlock(type: BlockType, afterBlockID: UUID?) {
        let sorted = sortedBlocks
        let insertIndex: Int
        if let afterID = afterBlockID,
           let afterBlock = sorted.first(where: { $0.id == afterID }) {
            insertIndex = afterBlock.sortOrder + 1
        } else {
            insertIndex = (sorted.last?.sortOrder ?? -1) + 1
        }
        // Shift existing blocks up to make room
        for block in sorted where block.sortOrder >= insertIndex {
            block.sortOrder += 1
        }
        let newBlock = SermonBlock(blockType: type, sortOrder: insertIndex, sermon: sermon)
        modelContext.insert(newBlock)
        sermon.blocks.append(newBlock)
        sermon.updateTimestamp()
        focusedBlockID = newBlock.id
        try? modelContext.save()
    }

    func deleteBlock(id: UUID) {
        guard let block = sermon.blocks.first(where: { $0.id == id }) else { return }
        let deletedOrder = block.sortOrder
        // Determine next focus target before deletion
        let sorted = sortedBlocks
        if let idx = sorted.firstIndex(where: { $0.id == id }) {
            if idx > 0 {
                focusedBlockID = sorted[idx - 1].id
            } else if idx + 1 < sorted.count {
                focusedBlockID = sorted[idx + 1].id
            } else {
                focusedBlockID = nil
            }
        }
        modelContext.delete(block)
        // Reindex remaining blocks
        for remaining in sermon.blocks where remaining.sortOrder > deletedOrder {
            remaining.sortOrder -= 1
        }
        sermon.updateTimestamp()
        try? modelContext.save()
    }

    func moveBlock(fromOffsets: IndexSet, toOffset: Int) {
        var sorted = sortedBlocks
        sorted.move(fromOffsets: fromOffsets, toOffset: toOffset)
        for (index, block) in sorted.enumerated() {
            block.sortOrder = index
        }
        sermon.updateTimestamp()
        try? modelContext.save()
    }

    func duplicateBlock(id: UUID) {
        guard let original = sermon.blocks.first(where: { $0.id == id }) else { return }
        let newSortOrder = original.sortOrder + 1
        // Shift blocks after the original
        for block in sermon.blocks where block.sortOrder >= newSortOrder && block.id != original.id {
            block.sortOrder += 1
        }
        let copy = SermonBlock(blockType: original.blockTypeEnum, sortOrder: newSortOrder, sermon: sermon)
        copy.content = original.content
        copy.metadata = original.metadata
        modelContext.insert(copy)
        sermon.blocks.append(copy)
        sermon.updateTimestamp()
        focusedBlockID = copy.id
        try? modelContext.save()
    }

    func saveBlockToIllustrationLibrary(blockID: UUID) {
        guard let block = sermon.blocks.first(where: { $0.id == blockID }),
              block.blockTypeEnum == .illustration else { return }
        let illus = IllustrationLibrary(
            title: String(block.content.prefix(80)),
            content: block.content,
            illustrationType: block.illustrationMetadata?.illustrationTypeEnum ?? .story,
            sourceTitle: block.illustrationMetadata?.sourceTitle,
            sourceAuthor: block.illustrationMetadata?.sourceAuthor,
            tags: block.illustrationMetadata?.tags ?? []
        )
        modelContext.insert(illus)
        try? modelContext.save()
    }

    func save() {
        sermon.updateTimestamp()
        try? modelContext.save()
    }
}
