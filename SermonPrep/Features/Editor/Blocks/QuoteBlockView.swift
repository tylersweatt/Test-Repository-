import SwiftUI

struct QuoteBlockView: View {
    @Bindable var block: SermonBlock
    var focusedBlockID: Binding<UUID?>
    @FocusState private var isFocused: Bool
    @State private var authorText = ""
    @State private var sourceText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                // Left quote mark decoration
                Text("\"")
                    .font(.system(size: 40))
                    .foregroundStyle(BlockType.quote.accentColor.opacity(0.3))
                    .offset(y: -8)

                TextEditor(text: $block.content)
                    .font(.body.italic())
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .frame(minHeight: 60)
                    .focused($isFocused)
                    .onChange(of: isFocused) { _, f in if f { focusedBlockID.wrappedValue = block.id } }
                    .overlay(alignment: .topLeading) {
                        if block.content.isEmpty {
                            Text("Enter quotation...")
                                .foregroundStyle(.tertiary)
                                .font(.body.italic())
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                        }
                    }
            }

            HStack {
                TextField("— Author", text: Binding(
                    get: { block.illustrationMetadata?.sourceAuthor ?? "" },
                    set: { val in
                        var m = block.illustrationMetadata ?? .empty
                        m.sourceAuthor = val.isEmpty ? nil : val
                        block.illustrationMetadata = m
                    }
                ))
                .textFieldStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)

                TextField("Source", text: Binding(
                    get: { block.illustrationMetadata?.sourceTitle ?? "" },
                    set: { val in
                        var m = block.illustrationMetadata ?? .empty
                        m.sourceTitle = val.isEmpty ? nil : val
                        block.illustrationMetadata = m
                    }
                ))
                .textFieldStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.leading, 48)
        }
    }
}
