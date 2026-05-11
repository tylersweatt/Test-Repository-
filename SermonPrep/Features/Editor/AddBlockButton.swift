import SwiftUI

// MARK: - AddBlockButton

struct AddBlockButton: View {
    var afterBlockID: UUID?
    var onAdd: (BlockType, UUID?) -> Void

    @State private var isShowingPicker = false
    @State private var isHovered = false

    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.secondary.opacity(isHovered ? 0.5 : 0.1))
                .frame(height: 1)

            Button {
                isShowingPicker = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(isHovered ? .blue : Color.secondary.opacity(0.4))
            }
            .buttonStyle(.plain)
            #if os(macOS)
            .onHover { isHovered = $0 }
            #endif

            Rectangle()
                .fill(Color.secondary.opacity(isHovered ? 0.5 : 0.1))
                .frame(height: 1)
        }
        .frame(height: 24)
        .contentShape(Rectangle())
        #if os(macOS)
        .onHover { isHovered = $0 }
        #endif
        .popover(isPresented: $isShowingPicker, arrowEdge: .bottom) {
            BlockTypePicker { type in
                onAdd(type, afterBlockID)
                isShowingPicker = false
            }
        }
    }
}
