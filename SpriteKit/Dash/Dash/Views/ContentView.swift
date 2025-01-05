import SwiftUI

struct ContentView: View {
    @State private var gameSceneController = GameSceneController()
    
    var body: some View {
        switch gameSceneController.gameState {
        case .playing:
            GameView(gameSceneController: $gameSceneController)
        case .paused:
            PausedMenuView(gameSceneController: $gameSceneController)
        case .gameOver:
            GameOverMenuView(gameSceneController: $gameSceneController)
        case .mainMenu:
            MainMenuView(gameSceneController: $gameSceneController)
        }
    }
}

#Preview {
    ContentView()
}
