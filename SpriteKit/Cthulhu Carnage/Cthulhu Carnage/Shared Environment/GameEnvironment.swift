import SwiftUI
import GameKit

struct GameEnvironment {
    var gameSceneController: GameSceneController
    var accessPoint: GKAccessPoint
    var gameCenterController: GameCenterController
}

struct GameEnvironmentKey: EnvironmentKey {
    static let defaultValue: GameEnvironment = GameEnvironment(
        gameSceneController: GameSceneController(size: .zero), // placeholder; will be overridden
        accessPoint: GKAccessPoint.shared,
        gameCenterController: GameCenterController.shared
    )
}

extension EnvironmentValues {
    var gameEnvironment: GameEnvironment {
        get { self[GameEnvironmentKey.self] }
        set { self[GameEnvironmentKey.self] = newValue }
    }
}

// Great article by Natalia Panferova about SwiftUI Environment
// https://nilcoalescing.com/blog/SwiftUIEnvironment/
