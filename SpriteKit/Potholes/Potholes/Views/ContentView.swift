import SwiftUI
import SpriteKit
import GameKit

struct ContentView: View {
    @State private var gameSceneController = GameSceneController(size: UIScreen.main.bounds.size)
    var gameCenterController = GameCenterController.shared
    let accessPoint = GKAccessPoint.shared
    
    @AppStorage("gameHighScore") var highScore = 0
    
    var body: some View {
        switch gameSceneController.gameState {
        case .playing:
            SpriteView(scene: gameSceneController)
                .ignoresSafeArea()
                .overlay(alignment: .topLeading) {
                    Text("Score: \(gameSceneController.score)")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundStyle(.white)
                }
                .onAppear {
                    accessPoint.isActive = false
                }
        case .paused:
            VStack(spacing: 40) {
                Text("Paused View")
                    .font(.largeTitle)
                Button("Resume Game") {
                    gameSceneController.gameState = .playing
                }
                Button("Main Menu") {
                    gameSceneController.gameState = .mainMenu
                }
            }
        case .gameOver:
            ZStack {
                Image(.bg)
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 60) {
                    Text("Game Over")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Score: \(gameSceneController.score)")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text("High Score: \(highScore)")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Button("Restart Game") {
                        withAnimation {
                            gameSceneController.gameState = .playing
                        }
                    }
                    .font(.title2)
                    
                    Button("Main Menu") {
                        gameSceneController.gameState = .mainMenu
                    }
                    .font(.title2)
                }
                .foregroundStyle(.white)
            }
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
        case .mainMenu:
            ZStack {
                Image(.bg)
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 120) {
                    VStack {
                        Text("Potholes")
                            .font(.system(size: 72))
                            .fontWeight(.bold)
                        
                        Text("Fury Road")
                            .font(.system(size: 42))
                            .fontWeight(.bold)
                    }
                    
                    Button("Start Game") {
                        withAnimation {
                            gameSceneController.gameState = .playing
                        }
                    }
                    .font(.largeTitle)
                    .fontWeight(.bold)
                }
                .foregroundStyle(.white)
                .transition(.move(edge: .bottom))
            }
            .onAppear {
                accessPoint.location = .topLeading
                accessPoint.showHighlights = true
                accessPoint.isActive = true
            }
            .onDisappear {
                accessPoint.isActive = false
            }
        }
    }
}

#Preview {
    ContentView()
}
