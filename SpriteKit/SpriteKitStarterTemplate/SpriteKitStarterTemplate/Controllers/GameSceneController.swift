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
    
    var player = SKShapeNode()
    var enemy = SKShapeNode()
    var collectible = SKShapeNode()
    
    override func didMove(to view: SKView) {
        size = getWindowSize()!
        backgroundColor = .magenta
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
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
    
#if os(iOS) || os(tvOS) || os(visionOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            player.run(SKAction.move(to: location, duration: 0.3))
        }
    }
#elseif os(macOS)
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        player.run(SKAction.move(to: location, duration: 0.3))
    }
#endif
    
    func restartGame() {
        score = 0
        removeAllChildren()
        removeAllActions()
        
        playBackgroundMusic(filename: "backgroundMusic.wav")
        backgroundMusicPlayer?.volume = 0.09
        
        // Create Player (blue)
        player = SKShapeNode(circleOfRadius: 30)
        player.fillColor = .blue
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        player.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.collectible | PhysicsCategory.enemy
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        addChild(player)
        
        // Create Enemy (red)
        enemy = SKShapeNode(circleOfRadius: 30)
        enemy.fillColor = .red
        enemy.position = CGPoint(x: 300, y: 100)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.player
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.none
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.isDynamic = true
        addChild(enemy)
        
        // Create Collectible (green)
        collectible = SKShapeNode(circleOfRadius: 20)
        collectible.fillColor = .purple
        collectible.position = CGPoint(x: getWindowSize()!.width / 2, y: getWindowSize()!.height / 2)
        collectible.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        collectible.physicsBody?.categoryBitMask = PhysicsCategory.collectible
        collectible.physicsBody?.contactTestBitMask = PhysicsCategory.player
        collectible.physicsBody?.collisionBitMask = PhysicsCategory.none
        collectible.physicsBody?.affectedByGravity = false
        collectible.physicsBody?.isDynamic = false
        addChild(collectible)
    }
    
    // MARK: - Collision Handling
    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask
        
        // Player collects item
        if (a == PhysicsCategory.player && b == PhysicsCategory.collectible) ||
            (b == PhysicsCategory.player && a == PhysicsCategory.collectible) {
            collectible.removeFromParent()
            score += 1
            print("Collected! Score: \(score)")
        }
        
        // Player hit by enemy
        if (a == PhysicsCategory.player && b == PhysicsCategory.enemy) ||
            (b == PhysicsCategory.player && a == PhysicsCategory.enemy) {
            gameOver()
            print("Game Over")
        }
    }
    
    func gameOver() {
        gameState = .gameOver
        
        backgroundMusicPlayer?.stop()
        
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
        super.update(currentTime)
        checkForAchievements()
        
        let dx = player.position.x - enemy.position.x
        let dy = player.position.y - enemy.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance > 1 {
            let moveSpeed: CGFloat = 1.0
            let direction = CGVector(dx: dx / distance * moveSpeed, dy: dy / distance * moveSpeed)
            enemy.position = CGPoint(x: enemy.position.x + direction.dx, y: enemy.position.y + direction.dy)
        }
    }
    
    func checkForAchievements() {
        GameCenterController.shared.reportAchievement(identifier: "ID ?", percentComplete: 100)
    }
}
