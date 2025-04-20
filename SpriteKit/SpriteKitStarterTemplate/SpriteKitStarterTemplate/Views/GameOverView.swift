import SwiftUI
import GameKit

struct GameOverView: View {
    @Environment(\.gameEnvironment) var gameEnvironment
    @AppStorage("gameHighScore") var highScore = 0
    
    var body: some View {
        ZStack {
            Color(.red)
                .ignoresSafeArea()
            
            VStack(spacing: 60) {
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    Text("Score: \(gameEnvironment.gameSceneController.score)")
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
                            gameEnvironment.gameSceneController.gameState = .playing
                        }
                    }
                    .font(.title2)
                    
                    Spacer()
                    
                    Button("Main Menu") {
                        gameEnvironment.gameSceneController.gameState = .mainMenu
                    }
                    .font(.title2)
                }
                .padding()
            }
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .onAppear {
            gameEnvironment.accessPoint.location = .topLeading
            gameEnvironment.accessPoint.showHighlights = true
            gameEnvironment.accessPoint.isActive = true
            
            if gameEnvironment.gameSceneController.score > highScore {
                highScore = gameEnvironment.gameSceneController.score
                
                Task {
                    await gameEnvironment.gameCenterController.submitScoreToGameCenter(score: gameEnvironment.gameSceneController.score)
                }
            }
        }
    }
}

#Preview {
    return GameOverView()
        .environment(\.gameEnvironment, GameEnvironment(
            gameSceneController: GameSceneController(size: CGSize(width: 375, height: 812)),
            accessPoint: GKAccessPoint.shared,
            gameCenterController: GameCenterController.shared
        ))
}

