import SwiftUI
import GameKit

struct MainMenuView: View {
    @Environment(\.gameEnvironment) var gameEnvironment
    
    var body: some View {
        ZStack {
            Color(.green)
                .ignoresSafeArea()
            
            VStack {
                Text("Get a Chicken")
                    .font(.system(size: 55, weight: .black, design: .rounded))
                
                Button("Play") {
                    withAnimation {
                        gameEnvironment.gameSceneController.gameState = .playing
                    }
                }
                .font(.system(size: 42, weight: .black, design: .rounded))
                .padding(.top)
                
                Button("Options") {
                    withAnimation {
                        gameEnvironment.gameSceneController.gameState = .options
                    }
                }
                .font(.system(size: 42, weight: .black, design: .rounded))
            }
            .foregroundStyle(.white)
            .transition(.move(edge: .bottom))
        }
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
