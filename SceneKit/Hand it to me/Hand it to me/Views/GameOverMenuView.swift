import SwiftUI

struct GameOverMenuView: View {
    @AppStorage("gameHighScore") var highScore = 0
    @Binding var gameSceneController: GameSceneController
    var gameCenterController = GameCenterController.shared
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Game Over!")
                .padding(.vertical)
            
            Button {
                gameSceneController.startGame()
            } label: {
                Text("Try Again")
            }
            .padding(.bottom)
            
            Button {
                gameSceneController.gameState = .mainMenu
            } label: {
                Text("Quit")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .padding()
        .background(.black)
        .onAppear {
            //            if gameSceneController.score > highScore {
            //                highScore = gameSceneController.score
            //                
            //                Task {
            //                    await gameCenterController.submitScoreToGameCenter(score: gameSceneController.score)
            //                }
            //            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GameOverMenuView(gameSceneController: .constant(GameSceneController()))
}
