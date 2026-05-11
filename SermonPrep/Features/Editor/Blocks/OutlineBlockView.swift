import SwiftUI

struct OutlineBlockView: View {
    @Bindable var block: SermonBlock
    var focusedBlockID: Binding<UUID?>

    @FocusState private var isFocused: Bool

    var meta: OutlineMetadata { block.outlineMetadata ?? OutlineMetadata.main(number: 1) }

    var indentPadding: CGFloat { CGFloat((meta.level - 1)) * 24 }

    var levelFont: Font {
        switch meta.level {
        case 1: return .title3.bold()
        case 2: return .headline
        default: return .body
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Spacer().frame(width: indentPadding)

            Text(meta.pointNumber + ".")
                .font(levelFont)
                .foregroundStyle(BlockType.outline.accentColor)
                .frame(width: meta.level == 1 ? 28 : 20, alignment: .trailing)

            TextField("Outline point...", text: $block.content, axis: .vertical)
                .font(levelFont)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .onChange(of: isFocused) { _, f in
                    if f { focusedBlockID.wrappedValue = block.id }
                }
        }
        .padding(.vertical, 4)
    }
}
