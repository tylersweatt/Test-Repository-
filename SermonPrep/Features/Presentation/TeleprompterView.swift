import SwiftUI

struct TeleprompterView: View {
    let sermon: Sermon
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings

    @State private var isPlaying = false
    @State private var scrollOffset: CGFloat = 0
    @State private var speed: Double = 50
    @State private var fontSize: CGFloat = 24

    var displayBlocks: [SermonBlock] {
        sermon.blocksSorted.filter { $0.blockTypeEnum.showInPresentation }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            ScrollView {
                ScrollViewReader { proxy in
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(displayBlocks) { block in
                            teleprompterBlockView(block)
                                .id(block.id)
                        }
                        Spacer().frame(height: 400)  // bottom padding for readability
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 60)
                }
            }

            // Controls overlay at bottom
            VStack(spacing: 0) {
                Spacer()
                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                    .frame(height: 120)
                    .allowsHitTesting(false)
                HStack(spacing: 20) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Button {
                        isPlaying.toggle()
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                    }

                    Slider(value: $speed, in: 10...150)
                        .frame(width: 120)
                        .tint(.white)

                    Image(systemName: "speedometer")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .background(Color.black)
            }
        }
        .preferredColorScheme(.dark)
        #if os(iOS)
        .statusBarHidden()
        #endif
        .onAppear { speed = settings.teleprompterSpeed }
    }

    func teleprompterBlockView(_ block: SermonBlock) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if block.blockTypeEnum == .scripture, let meta = block.scriptureMetadata {
                Text(meta.referenceString)
                    .font(.system(size: fontSize * 0.7).weight(.semibold))
                    .foregroundStyle(block.blockTypeEnum.accentColor)
                Text("\"\(meta.verseText)\"")
                    .font(.system(size: fontSize).italic())
                    .foregroundStyle(.white)
            } else if block.blockTypeEnum == .outline, let meta = block.outlineMetadata {
                Text("\(meta.pointNumber). \(block.content)")
                    .font(.system(size: fontSize + 4).bold())
                    .foregroundStyle(.white)
            } else {
                Text(block.content)
                    .font(.system(size: fontSize))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }
}
