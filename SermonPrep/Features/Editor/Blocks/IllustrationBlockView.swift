import SwiftUI

struct IllustrationBlockView: View {
    @Bindable var block: SermonBlock
    var focusedBlockID: Binding<UUID?>
    var onSaveToLibrary: (() -> Void)?

    @FocusState private var isFocused: Bool
    @State private var isMetaExpanded = false

    var meta: IllustrationMetadata {
        get { block.illustrationMetadata ?? .empty }
    }

    func updateMeta(_ update: (inout IllustrationMetadata) -> Void) {
        var m = block.illustrationMetadata ?? .empty
        update(&m)
        block.illustrationMetadata = m
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $block.content)
                .font(.body)
                .scrollContentBackground(.hidden)
                .background(.clear)
                .frame(minHeight: 80)
                .focused($isFocused)
                .onChange(of: isFocused) { _, f in
                    if f { focusedBlockID.wrappedValue = block.id }
                }
                .overlay(alignment: .topLeading) {
                    if block.content.isEmpty {
                        Text("Describe your illustration, story, or example...")
                            .foregroundStyle(.tertiary)
                            .font(.body)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                }

            // Metadata toggle
            DisclosureGroup(isExpanded: $isMetaExpanded) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Picker("Type", selection: Binding(
                            get: { IllustrationType(rawValue: meta.illustrationType) ?? .story },
                            set: { updateMeta { $0.illustrationType = $1.rawValue } }
                        )) {
                            ForEach(IllustrationType.allCases) { t in
                                Label(t.displayName, systemImage: t.systemImage).tag(t)
                            }
                        }
                        .pickerStyle(.menu)
                        .controlSize(.small)
                    }

                    TextField("Source / Title", text: Binding(
                        get: { meta.sourceTitle ?? "" },
                        set: { let v = $0; updateMeta { $0.sourceTitle = v.isEmpty ? nil : v } }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.small)

                    TextField("Author", text: Binding(
                        get: { meta.sourceAuthor ?? "" },
                        set: { let v = $0; updateMeta { $0.sourceAuthor = v.isEmpty ? nil : v } }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.small)

                    if let onSave = onSaveToLibrary {
                        Button(action: onSave) {
                            Label("Save to Illustration Library", systemImage: "bookmark")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding(.top, 4)
            } label: {
                Text("Source & Details")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
