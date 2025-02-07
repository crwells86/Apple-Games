import SwiftUI
import SpriteKit
import GameKit

struct ContentView: View {
    @State private var gameSceneController = GameSceneController()
    
    @State private var gameState: GameState = .mainMenu
    var gameCenterController = GameCenterController.shared
    let accessPoint = GKAccessPoint.shared
    
    var body: some View {
        switch gameState {  //gameSceneController.gameState {
        case .playing:
            GameView(gameSceneController: $gameSceneController, gameState: $gameState)
                .onAppear {
                    accessPoint.isActive = false
                    
                    // Configure the callback so that when gameOver is called, we update our view state.
                    gameSceneController.onGameOver = {
                        // This closure is executed on the game over event.
                        // Ensure any UI updates are done on the main thread.
                        DispatchQueue.main.async {
                            gameState = .gameOver
                        }
                    }
                }
        case .paused:
            PausedMenuView(gameState: $gameState) //(gameSceneController: $gameSceneController)
        case .gameOver:
            GameOverMenuView(gameSceneController: $gameSceneController, gameState: $gameState)
                .onAppear {
                    accessPoint.location = .topLeading
                    accessPoint.showHighlights = true
                    accessPoint.isActive = true
                }
        case .mainMenu:
            MainMenuView(gameSceneController: $gameSceneController, gameState: $gameState)
                .onAppear {
                    accessPoint.location = .topLeading
                    accessPoint.showHighlights = true
                    accessPoint.isActive = true
                }
                .onDisappear {
                    accessPoint.isActive = false
                }
        }
    }
}

#Preview {
    ContentView()
}
