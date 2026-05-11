import SwiftUI

struct ConclusionBlockView: View {
    @Bindable var block: SermonBlock
    var focusedBlockID: Binding<UUID?>

    var body: some View {
        SimpleTextBlockView(
            block: block,
            focusedBlockID: focusedBlockID,
            placeholder: "Write your conclusion and call to action..."
        )
    }
}
