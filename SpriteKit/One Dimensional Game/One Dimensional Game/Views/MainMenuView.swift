import SwiftUI

struct MainMenuView: View {
    @Binding var gameSceneController: GameSceneController
    
    var body: some View {
        VStack {
            Text("2D Dash")
//                .retroFont(size: 87)
            
            Button {
                gameSceneController.startGame()
            } label: {
                Text("Play")
//                    .retroFont(style: .largeTitle)
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
