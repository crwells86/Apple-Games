import SwiftUI
import SpriteKit

struct GameView: View {
    @Binding var gameSceneController: GameSceneController
    
    @State var digitalCrownRotationAmount = 0.0
    @State private var lastStep: Int = 0
    @State private var accumulatedSteps: Int = 0
    let stepThreshold = 3 // tune this
    
    
    var body: some View {
        ZStack {
            SpriteView(scene: gameSceneController)
                .ignoresSafeArea()
                .onAppear {
#if os(watchOS)
                    gameSceneController.didMoveToWatchView()
#endif
                }
            
#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
            ZStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Score: \(gameSceneController.score)")
                        Text("Level: \(gameSceneController.currentLevel)")
                    }
                    .font(.title3)
                    
                    Spacer()
                    
                    Text("High Score: \(UserDefaults.standard.integer(forKey: "gameHighScore"))")
                        .font(.title3)
                }
                .foregroundStyle(.black)
                .offset(x: 1, y: 2)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Score: \(gameSceneController.score)")
                        Text("Level: \(gameSceneController.currentLevel)")
                    }
                    .font(.title3)
                    
                    Spacer()
                    
                    Text("High Score: \(UserDefaults.standard.integer(forKey: "gameHighScore"))")
                        .font(.title3)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .foregroundStyle(.white)
            .padding()
#endif
#if os(watchOS)
            HStack {
                ZStack {
                    VStack(alignment: .leading) {
                        Text("Score: \(gameSceneController.score)")
                        Text("Level: \(gameSceneController.currentLevel)")
                    }
                    .foregroundStyle(.black)
                    .offset(x: 1, y: 2)
                    
                    VStack(alignment: .leading) {
                        Text("Score: \(gameSceneController.score)")
                        Text("Level: \(gameSceneController.currentLevel)")
                    }
                }
                
                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .foregroundStyle(.white)
            .padding()
#endif
        }
        .buttonStyle(.plain)
#if os(watchOS)
        .focusable(true)
        //        .digitalCrownRotation($digitalCrownRotationAmount, from: 1, through: 2, by: 1, sensitivity: .low, isContinuous: false)
        //        .onChange(of: digitalCrownRotationAmount) {
        //            if digitalCrownRotationAmount == 1 || digitalCrownRotationAmount == 2 {
        //                gameSceneController.changePlayerDirection()
        //            }
        //        }
        .digitalCrownRotation(
            $digitalCrownRotationAmount,
            from: -1000, through: 1000, by: 1,
            sensitivity: .low,
            isContinuous: true, isHapticFeedbackEnabled: true
        )
        //        .onChange(of: digitalCrownRotationAmount) {
        //            let step = Int(digitalCrownRotationAmount.rounded())
        //            if step != lastStep {
        //                // Decide if we want to react to every step or every N steps
        //                gameSceneController.changePlayerDirection()
        //                lastStep = step
        //            }
        //        }
        
        .onChange(of: digitalCrownRotationAmount) {
            let step = Int(digitalCrownRotationAmount.rounded())
            let delta = step - lastStep
            guard delta != 0 else { return }
            
            accumulatedSteps += delta
            lastStep = step
            
            if abs(accumulatedSteps) >= stepThreshold {
                if accumulatedSteps > 0 {
                    gameSceneController.changePlayerDirection()
                } else {
                    gameSceneController.changePlayerDirection()
                }
                accumulatedSteps = 0
            }
        }
#endif
    }
}

#Preview {
    GameView(gameSceneController: .constant(GameSceneController()))
}
