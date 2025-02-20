import SwiftUI

struct ContentView: View {
    @State private var gameSceneController = GameSceneController()
    
    var body: some View {
        switch gameSceneController.gameState {
        case .playing:
            VStack {
                Text("Game View")
                
                Button("Pause Game") {
                    gameSceneController.gameState = .paused
                }
            }
        case .paused:
            VStack {
                Text("Paused View")
                
                Button("Resume Game") {
                    gameSceneController.gameState = .playing
                }
                
                Button("Main Menu") {
                    gameSceneController.gameState = .mainMenu
                }
            }
        case .gameOver:
            VStack {
                Text("Game Over View")
                
                Button("Restart Game") {
                    gameSceneController.gameState = .playing
                }
                
                Button("Main Menu") {
                    gameSceneController.gameState = .mainMenu
                }
            }
        case .mainMenu:
            VStack {
                Text("Main Menu View")
                
                Button("Start Game") {
                    gameSceneController.gameState = .playing
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
