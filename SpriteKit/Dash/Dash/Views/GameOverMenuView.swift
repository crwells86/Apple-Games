import SwiftUI

struct GameOverMenuView: View {
    @Binding var gameSceneController: GameSceneController
    
    var body: some View {
        VStack {
            Text("game Over!\n☹️☹️☹️")
            
            Text("• Coins Collected: \(gameSceneController.coinsCollected)")
            Text("• Enemies Defeated: \(gameSceneController.enemiesDefeated)")
            Text("• Total Score: \(gameSceneController.score)")
            Text("• High Score: \(gameSceneController.highScore)")
            
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
    }
}

#Preview {
    GameOverMenuView(gameSceneController: .constant(GameSceneController()))
}
