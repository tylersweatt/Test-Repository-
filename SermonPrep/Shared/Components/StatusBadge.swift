import SwiftUI

// MARK: - StatusBadge

struct StatusBadge: View {
    let status: SermonStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(status.color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(status.color.opacity(0.15))
            .clipShape(Capsule())
    }
}

// MARK: - SermonStatus display extensions

extension SermonStatus {
    var displayName: String {
        switch self {
        case .draft:      return "Draft"
        case .inProgress: return "In Progress"
        case .ready:      return "Ready"
        case .preached:   return "Preached"
        case .archived:   return "Archived"
        }
    }

    var color: Color {
        switch self {
        case .draft:      return .gray
        case .inProgress: return .orange
        case .ready:      return .green
        case .preached:   return .blue
        case .archived:   return .secondary
        }
    }
}
