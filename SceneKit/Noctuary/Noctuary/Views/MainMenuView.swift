import SwiftUI
import StoreKit
import GameKit

struct MainMenuView: View {
#if !os(tvOS)
    @Environment(\.requestReview) private var requestReview
#endif
    @AppStorage("playCount") private var playCount: Int = 0
    @AppStorage("hasPromptedForReview") private var hasPromptedForReview: Bool = false
    
    var body: some View {
        Text("Hello")
            .padding()
    }
}

#Preview {
    MainMenuView()
}
