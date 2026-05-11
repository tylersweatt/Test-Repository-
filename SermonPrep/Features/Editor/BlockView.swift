import SwiftUI

// MARK: - BlockView

struct BlockView: View {
    @Bindable var block: SermonBlock
    var focusedBlockID: Binding<UUID?>
    var onDelete: () -> Void
    var onDuplicate: () -> Void
    var onInsertBelow: (BlockType) -> Void
    var onMoveUp: () -> Void
    var onMoveDown: () -> Void
    var onChangeType: (BlockType) -> Void
    var onSaveToLibrary: (() -> Void)?

    @State private var isShowingTypePicker = false
    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            BlockTypeIndicator(blockType: block.blockTypeEnum)
                .padding(.leading, 16)
                .padding(.top, 14)

            VStack(alignment: .leading, spacing: 4) {
                // Type chip (tappable to change type) + actions menu
                HStack {
                    BlockTypeChip(blockType: block.blockTypeEnum) {
                        isShowingTypePicker = true
                    }
                    Spacer()
                    if isHovered || focusedBlockID.wrappedValue == block.id {
                        blockActionsMenu
                    }
                }
                .padding(.top, 10)

                // Type-specific content view
                blockContentView
                    .padding(.bottom, 10)
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
        }
        .background(
            block.blockTypeEnum == .note
                ? Color.yellow.opacity(0.06)
                : Color.clear
        )
        #if os(macOS)
        .onHover { isHovered = $0 }
        #endif
        .contextMenu {
            contextMenuItems
        }
        .popover(isPresented: $isShowingTypePicker) {
            blockTypeChangeMenu
        }
    }

    // MARK: - Content dispatch

    @ViewBuilder
    var blockContentView: some View {
        switch block.blockTypeEnum {
        case .scripture:
            ScriptureBlockView(block: block, focusedBlockID: focusedBlockID)
        case .outline:
            OutlineBlockView(block: block, focusedBlockID: focusedBlockID)
        case .illustration:
            IllustrationBlockView(
                block: block,
                focusedBlockID: focusedBlockID,
                onSaveToLibrary: onSaveToLibrary
            )
        case .quote:
            QuoteBlockView(block: block, focusedBlockID: focusedBlockID)
        case .note:
            NoteBlockView(block: block, focusedBlockID: focusedBlockID)
        case .hook, .explanation, .application, .prayer, .transition, .conclusion:
            SimpleTextBlockView(
                block: block,
                focusedBlockID: focusedBlockID,
                placeholder: placeholderText(for: block.blockTypeEnum)
            )
        }
    }

    // MARK: - Actions menu

    var blockActionsMenu: some View {
        Menu {
            contextMenuItems
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(.secondary)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    @ViewBuilder
    var contextMenuItems: some View {
        Button { onDuplicate() } label: {
            Label("Duplicate Block", systemImage: "doc.on.doc")
        }
        Button { onMoveUp() } label: {
            Label("Move Up", systemImage: "arrow.up")
        }
        Button { onMoveDown() } label: {
            Label("Move Down", systemImage: "arrow.down")
        }
        if block.blockTypeEnum == .illustration {
            Divider()
            Button { onSaveToLibrary?() } label: {
                Label("Save to Illustration Library", systemImage: "bookmark")
            }
        }
        Divider()
        Button(role: .destructive) { onDelete() } label: {
            Label("Delete Block", systemImage: "trash")
        }
    }

    // MARK: - Type change popover

    var blockTypeChangeMenu: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Change Block Type")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                ForEach(BlockType.allCases) { type in
                    Button {
                        onChangeType(type)
                        isShowingTypePicker = false
                    } label: {
                        HStack {
                            Image(systemName: type.systemImage)
                                .foregroundStyle(type.accentColor)
                                .frame(width: 20)
                            Text(type.displayName)
                            Spacer()
                            if type == block.blockTypeEnum {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 8)
        }
        .frame(width: 240, height: 300)
    }

    // MARK: - Placeholder text

    private func placeholderText(for type: BlockType) -> String {
        switch type {
        case .hook:         return "Write your sermon opener..."
        case .explanation:  return "Explain the text..."
        case .application:  return "How does this apply to life today?"
        case .prayer:       return "Write a prayer..."
        case .transition:   return "Transition sentence..."
        case .conclusion:   return "Write your conclusion..."
        default:            return "Write here..."
        }
    }
}
