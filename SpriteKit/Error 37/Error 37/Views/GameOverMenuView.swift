import SwiftUI

struct GameOverMenuView: View {
    @AppStorage("gameHighScore") var highScore = 0
    @Binding var gameSceneController: GameSceneController
    @Binding var gameState: GameState
    var gameCenterController = GameCenterController.shared
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Game Over!")
                .font(.largeTitle)
                .padding(.vertical)
            
            Text("Coins Collected: \(gameSceneController.coinsCollected)")
                .font(.title3)
            
            Text("Enemies Defeated: \(gameSceneController.enemiesDefeated)")
                .font(.title3)
            
            Text("----------------")
                .font(.title3)
                .padding(.vertical)
            
            Text("Score: \(gameSceneController.score)")
                .font(.title3)
            
            Text("High Score: \(highScore)")
                .font(.title3)
            
            Text("----------------")
                .font(.title3)
                .padding(.vertical)
            
            Button {
                gameSceneController.startGame()
            } label: {
                Text("Try Again")
                    .font(.title2)
            }
            .padding(.bottom)
            
            Button {
                gameState = .mainMenu
                // gameSceneController.gameState = .mainMenu
            } label: {
                Text("Quit")
                    .font(.title2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .padding()
        .background(.black)
        .onAppear {
            if gameSceneController.score > highScore {
                highScore = gameSceneController.score
                
                Task {
                    await gameCenterController.submitScoreToGameCenter(score: gameSceneController.score)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GameOverMenuView(gameSceneController: .constant(GameSceneController()), gameState: .constant(.gameOver))
}
