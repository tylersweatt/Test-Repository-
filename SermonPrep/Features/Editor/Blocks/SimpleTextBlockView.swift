import SwiftUI

struct SimpleTextBlockView: View {
    @Bindable var block: SermonBlock
    var focusedBlockID: Binding<UUID?>
    var placeholder: String

    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: $block.content)
            .font(.body)
            .scrollContentBackground(.hidden)
            .background(.clear)
            .frame(minHeight: 60)
            .focused($isFocused)
            .onChange(of: isFocused) { _, focused in
                if focused { focusedBlockID.wrappedValue = block.id }
            }
            .overlay(alignment: .topLeading) {
                if block.content.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                        .font(.body)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
    }
}
