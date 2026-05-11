import SwiftUI

// MARK: - BlockType color definitions
// All colour logic lives here; BlockType.accentColor delegates to BlockType.color.

extension BlockType {

    /// The primary accent colour for this block type.
    var color: Color {
        switch self {
        case .hook:         return .orange
        case .outline:      return .indigo
        case .scripture:    return .purple
        case .explanation:  return .blue
        case .illustration: return .green
        case .application:  return .red
        case .quote:        return .brown
        case .prayer:       return .teal
        case .transition:   return .gray
        case .conclusion:   return .cyan
        case .note:         return .yellow
        }
    }

    /// A very light tint of the block type colour, suitable for backgrounds.
    var colorLight: Color { color.opacity(0.15) }

    /// A medium tint of the block type colour, suitable for borders and chips.
    var colorMedium: Color { color.opacity(0.35) }
}

// MARK: - Convenience free function

extension Color {
    /// Returns the accent colour associated with a given block type.
    static func blockTypeColor(_ type: BlockType) -> Color {
        type.color
    }
}
