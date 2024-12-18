import SwiftUI
import SceneKit

struct MainMenuView: View {
    @AppStorage("playCount") private var playCount: Int = 0
    @AppStorage("hasPromptedForReview") private var hasPromptedForReview: Bool = false
    
    @State private var isGameActive = false
    @State private var gameScene = GameSceneController()
    
    var body: some View {
        ZStack {
            Color.purple
                .ignoresSafeArea()
            
            Group {
                Text("Noctuary")
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                
                Text("Noctuary")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .offset(x: -2, y: -2)
            }
            
            HStack {
                Button {
                    handlePlayButtonTapped()
                } label: {
                    Text("Play")
                        .font(.title2)
                }
                
                Button {
                    // Handle "Settings" action
                } label: {
                    Text("Settings")
                        .font(.title2)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding()
            
            if isGameActive {
                SceneView(scene: gameScene, pointOfView: gameScene.cameraController!.cameraNode, delegate: gameScene)
                    .ignoresSafeArea()
            }
        }
    }
    
    private func handlePlayButtonTapped() {
        gameScene.startGame()
        isGameActive.toggle()
    }
}

#Preview {
    MainMenuView()
}
