import SwiftUI

// MARK: - Conditional platform transforms

extension View {

    /// Applies a transform only when running on macOS, leaving the view unchanged on other platforms.
    @ViewBuilder
    func ifMac<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        #if os(macOS)
        transform(self)
        #else
        self
        #endif
    }

    /// Applies a transform only when running on iOS, leaving the view unchanged on other platforms.
    @ViewBuilder
    func ifIOS<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        #if os(iOS)
        transform(self)
        #else
        self
        #endif
    }
}

// MARK: - Platform-aware horizontal padding

extension View {

    /// Applies horizontal padding sized appropriately for the current platform.
    func platformHorizontalPadding() -> some View {
        #if os(macOS)
        self.padding(.horizontal, 16)
        #else
        self.padding(.horizontal, 20)
        #endif
    }
}

// MARK: - Platform-aware list style modifier

struct PlatformListStyle: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        content.listStyle(.sidebar)
        #else
        content.listStyle(.insetGrouped)
        #endif
    }
}

extension View {

    /// Applies `.sidebar` on macOS and `.insetGrouped` on iOS.
    func platformListStyle() -> some View {
        modifier(PlatformListStyle())
    }
}
