import SwiftUI
import SceneKit

struct GameView: View {
    @Binding var gameScene: GameSceneController
    
#if os(iOS) || os(tvOS) || os(visionOS)
    let calculatedWidth = UIScreen.main.bounds.width / 2.7
#elseif os(macOS)
    let calculatedWidth = (NSApplication.shared.mainWindow?.frame.width)! / 2.7
#endif
    
    var body: some View {
        SceneView(scene: gameScene, pointOfView: gameScene.cameraController!.cameraNode, delegate: gameScene)
            .ignoresSafeArea()
            .overlay {
                ZStack {
                    Color.black
                        .opacity(0.42)
                    
                    ScrollView {
                        Text("""
                    Hi there!
                    
                    I hope the note animation looks great on macOS, iOS, tvOS, and now it’s time to move on to the next feature or work on some graphics!
                    
                    -Dev
                    """)
                    }
                    .frame(width: calculatedWidth)
                    .padding()
                    .background(.white)
                    .foregroundStyle(.black)
                    .offset(y: gameScene.isNoteShowing ? 0 : calculatedWidth)
                }
                .opacity(gameScene.isNoteShowing ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: gameScene.isNoteShowing)
            }
    }
}
