import SpriteKit

@Observable class GameSceneController: SKScene, SKPhysicsContactDelegate {
    var gameState: GameState = .mainMenu
}
