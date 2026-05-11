import SwiftUI

// MARK: - PresentationView

struct PresentationView: View {
    let sermon: Sermon
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings

    @State private var currentBlockIndex: Int = 0
    @State private var fontSize: CGFloat = 28
    @State private var isShowingControls = true

    private var visibleBlocks: [SermonBlock] {
        sermon.blocksSorted.filter { $0.blockTypeEnum.showInPresentation }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if visibleBlocks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 64))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("No content to present")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            } else {
                TabView(selection: $currentBlockIndex) {
                    ForEach(visibleBlocks.indices, id: \.self) { idx in
                        PresentationSlideView(
                            block: visibleBlocks[idx],
                            fontSize: fontSize,
                            sermonTitle: sermon.title
                        )
                        .tag(idx)
                    }
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
            }

            // Overlay controls
            if isShowingControls {
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Label("Exit", systemImage: "xmark.circle.fill")
                                .foregroundStyle(.white)
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                        .padding()

                        Spacer()

                        Text("\(currentBlockIndex + 1) / \(visibleBlocks.count)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding()
                    }

                    Spacer()

                    HStack(spacing: 32) {
                        Button {
                            if currentBlockIndex > 0 { currentBlockIndex -= 1 }
                        } label: {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(currentBlockIndex > 0 ? .white : .white.opacity(0.2))
                        }
                        .buttonStyle(.plain)
                        .disabled(currentBlockIndex == 0)

                        Button {
                            if currentBlockIndex < visibleBlocks.count - 1 { currentBlockIndex += 1 }
                        } label: {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(
                                    currentBlockIndex < visibleBlocks.count - 1 ? .white : .white.opacity(0.2)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(currentBlockIndex == visibleBlocks.count - 1)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onTapGesture {
            withAnimation { isShowingControls.toggle() }
        }
        #if os(iOS)
        .statusBarHidden(true)
        #endif
    }
}

// MARK: - PresentationSlideView

struct PresentationSlideView: View {
    let block: SermonBlock
    let fontSize: CGFloat
    let sermonTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()

            // Block type label
            HStack {
                Image(systemName: block.blockTypeEnum.systemImage)
                Text(block.blockTypeEnum.displayName.uppercased())
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(block.blockTypeEnum.accentColor)
            .padding(.horizontal, 40)

            // Content
            if block.blockTypeEnum == .scripture,
               let meta = block.scriptureMetadata {
                VStack(alignment: .leading, spacing: 12) {
                    Text(meta.referenceString)
                        .font(.system(size: fontSize * 0.6).weight(.bold))
                        .foregroundStyle(block.blockTypeEnum.accentColor)
                    Text(block.content)
                        .font(.system(size: fontSize).italic())
                        .foregroundStyle(.white)
                    Text("— \(meta.translation)")
                        .font(.system(size: fontSize * 0.4))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 40)
            } else if block.blockTypeEnum == .quote {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\u{201C}\(block.content)\u{201D}")
                        .font(.system(size: fontSize).italic())
                        .foregroundStyle(.white)
                    if let author = block.illustrationMetadata?.sourceAuthor, !author.isEmpty {
                        Text("— \(author)")
                            .font(.system(size: fontSize * 0.5))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 40)
            } else if block.blockTypeEnum == .outline,
                      let meta = block.outlineMetadata {
                HStack(alignment: .top, spacing: 16) {
                    Text(meta.pointNumber)
                        .font(.system(size: fontSize).weight(.bold))
                        .foregroundStyle(block.blockTypeEnum.accentColor)
                    Text(block.content)
                        .font(.system(size: fontSize).weight(.semibold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 40)
            } else {
                Text(block.content)
                    .font(.system(size: fontSize))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.black)
    }
}
