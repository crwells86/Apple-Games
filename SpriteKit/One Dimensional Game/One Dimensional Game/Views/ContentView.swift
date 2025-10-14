import SwiftUI
import GameKit

//struct ContentView: View {
//    @State private var gameSceneController = GameSceneController()
//
//#if !os(watchOS)
//    var gameCenterController = GameCenterController.shared
//    let accessPoint = GKAccessPoint.shared
//#endif
//
//    var body: some View {
//        switch gameSceneController.gameState {
//        case .playing:
//            GameView(gameSceneController: $gameSceneController)
//                .onAppear {
//#if !os(watchOS)
//                    accessPoint.isActive = false
//#endif
//                }
//        case .gameOver:
//            GameOverView(gameSceneController: $gameSceneController)
//                .onAppear {
//#if !os(watchOS)
//                    accessPoint.location = .topLeading
//                    accessPoint.showHighlights = true
//                    accessPoint.isActive = true
//#endif
//                }
//        case .mainMenu:
//            MainMenuView(gameSceneController: $gameSceneController)
//#if !os(watchOS)
//                .onAppear {
//                    accessPoint.location = .topLeading
//                    accessPoint.showHighlights = true
//                    accessPoint.isActive = true
//                }
//                .onDisappear {
//                    accessPoint.isActive = false
//                }
//#endif
//        }
//    }
//}

struct ContentView: View {
    @State private var gameSceneController = GameSceneController()
    @State private var sceneID = UUID() // ← Add this to force recreation
    
#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
    var gameCenterController = GameCenterController.shared
    let accessPoint = GKAccessPoint.shared
#endif
    
    var body: some View {
        switch gameSceneController.gameState {
        case .playing:
            GameView(gameSceneController: $gameSceneController)
                .id(sceneID) // ← Force view recreation
                .onAppear {
                    #if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
                    accessPoint.isActive = false
                    #endif
                }
        case .gameOver:
            GameOverView(gameSceneController: $gameSceneController)
                .onAppear {
                    #if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
                    accessPoint.location = .topLeading
                    accessPoint.showHighlights = true
                    accessPoint.isActive = true
                    #endif
                }
        case .mainMenu:
            MainMenuView(gameSceneController: $gameSceneController)
            #if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
                .onAppear {
                    accessPoint.location = .topLeading
                    accessPoint.showHighlights = true
                    accessPoint.isActive = true
                }
                .onDisappear {
                    accessPoint.isActive = false
                }
            #endif
        }
    }
}

#Preview {
    ContentView()
}
