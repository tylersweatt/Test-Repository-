import SwiftUI

// MARK: - BlockTypePicker

struct BlockTypePicker: View {
    var onSelect: (BlockType) -> Void

    let columns = [GridItem(.adaptive(minimum: 120, maximum: 160))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(BlockType.allCases) { type in
                    Button {
                        onSelect(type)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.systemImage)
                                .font(.title2)
                                .foregroundStyle(type.accentColor)
                            Text(type.displayName)
                                .font(.caption.weight(.medium))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                            Text(type.description)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(type.accentColor.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .frame(minWidth: 320, idealWidth: 400, maxWidth: 500)
        .frame(minHeight: 300, idealHeight: 400, maxHeight: 500)
        .navigationTitle("Add Block")
    }
}
