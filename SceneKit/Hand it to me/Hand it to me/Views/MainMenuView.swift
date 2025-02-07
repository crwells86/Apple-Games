import SwiftUI

struct MainMenuView: View {
    @Binding var gameSceneController: GameSceneController
    
    var body: some View {
        VStack {
            Text("Hand it to me")
            
            Button {
                gameSceneController.startGame()
            } label: {
                Text("Play")
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
    MainMenuView(gameSceneController: .constant(GameSceneController()))
}
