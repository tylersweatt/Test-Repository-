import SwiftUI

struct NoteBlockView: View {
    @Bindable var block: SermonBlock
    var focusedBlockID: Binding<UUID?>
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "eye.slash")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("Private note — not shown in presentation")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            TextEditor(text: $block.content)
                .font(.body)
                .scrollContentBackground(.hidden)
                .background(.clear)
                .frame(minHeight: 50)
                .focused($isFocused)
                .onChange(of: isFocused) { _, f in if f { focusedBlockID.wrappedValue = block.id } }
                .overlay(alignment: .topLeading) {
                    if block.content.isEmpty {
                        Text("Private notes for the preacher only...")
                            .foregroundStyle(.tertiary)
                            .font(.body)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                }
        }
        .padding(8)
        .background(Color.yellow.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
