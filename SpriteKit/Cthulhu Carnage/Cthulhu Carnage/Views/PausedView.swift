import SwiftUI
import GameKit

struct PausedView: View {
    @Environment(\.gameEnvironment) var gameEnvironment
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Paused View")
                .font(.largeTitle)
            Button("Resume Game") {
                gameEnvironment.gameSceneController.gameState = .playing
            }
            Button("Main Menu") {
                gameEnvironment.gameSceneController.gameState = .mainMenu
            }
        }
    }
}

#Preview {
    PausedView()
        .environment(\.gameEnvironment, GameEnvironment(
            gameSceneController: GameSceneController(size: CGSize(width: 375, height: 812)),
            accessPoint: GKAccessPoint.shared,
            gameCenterController: GameCenterController.shared
        ))
}
