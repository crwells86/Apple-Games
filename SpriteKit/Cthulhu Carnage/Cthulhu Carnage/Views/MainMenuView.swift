import SwiftUI
import GameKit

struct MainMenuView: View {
    @Environment(\.gameEnvironment) var gameEnvironment
    
    var body: some View {
        ZStack {
            Color(.green)
                .ignoresSafeArea()
            
            VStack {
                Text("Cthulhu Carnage")
                    .font(.system(size: 72))
                    .fontWeight(.bold)
                
                Button("Single Player") {
                    withAnimation {
                        gameEnvironment.gameSceneController.gameState = .playing
                    }
                }
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                
                Button("Multiplayer") {
                    withAnimation {
                        gameEnvironment.gameSceneController.gameState = .multiplayer
                    }
                }
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.vertical)
                
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
