import SwiftUI

struct MainMenuView: View {
    @Binding var gameSceneController: GameSceneController
    
    var body: some View {
        VStack {
            Text("1D Dash")
                .retroFont(style: .largeTitle)
            
            Button {
                gameSceneController.startGame()
            } label: {
                Text("Play")
                    .retroFont(style: .title)
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
