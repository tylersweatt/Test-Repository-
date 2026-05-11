import SwiftUI

struct ApplicationBlockView: View {
    @Bindable var block: SermonBlock
    var focusedBlockID: Binding<UUID?>
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextEditor(text: $block.content)
                .font(.body)
                .scrollContentBackground(.hidden)
                .background(.clear)
                .frame(minHeight: 60)
                .focused($isFocused)
                .onChange(of: isFocused) { _, f in if f { focusedBlockID.wrappedValue = block.id } }
                .overlay(alignment: .topLeading) {
                    if block.content.isEmpty {
                        Text("How does this apply to life today?")
                            .foregroundStyle(.tertiary)
                            .font(.body)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                }
            // "So what?" prompt label
            Label("Application: So what?", systemImage: "arrow.forward.circle")
                .font(.caption2)
                .foregroundStyle(BlockType.application.accentColor.opacity(0.7))
        }
    }
}
