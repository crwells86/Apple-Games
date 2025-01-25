import SpriteKit

@Observable class GameSceneController: SKScene, SKPhysicsContactDelegate {
    var gameState: GameState = .mainMenu
    
    var enemiesDefeated = 0
    var coinsCollected = 0
    var score = 0
    
    var player = SKSpriteNode()
    var enemy = SKSpriteNode()
    var spriteSize = CGSize(width: 55, height: 55)
    
    var inputController: InputController?
    
    // MARK: - Game Setup
    override func didMove(to view: SKView) {
        size = getWindowSize()!
        backgroundColor = .black
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -20)
        
        inputController = InputController(gameSceneController: self)
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
    
    func startGame() {
        gameState = .playing
        enemiesDefeated = 0
        coinsCollected = 0
        score = 0
        
        setupPlayer()
        setupEnemy()
        setupPlatform()
    }
    
    // MARK: - Player Initialization
    func setupPlayer() {
        player = SKSpriteNode(color: .clear, size: spriteSize)
        player.position = CGPoint(x: size.width / 4, y: (spriteSize.height * 2) + 12)
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.coin.rawValue | CollisionTypes.enemy.rawValue | CollisionTypes.platform.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.platform.rawValue
        
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        
        let animationTextures = [
            SKTexture(image: .player00),
            SKTexture(image: .player01)
        ]
        
        let animationAction = SKAction.animate(with: animationTextures, timePerFrame: 0.3)
        let repeatAction = SKAction.repeatForever(animationAction)
        
        player.run(repeatAction)
    }
    
    func changePlayerDirection() {
        player.xScale *= -1
    }
    
    //MARK: - Platform Initialization
    func setupPlatform() {
        let platformTexture = SKTexture(image: .platform)
        var platformXPosition: CGFloat = 0
        
        for _ in 0..<50 {
            let platform = SKSpriteNode(texture: platformTexture, size: spriteSize)
            platform.position.y = spriteSize.height + 12
            platform.position.x = platformXPosition
            
            platformXPosition += spriteSize.width
            setupPhysics(for: platform, type: .platform)
            
            addChild(platform)
        }
    }
    
    // MARK: - Enemy Initialization
    func setupEnemy() {
        let enemy = SKSpriteNode(color: .clear, size: spriteSize)
        
        enemy.position =  CGPoint(x: 900, y: (spriteSize.height * 2) + 12)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        enemy.physicsBody?.categoryBitMask = CollisionTypes.enemy.rawValue
        enemy.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue | CollisionTypes.platform.rawValue
        enemy.physicsBody?.collisionBitMask = CollisionTypes.platform.rawValue
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.allowsRotation = false
        
        let animationTextures = [
            SKTexture(image: .enemy00),
            SKTexture(image: .enemy01)
        ]
        
        let animationAction = SKAction.animate(with: animationTextures, timePerFrame: 0.3)
        let repeatAction = SKAction.repeatForever(animationAction)
        
        enemy.run(repeatAction)
        
        let walkActionOne = SKAction.move(by: CGVector(dx: spriteSize.width, dy: 0), duration: 1.5)
        let walkActionTwo = SKAction.move(by: CGVector(dx: -spriteSize.width, dy: 0), duration: 1.5)
        let repeatWalkAction = SKAction.repeatForever(SKAction.sequence([walkActionOne, walkActionTwo]))
        enemy.run(repeatWalkAction)
        
        addChild(enemy)
    }
    
    // MARK: - Level Logic
    func setupPhysics(for node: SKSpriteNode, type: TileType) {
        switch type {
        case .platform:
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
            node.physicsBody?.categoryBitMask = CollisionTypes.platform.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue
            node.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.isDynamic = false
        case .coin:
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
            node.physicsBody?.categoryBitMask = CollisionTypes.coin.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
            node.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.isDynamic = false
        default:
            break
        }
    }
    
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        // Move the player continuously to the left or right
        let playerSpeed: CGFloat = 2
        player.position.x += player.xScale > 0 ? playerSpeed : -playerSpeed
        
        // Wrap the player to the other side when reaching the screen edges
        if player.position.x > size.width {
            player.position.x = 0
        } else if player.position.x < 0 {
            player.position.x = size.width
        }
        
        // Set the constant speed you desire for the enemy
        let enemySpeed: CGFloat = 2.01
        
        // Calculate the direction towards the player
        let direction = player.position.x > enemy.position.x ? 1 : -1
        
        // Move the enemy towards the player
        enemy.position.x += CGFloat(direction) * enemySpeed
        
        // Check if the enemy is close to the screen edges to switch direction
        let edgeThreshold: CGFloat = 32
        
        if enemy.position.x > size.width / 2 - edgeThreshold {
            enemy.position.x = size.width / 2 - edgeThreshold
        } else if enemy.position.x < -size.width / 2 + edgeThreshold {
            enemy.position.x = -size.width / 2 + edgeThreshold
        }
    }
    
    // MARK: - Collision Detection
    func didBegin(_ contact: SKPhysicsContact) {
        handleContact(contact)
    }
    
    func handleContact(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.coin.rawValue) {
            if let coin = contact.bodyA.categoryBitMask == CollisionTypes.coin.rawValue ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                coin.removeFromParent()
                score += 2
                coinsCollected += 1
            }
        }
        
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue) {
            gameOver()
        }
    }
    
    // MARK: - Game Over Logic
    func gameOver() {
        gameState = .gameOver
        removeAllChildren()
    }
}


//MARK: - Game Center
import GameKit

@Observable class GameCenterController: NSObject {
    static let shared = GameCenterController()
    var authenticated = false
    
    private override init() {
        super.init()
        authenticatePlayer()
    }
    
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController = viewController {
#if os(macOS)
                if let window = NSApplication.shared.windows.first {
                    window.contentViewController?.presentAsModalWindow(viewController)
                }
#else
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    scene.windows.first?.rootViewController?.present(viewController, animated: true, completion: nil)
                }
#endif
            } else if GKLocalPlayer.local.isAuthenticated {
                self.authenticated = true
            } else {
                print("Game Center authentication failed with error: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    //MARK: - High Score
    func submitScoreToGameCenter(score: Int) async {
        guard self.authenticated else {
            return
        }
        
        let gkScore = GKLeaderboardScore()
        gkScore.value = score
        
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: ["1DHighScore", "1DDashDailyHighScore"]
        ) { error in
            if let error = error {
                print("Failed to report high score to Game Center: \(error.localizedDescription)")
            } else {
                print("High score reported successfully!")
            }
        }
    }
    
    //MARK: - Achievement
    // ?
}
