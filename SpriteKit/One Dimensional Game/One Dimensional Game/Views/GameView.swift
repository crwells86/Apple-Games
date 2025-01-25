import SwiftUI
import SpriteKit

struct GameView: View {
    @Binding var gameSceneController: GameSceneController
    
    var body: some View {
        ZStack {
            SpriteView(scene: gameSceneController)
                .ignoresSafeArea()
                .onTapGesture {
                    // ?
                }
            
            HStack {
                Text("Score: \(gameSceneController.score)")
                //                    .retroFont(style: .largeTitle)
                
                Spacer()
                
                Button {
                    gameSceneController.gameState = .paused
                } label: {
                    Text("II")
                    //                        .retroFont(style: .largeTitle)
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
    GameView(gameSceneController: .constant(GameSceneController()))
}
