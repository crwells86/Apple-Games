import SwiftUI
import GameKit

struct ContentView: View {
    @State private var gameSceneController = GameSceneController()
    
#if !os(watchOS)
    var gameCenterController = GameCenterController.shared
    let accessPoint = GKAccessPoint.shared
#endif
    
    var body: some View {
        switch gameSceneController.gameState {
        case .playing:
            GameView(gameSceneController: $gameSceneController)
                .onAppear {
#if !os(watchOS)
                    accessPoint.isActive = false
#endif
                    // Ensure every entry into playing state starts a fresh run
                    gameSceneController.startGame()
                }
        case .gameOver:
            GameOverView(gameSceneController: $gameSceneController)
                .onAppear {
#if !os(watchOS)
                    accessPoint.location = .topLeading
                    accessPoint.showHighlights = true
                    accessPoint.isActive = true
#endif
                }
        case .mainMenu:
            MainMenuView(gameSceneController: $gameSceneController)
#if !os(watchOS)
                .onAppear {
                    accessPoint.location = .topLeading
                    accessPoint.showHighlights = true
                    accessPoint.isActive = true
                }
                .onDisappear {
                    accessPoint.isActive = false
                }
#endif
        }
    }
}

#Preview {
    ContentView()
}
