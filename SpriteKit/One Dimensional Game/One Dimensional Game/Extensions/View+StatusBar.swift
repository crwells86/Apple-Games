import SwiftUI

extension View {
    @ViewBuilder
    func applyStatusBarHidden() -> some View {
#if os(iOS)
        self.statusBarHidden(true)
#else
        self
#endif
    }
}
