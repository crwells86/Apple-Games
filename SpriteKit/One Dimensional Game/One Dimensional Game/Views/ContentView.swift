import SwiftUI
import GameKit

struct ContentView: View {
    @State private var gameSceneController = GameSceneController()
//    var gameCenterController = GameCenterController.shared
    let accessPoint = GKAccessPoint.shared
    
    var body: some View {
        switch gameSceneController.gameState {
        case .playing:
            GameView(gameSceneController: $gameSceneController)
//                .onAppear {
//                    accessPoint.isActive = false
//                }
        case .paused:
            Text("Paused")
//            PausedMenuView(gameSceneController: $gameSceneController)
        case .gameOver:
            Text("Game Over")
//            GameOverMenuView(gameSceneController: $gameSceneController)
//                .onAppear {
//                    accessPoint.location = .topLeading
//                    accessPoint.showHighlights = true
//                    accessPoint.isActive = true
//                }
        case .mainMenu:
            MainMenuView(gameSceneController: $gameSceneController)
//                .onAppear {
//                    accessPoint.location = .topLeading
//                    accessPoint.showHighlights = true
//                    accessPoint.isActive = true
//                }
//                .onDisappear {
//                    accessPoint.isActive = false
//                }
        }
    }
}

#Preview {
    ContentView()
}
