import SwiftUI

struct PausedMenuView: View {
    @Binding var gameSceneController: GameSceneController
    
    var body: some View {
        VStack {
            Text("Hello, paused menu!")
            
            Button {
                gameSceneController.gameState = .playing
            } label: {
                Text("Resume")
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
    PausedMenuView(gameSceneController: .constant(GameSceneController()))
}
