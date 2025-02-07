import SwiftUI

struct MainMenuView: View {
    @Binding var gameSceneController: GameSceneController
    @Binding var gameState: GameState
    
    var body: some View {
        VStack {
            Text("Error 37")
                .font(.system(size: 120))
            
            VStack {
                Button {
                    gameSceneController.isMultiplayer = false
                    gameState = .playing
                    gameSceneController.startGame()
                } label: {
                    Text("1")
                        .font(.largeTitle)
                }
                .padding()
                
                HStack {
                    ForEach(2..<5) { index in
                        Button {
                            gameSceneController.isMultiplayer = true
                            gameSceneController.setPlayerCount(to: index)
                            gameSceneController.startGame()
                        } label: {
                            Text("\(index)")
                                .font(.largeTitle)
                        }
                        .padding()
                    }
                }
            }
            .overlay(alignment: .topLeading) {
                Text("Select Players")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .padding()
        .background(.black)
        .buttonStyle(.plain)
    }
}

#Preview {
    MainMenuView(gameSceneController: .constant(GameSceneController()), gameState: .constant(.mainMenu))
}
