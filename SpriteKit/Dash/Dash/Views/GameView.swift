import SwiftUI
import SpriteKit

struct GameView: View {
    @Binding var gameSceneController: GameSceneController
    
    var body: some View {
        ZStack {
            SpriteView(scene: gameSceneController)
                .ignoresSafeArea()
                .onTapGesture {
                    gameSceneController.jump()
                }
            
            HStack {
                Text("Score: \(gameSceneController.score)")
                    .font(.largeTitle)
                
                Spacer()
                
                Button {
                    gameSceneController.gameState = .paused
                } label: {
                    Image(systemName: "pause.circle.fill")
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .foregroundStyle(.white)
            .padding()
        }
    }
}

#Preview {
    GameView(gameSceneController: .constant(GameSceneController()))
}
