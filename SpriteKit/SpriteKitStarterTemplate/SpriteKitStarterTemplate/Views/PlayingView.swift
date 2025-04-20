import SwiftUI
import SpriteKit
import GameKit

struct PlayingView: View {
    @Environment(\.gameEnvironment) var gameEnvironment
    
    var body: some View {
        SpriteView(scene: gameEnvironment.gameSceneController)
            .ignoresSafeArea()
            .overlay(alignment: .top) {
                HStack {
                    Text("Score: \(gameEnvironment.gameSceneController.score)")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        gameEnvironment.gameSceneController.gameState = .paused
                    } label: {
                        Text("Pause")
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            .onAppear {
                gameEnvironment.accessPoint.isActive = false
            }
    }
}

#Preview {
    PlayingView()
        .environment(\.gameEnvironment, GameEnvironment(
            gameSceneController: GameSceneController(size: CGSize(width: 375, height: 812)),
            accessPoint: GKAccessPoint.shared,
            gameCenterController: GameCenterController.shared
        ))
}
