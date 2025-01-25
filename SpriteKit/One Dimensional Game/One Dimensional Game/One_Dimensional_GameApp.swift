import SwiftUI

@main
struct One_Dimensional_GameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .applyStatusBarHidden()
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
