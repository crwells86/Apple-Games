import SwiftUI
import SpriteKit

struct GameView: View {
    @Binding var gameSceneController: GameSceneController
    @Binding var gameState: GameState
    
    var body: some View {
        ZStack {
            SpriteView(scene: gameSceneController)
                .ignoresSafeArea()
            
            HStack {
                Text("Score: \(gameSceneController.score)")
                    .font(.largeTitle)
                
                Spacer()
                
                Button {
                    gameState = .paused
                    //gameSceneController.gameState = .paused
                } label: {
                    Text("II")
                        .font(.largeTitle)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .foregroundStyle(.white)
            .padding()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GameView(gameSceneController: .constant(GameSceneController()), gameState: .constant(.playing))
}
