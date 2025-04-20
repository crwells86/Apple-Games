import SwiftUI
import GameKit

struct MainMenuView: View {
    @Environment(\.gameEnvironment) var gameEnvironment
    
    var body: some View {
        ZStack {
            Color(.green)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("SpriteKit\nStarter Template")
                    .font(.system(size: 72))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Button("Play") {
                    withAnimation {
                        gameEnvironment.gameSceneController.gameState = .playing
                    }
                }
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                
                Button("Options") {
                    withAnimation {
                        gameEnvironment.gameSceneController.gameState = .options
                    }
                }
                .font(.largeTitle)
                .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .transition(.move(edge: .bottom))
        }
        .buttonStyle(.plain)
        .onAppear {
            gameEnvironment.accessPoint.location = .topLeading
            gameEnvironment.accessPoint.showHighlights = true
            gameEnvironment.accessPoint.isActive = true
        }
        .onDisappear {
            gameEnvironment.accessPoint.isActive = false
        }
    }
}

#Preview {
    return MainMenuView()
        .environment(\.gameEnvironment, GameEnvironment(
            gameSceneController: GameSceneController(size: CGSize(width: 375, height: 812)),
            accessPoint: GKAccessPoint.shared,
            gameCenterController: GameCenterController.shared
        ))
}
