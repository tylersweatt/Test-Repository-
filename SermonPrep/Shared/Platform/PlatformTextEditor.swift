import SwiftUI

// MARK: - PlatformTextEditor

/// A cross-platform TextEditor with placeholder text support.
///
/// Wraps `TextEditor` in a `ZStack` so that placeholder copy is shown
/// whenever the binding is empty, matching the behaviour of `TextField`.
struct PlatformTextEditor: View {

    @Binding var text: String
    var placeholder: String = ""
    var font: Font = .body
    var minHeight: CGFloat = 44

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder
            if text.isEmpty {
                Text(placeholder)
                    .font(font)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }

            // Editor
            TextEditor(text: $text)
                .font(font)
                .frame(minHeight: minHeight)
                .scrollContentBackground(.hidden)
                .background(.clear)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var text = ""
    PlatformTextEditor(
        text: $text,
        placeholder: "Start writing your sermon here…",
        minHeight: 120
    )
    .padding()
}
