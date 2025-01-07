import SwiftUI

struct PausedMenuView: View {
    @Binding var gameSceneController: GameSceneController
    
    var body: some View {
        VStack {
            Button {
                gameSceneController.gameState = .playing
            } label: {
                Text("Resume")
                    .retroFont(style: .title2)
            }
            .padding()
            
            Button {
                gameSceneController.gameState = .mainMenu
            } label: {
                Text("Quit")
                    .retroFont(style: .title2)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .padding()
        .background(.black)
    }
}

#Preview {
    PausedMenuView(gameSceneController: .constant(GameSceneController()))
}
