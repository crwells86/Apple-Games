import SpriteKit
import AVFoundation

@Observable class GameSceneController: SKScene, SKPhysicsContactDelegate {
    var gameState: GameState = .mainMenu {
        didSet {
            if gameState == .playing {
                restartGame()
            }
        }
    }
    
    var score = 0
    
    var backgroundMusicPlayer: AVAudioPlayer?
    
    let light = SKLightNode()
    
    override func didMove(to view: SKView) {
        size = getWindowSize()!
        backgroundColor = .magenta
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        if gameState == .playing {
            // Create a Light Node
            let light = SKLightNode()
            light.position = CGPoint(x: size.width / 2, y: size.height / 2)
            light.lightColor = .white
            light.ambientColor = .gray
            light.falloff = 1.0
            light.categoryBitMask = 1 // Light affects nodes with matching bitmask
            addChild(light)

            // Create an Object That Casts a Shadow (Use an Image Instead of a Solid Color)
            let shadowCaster = SKSpriteNode(imageNamed: "cloud")
//            SKSpriteNode(texture: SKTexture(imageNamed: "cloud"))
            shadowCaster.size = CGSize(width: 200, height: 140)
            shadowCaster.position = CGPoint(x: size.width / 2 - 200, y: size.height / 2 - 100)
            shadowCaster.lightingBitMask = 1 // Affected by the light
            shadowCaster.shadowCastBitMask = 1 // This node casts shadows
            addChild(shadowCaster)

            // Create an Object That Receives a Shadow
            let shadowReceiver = SKSpriteNode(color: .gray, size: CGSize(width: 200, height: 20))
            shadowReceiver.position = CGPoint(x: size.width / 2, y: size.height / 2 - 150)
            shadowReceiver.shadowedBitMask = 1 // This node receives shadows
            addChild(shadowReceiver)

            // Animate the Shadow-Casting Object
            let moveAction = SKAction.moveBy(x: 400, y: 0, duration: 5.0) // Move to the right
            let moveBackAction = SKAction.moveBy(x: -400, y: 0, duration: 5.0) // Move back to the left
            let sequence = SKAction.sequence([moveAction, moveBackAction])
            let repeatForever = SKAction.repeatForever(sequence)

            shadowCaster.run(repeatForever)

        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            light.position = touch.location(in: self)
        }
    }
    
    func getWindowSize() -> CGSize? {
#if os(iOS) || os(tvOS) || os(visionOS)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow.frame.size
        }
#elseif os(macOS)
        if let window = NSApplication.shared.windows.first {
            return window.frame.size
        }
#endif
        return nil
    }
    
    func restartGame() {
        score = 0
        removeAllChildren()
        removeAllActions()
        
        playBackgroundMusic(filename: "backgroundMusic.wav")
        backgroundMusicPlayer?.volume = 0.09
    }
    
    // MARK: - Collision Handling
    func didBegin(_ contact: SKPhysicsContact) {
        // ?
    }
    
    func gameOver() {
        gameState = .gameOver
        
        backgroundMusicPlayer!.stop()
        
        removeAllActions()
    }
    
    // MARK: - Audio Logic
    func playBackgroundMusic(filename: String) {
        if let musicURL = Bundle.main.url(forResource: filename, withExtension: nil) {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.play()
            } catch {
                print("Could not play background music: \(error)")
            }
        }
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        checkForAchievements()
    }
    
    func checkForAchievements() {
        GameCenterController.shared.reportAchievement(identifier: "ID ?", percentComplete: 100)
    }
}
