import SwiftUI

struct MainMenuView: View {
    @Binding var gameSceneController: GameSceneController
    
    var body: some View {
        VStack {
            Text("Hello, main menu!")
            
            Button {
                gameSceneController.startGame()
            } label: {
                Text("Play")
            }
            
        }
        .padding()
    }
}

#Preview {
    MainMenuView(gameSceneController: .constant(GameSceneController()))
}
