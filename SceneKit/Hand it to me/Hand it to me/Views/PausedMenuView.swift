import SwiftUI

struct PausedMenuView: View {
    @Binding var gameSceneController: GameSceneController
    
    var body: some View {
        VStack {
            Button {
                gameSceneController.gameState = .playing
            } label: {
                Text("Resume")
            }
            .padding()
            
            Button {
                //                gameSceneController.gameOver()
                gameSceneController.gameState = .mainMenu
            } label: {
                Text("Quit")
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .padding()
        .background(.black)
        .buttonStyle(.plain)
    }
}

#Preview {
    PausedMenuView(gameSceneController: .constant(GameSceneController()))
}
