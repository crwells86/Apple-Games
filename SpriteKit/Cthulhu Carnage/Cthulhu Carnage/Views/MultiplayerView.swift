import SwiftUI
import GameKit

@Observable class PlayerSelectController {
    var selectedSpriteIndex = 0
    var selectedColorIndex = 0
    var isSelected = false
    
    let availableSprites: [String] = ["🚶🏻", "🏃🏻", "🚶🏼‍♀️", "🏃🏻‍♀️"]
    
    var currentSprite: String {
        availableSprites[selectedSpriteIndex % availableSprites.count]
    }
    
    func previousSprite() {
        selectedSpriteIndex = (selectedSpriteIndex - 1 + availableSprites.count) % availableSprites.count
    }
    
    func nextSprite() {
        selectedSpriteIndex = (selectedSpriteIndex + 1) % availableSprites.count
    }
    
    func select() {
        isSelected = true
    }
}


struct PlayerSelectView: View {
    @Binding var controller: PlayerSelectController
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                controller.previousSprite()
            } label: {
                Image(systemName: "chevron.up.circle")
                    .font(.title)
            }
            .buttonStyle(.plain)
            
            Text(controller.currentSprite)
                .font(.system(size: 88))
                .onTapGesture {
                    if !controller.isSelected {
                        controller.select()
                    }
                }
            
            Button {
                controller.nextSprite()
            } label: {
                Image(systemName: "chevron.down.circle")
                    .font(.title)
            }
            
            Text("Bob")
                .padding(.top, 4)
        }
        .padding()
        .opacity(controller.isSelected ? 1.0 : 0.5)
        .overlay(
            Group {
                if !controller.isSelected {
                    Text("Tap")
                        .font(.caption)
                        .padding(4)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                        .padding(4)
                }
            }
        )
        .onTapGesture {
            if !controller.isSelected {
                controller.select()
            }
        }
    }
}

struct MultiplayerView: View {
    @Environment(\.gameEnvironment) var gameEnvironment
    @State private var playerControllers = (0..<4).map { _ in PlayerSelectController() }
    
    var body: some View {
        VStack {
            Text("Select Your Character")
                .font(.title)
                .fontWeight(.semibold)
                .padding()
            
            HStack {
                ForEach(0..<playerControllers.count, id: \.self) { index in
                    PlayerSelectView(controller: $playerControllers[index])
                }
            }
            
            HStack {
                Button {
                    gameEnvironment.gameSceneController.gameState = .mainMenu
                } label: {
                    Text("Back")
                }
                
                Spacer()
                
                Button {
                    gameEnvironment.gameSceneController.gameState = .playing
                } label: {
                    Text("Play")
                }
            }
            .padding()
        }
    }
}

#Preview {
    MultiplayerView()
        .environment(\.gameEnvironment, GameEnvironment(
            gameSceneController: GameSceneController(size: CGSize(width: 375, height: 812)),
            accessPoint: GKAccessPoint.shared,
            gameCenterController: GameCenterController.shared
        ))
}
