import SwiftUI

struct GameOverMenuView: View {
    @AppStorage("gameHighScore") var highScore = 0
    @Binding var gameSceneController: GameSceneController
    var gameCenterController = GameCenterController.shared
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Game Over!")
                .retroFont(style: .largeTitle)
                .padding(.vertical)
            
            Text("Coins Collected: \(gameSceneController.coinsCollected)")
                .retroFont(style: .title3)
            
            Text("Enemies Defeated: \(gameSceneController.enemiesDefeated)")
                .retroFont(style: .title3)
            
            Text("----------------")
                .retroFont(style: .title3)
                .padding(.vertical)
            
            Text("Score: \(gameSceneController.score)")
                .retroFont(style: .title3)
            
            Text("High Score: \(highScore)")
                .retroFont(style: .title3)
            
            Text("----------------")
                .retroFont(style: .title3)
                .padding(.vertical)
            
            Button {
                gameSceneController.startGame()
            } label: {
                Text("Try Again")
                    .retroFont(style: .title2)
            }
            .padding(.bottom)
            
            Button {
                gameSceneController.gameState = .mainMenu
            } label: {
                Text("Quit")
                    .retroFont(style: .title2)
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
    GameOverMenuView(gameSceneController: .constant(GameSceneController()))
}
