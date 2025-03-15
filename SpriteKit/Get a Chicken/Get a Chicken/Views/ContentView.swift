import SwiftUI
import SpriteKit
import GameKit

struct ContentView: View {
    @State private var gameSceneController = GameSceneController()
    
    var body: some View {
        let gameEnvironment = GameEnvironment(
            gameSceneController: gameSceneController,
            accessPoint: GKAccessPoint.shared,
            gameCenterController: GameCenterController.shared
        )
        
        Group {
            switch gameSceneController.gameState {
            case .playing:
                PlayingView()
            case .paused:
                PausedView()
            case .gameOver:
                GameOverView()
            case .mainMenu:
                MainMenuView()
            case .options:
                VStack {
                    Text("Options")
                    
                    Button("Back") {
                        gameSceneController.gameState = .mainMenu
                    }
                    .font(.system(size: 42, weight: .black, design: .rounded))
                }
            }
        }
        .environment(\.gameEnvironment, gameEnvironment)
    }
}

#Preview {
    ContentView()
}
