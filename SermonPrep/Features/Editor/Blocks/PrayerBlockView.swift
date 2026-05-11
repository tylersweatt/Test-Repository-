import SwiftUI

struct PrayerBlockView: View {
    @Bindable var block: SermonBlock
    var focusedBlockID: Binding<UUID?>

    var body: some View {
        SimpleTextBlockView(
            block: block,
            focusedBlockID: focusedBlockID,
            placeholder: "Write a prayer or altar call..."
        )
    }
}
