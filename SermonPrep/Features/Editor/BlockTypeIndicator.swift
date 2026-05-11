import SwiftUI

// MARK: - BlockTypeIndicator

struct BlockTypeIndicator: View {
    let blockType: BlockType

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(blockType.accentColor)
            .frame(width: 4)
            .padding(.vertical, 2)
    }
}

// MARK: - BlockTypeChip

struct BlockTypeChip: View {
    let blockType: BlockType
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 4) {
                Image(systemName: blockType.systemImage)
                    .font(.caption2)
                Text(blockType.shortLabel)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(blockType.accentColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(blockType.accentColor.opacity(0.12))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
