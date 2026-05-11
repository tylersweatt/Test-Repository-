import SwiftUI

struct ScriptureBlockView: View {
    @Bindable var block: SermonBlock
    var focusedBlockID: Binding<UUID?>
    @State private var isShowingPicker = false
    @EnvironmentObject private var settings: AppSettings

    var meta: ScriptureMetadata? { block.scriptureMetadata }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Scripture reference header button
            Button {
                isShowingPicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "book.closed.fill")
                        .foregroundStyle(BlockType.scripture.accentColor)
                    if let meta = meta, !meta.verseText.isEmpty {
                        Text(meta.referenceString)
                            .font(.subheadline.weight(.semibold))
                        Text("(\(meta.translation))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Tap to look up scripture...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if meta?.isKeyVerse == true {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    }
                }
            }
            .buttonStyle(.plain)

            // Verse text display
            if let meta = meta, !meta.verseText.isEmpty {
                Text("\"\(meta.verseText)\"")
                    .font(.body.italic())
                    .foregroundStyle(.primary.opacity(0.85))
                    .padding(.leading, 16)
                    .padding(10)
                    .background(BlockType.scripture.accentColor.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                // Key verse toggle
                HStack {
                    Toggle(isOn: Binding(
                        get: { block.scriptureMetadata?.isKeyVerse ?? false },
                        set: { val in
                            var m = block.scriptureMetadata ?? ScriptureMetadata.empty()
                            m.isKeyVerse = val
                            block.scriptureMetadata = m
                        }
                    )) {
                        Text("Key Verse")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .toggleStyle(.checkbox)
                    .controlSize(.small)
                }
            }

            // Annotation / notes on this passage
            TextEditor(text: $block.content)
                .font(.body)
                .scrollContentBackground(.hidden)
                .background(.clear)
                .frame(minHeight: 40)
                .overlay(alignment: .topLeading) {
                    if block.content.isEmpty {
                        Text("Add notes on this passage...")
                            .foregroundStyle(.tertiary)
                            .font(.body)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                }
        }
        .sheet(isPresented: $isShowingPicker) {
            ScripturePickerSheet { newMeta in
                block.scriptureMetadata = newMeta
                block.updateTimestamp()
                isShowingPicker = false
            }
        }
    }
}
