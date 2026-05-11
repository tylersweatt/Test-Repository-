import SwiftUI

struct HookBlockView: View {
    @Bindable var block: SermonBlock
    var focusedBlockID: Binding<UUID?>

    var body: some View {
        SimpleTextBlockView(
            block: block,
            focusedBlockID: focusedBlockID,
            placeholder: "Write your attention-getting sermon opener..."
        )
    }
}
