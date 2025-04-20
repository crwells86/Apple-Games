import SwiftUI
import GameKit

struct OptionsView: View {
    @Environment(\.gameEnvironment) var gameEnvironment
    
    @State private var musicEnabled: Bool = true
    @State private var sfxEnabled: Bool = true
    @State private var difficultyIndex: Int = 1
    
    var body: some View {
        ScrollView {
            Text("Options")
                .font(.largeTitle)
            
            Form {
                Section(header: Text("Audio")) {
                    Toggle("Music", isOn: $musicEnabled)
                    Toggle("Sound Effects", isOn: $sfxEnabled)
                }
                
                Section(header: Text("Gameplay")) {
                    Picker("Difficulty", selection: $difficultyIndex) {
                        Text("Easy").tag(0)
                        Text("Normal").tag(1)
                        Text("Hard").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            
            Button("back") {
                withAnimation {
                    gameEnvironment.gameSceneController.gameState = .mainMenu
                }
            }
            .padding()
        }
        .buttonStyle(.plain)
        .padding()
    }
}

#Preview {
    OptionsView()
        .environment(\.gameEnvironment, GameEnvironment(
            gameSceneController: GameSceneController(size: CGSize(width: 375, height: 812)),
            accessPoint: GKAccessPoint.shared,
            gameCenterController: GameCenterController.shared
        ))
}
