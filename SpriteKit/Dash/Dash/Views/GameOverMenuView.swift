import SwiftUI

struct GameOverMenuView: View {
    @AppStorage("gameHighScore") var highScore = 0
    @Binding var gameSceneController: GameSceneController
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Game Over!")
            
            Text("Coins Collected: \(gameSceneController.coinsCollected)")
            Text("Enemies Defeated: \(gameSceneController.enemiesDefeated)")
            Text("Score: \(gameSceneController.score)")
            Text("High Score: \(highScore)")
            
            Button {
                gameSceneController.startGame()
            } label: {
                Text("Try Again")
            }
            
            Button {
                gameSceneController.gameState = .mainMenu
            } label: {
                Text("Quit")
            }
        }
        .padding()
        .onAppear {
            if gameSceneController.score > highScore {
                highScore = gameSceneController.score
            }
        }
    }
}

#Preview {
    GameOverMenuView(gameSceneController: .constant(GameSceneController()))
}
