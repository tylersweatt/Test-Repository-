import SwiftUI

struct PresentationView: View {
    let sermon: Sermon
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var isShowingTeleprompter = false
    @State private var fontSize: CGFloat = 28

    var displayBlocks: [SermonBlock] {
        sermon.blocksSorted.filter { $0.blockTypeEnum.showInPresentation }
    }

    var currentBlock: SermonBlock? {
        guard displayBlocks.indices.contains(currentIndex) else { return nil }
        return displayBlocks[currentIndex]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("\(currentIndex + 1) / \(displayBlocks.count)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Menu {
                        Button("Increase Text") { fontSize = min(fontSize + 4, 56) }
                        Button("Decrease Text") { fontSize = max(fontSize - 4, 16) }
                        Divider()
                        Button("Teleprompter Mode") { isShowingTeleprompter = true }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding()

                // Current block content
                if let block = currentBlock {
                    ScrollView {
                        PresentationBlockView(block: block, fontSize: fontSize)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                    }
                }

                Spacer()

                // Navigation arrows
                HStack(spacing: 40) {
                    Button {
                        if currentIndex > 0 { currentIndex -= 1 }
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(currentIndex > 0 ? .white : .white.opacity(0.2))
                    }
                    .disabled(currentIndex == 0)

                    // Block type indicator
                    if let block = currentBlock {
                        VStack(spacing: 4) {
                            Image(systemName: block.blockTypeEnum.systemImage)
                                .foregroundStyle(block.blockTypeEnum.accentColor)
                            Text(block.blockTypeEnum.displayName)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }

                    Button {
                        if currentIndex < displayBlocks.count - 1 { currentIndex += 1 }
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(currentIndex < displayBlocks.count - 1 ? .white : .white.opacity(0.2))
                    }
                    .disabled(currentIndex >= displayBlocks.count - 1)
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isShowingTeleprompter) {
            TeleprompterView(sermon: sermon)
        }
        #if os(iOS)
        .statusBarHidden()
        #endif
    }
}

// MARK: - PresentationBlockView

struct PresentationBlockView: View {
    let block: SermonBlock
    let fontSize: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Type label
            Text(block.blockTypeEnum.shortLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(block.blockTypeEnum.accentColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(block.blockTypeEnum.accentColor.opacity(0.15))
                .clipShape(Capsule())

            if block.blockTypeEnum == .scripture, let meta = block.scriptureMetadata {
                // Scripture: show reference + verse text prominently
                Text(meta.referenceString + " (\(meta.translation))")
                    .font(.system(size: fontSize * 0.6).weight(.semibold))
                    .foregroundStyle(block.blockTypeEnum.accentColor)
                Text("\"\(meta.verseText)\"")
                    .font(.system(size: fontSize).italic())
                    .foregroundStyle(.white)
                if !block.content.isEmpty {
                    Text(block.content)
                        .font(.system(size: fontSize * 0.8))
                        .foregroundStyle(.white.opacity(0.8))
                }
            } else if block.blockTypeEnum == .outline, let meta = block.outlineMetadata {
                HStack(alignment: .top, spacing: 12) {
                    Text(meta.pointNumber + ".")
                        .font(.system(size: fontSize).bold())
                        .foregroundStyle(block.blockTypeEnum.accentColor)
                    Text(block.content)
                        .font(.system(size: fontSize).bold())
                        .foregroundStyle(.white)
                }
            } else {
                Text(block.content)
                    .font(.system(size: fontSize))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
