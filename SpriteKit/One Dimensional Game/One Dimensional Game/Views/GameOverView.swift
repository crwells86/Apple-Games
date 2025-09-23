import SwiftUI
import GameKit

struct GameOverView: View {
    @AppStorage("gameHighScore") var highScore = 0
    @Binding var gameSceneController: GameSceneController
    
#if !os(watchOS)
    var gameCenterController = GameCenterController.shared
    let accessPoint = GKAccessPoint.shared
#endif
    
    var body: some View {
        ZStack {
            Color(.red)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 60) {
                    Text("Game Over")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Score: \(gameSceneController.score)")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("High Score: \(highScore)")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Button("Restart Game") {
                            withAnimation {
    //                            gameSceneController.gameState = .playing
                                gameSceneController.startGame()
                            }
                        }
                        .font(.title2)
                        
                        Spacer()
                        
                        Button("Main Menu") {
                            gameSceneController.gameState = .mainMenu
                        }
                        .font(.title2)
                    }
                    .padding()
                }
                .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
#if !os(watchOS)
        .onAppear {
            accessPoint.location = .topLeading
            accessPoint.showHighlights = true
            accessPoint.isActive = true
            
            if gameSceneController.score > highScore {
                highScore = gameSceneController.score
                
                Task {
                    await gameCenterController.submitScoreToGameCenter(score: gameSceneController.score)
                }
            }
        }
#endif
    }
}

#Preview {
    GameOverView(gameSceneController: .constant(GameSceneController()))
}
