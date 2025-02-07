import SwiftUI

@main
struct Hand_it_to_meApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .applyStatusBarHidden()
                .onAppear {
                    suppressKeyPressSounds()
                }
        }
    }
    
    // Prevent system sound on Mac
    func suppressKeyPressSounds() {
#if os(macOS)
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { event in
            return nil
        }
#endif
    }
    
}
