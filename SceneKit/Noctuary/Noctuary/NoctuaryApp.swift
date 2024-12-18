import SwiftUI

@main
struct NoctuaryApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .onAppear {
                    suppressKeyPressSounds()
                }
        }
    }
    
    // Prevent system sound
    func suppressKeyPressSounds() {
#if os(macOS)
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { event in
            return nil
        }
#endif
    }
    
}
