import SpriteKit
#if os(watchOS)
import WatchKit
#endif

@Observable class GameSceneController: SKScene, SKPhysicsContactDelegate {
    var gameState: GameState = .mainMenu
    
    var enemiesDefeated = 0
    var coinsCollected = 0
    var score = 0
    
    var player = SKSpriteNode()
    var enemy = SKSpriteNode()
    
    // Cross-platform scaling and level rules
    private var unit: CGFloat { max(8, min(size.width, size.height) / 24) } // base unit scales with screen
    private var groundY: CGFloat { unit * 2 } // platform height reference
    private var playerSpeedPerFrame: CGFloat { unit * 0.18 } // tuned across devices
    private var enemySpeedPerFrame: CGFloat { unit * 0.185 } // slightly faster than player
    private var coinCountThisLevel: Int = 0
    var currentLevel: Int = 1
    private var playerDirection: CGFloat = 1 // 1 = to trailing, -1 = to leading
    private var platformSpeedScale: CGFloat {
#if os(watchOS)
        return 0.32 // slower on Apple Watch for comfort
#else
        return 0.72
#endif
    }
    private var lastUpdateTime: TimeInterval = 0
    private var didInitializeForCurrentSize = false
    private var isStartingRun: Bool = false
    
#if !os(watchOS)
    var spriteSize = CGSize(width: 55, height: 55)
    var inputController: InputController?
#else
    var spriteSize = CGSize(width: 27, height: 27)
#endif
    
    // MARK: - Game Setup
#if !os(watchOS)
    override func didMove(to view: SKView) {
        size = getWindowSize() ?? size
        configureWorld()
        initializeIfNeededForCurrentSize()
        inputController = InputController(gameSceneController: self)
    }
#endif
    
    func didMoveToWatchView() {
        size = getWindowSize() ?? size
        configureWorld()
        initializeIfNeededForCurrentSize()
    }
    
    private func configureWorld() {
        backgroundColor = .black
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }

    private func initializeIfNeededForCurrentSize() {
        // Ensure we only initialize per valid, non-zero size changes
        guard size.width > 0 && size.height > 0 else { return }
        didInitializeForCurrentSize = true
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
#elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
#endif
        
#if !os(watchOS)
        return nil
#endif
    }
    
    private func resetSceneState() {
        // Normalize scene timing and state
        isPaused = true
        speed = 1.0
        physicsWorld.speed = 1.0
        removeAllActions()
        // Remove actions from all descendants to avoid retained animations
        enumerateChildNodes(withName: "//*") { node, _ in
            node.removeAllActions()
        }
        // Remove all nodes to guarantee a clean slate
        removeAllChildren()

        // Clear per-run state
        player.removeAllActions()
        enemy.removeAllActions()
        enemy.userData = nil
        lastUpdateTime = 0
        didInitializeForCurrentSize = false

        // Unpause for the next run
        isPaused = false
    }
    
    func startGame() {
        // Prevent accidental double starts during UI transitions
        if isStartingRun { return }
        isStartingRun = true

        gameState = .playing
        enemiesDefeated = 0
        coinsCollected = 0
        score = 0
        currentLevel = 1

        resetSceneState()
        // Ensure size is current before layout
        size = getWindowSize() ?? size
        configureWorld()
        initializeIfNeededForCurrentSize()

        playerDirection = 1
        setupPlatforms()
        setupPlayerAtLeadingEdge()
        setupEnemyAtTrailingEdge()
        spawnCoinsForNewLevel()

        isStartingRun = false
    }
    
    // MARK: - Player Initialization
    func setupPlayerAtLeadingEdge() {
        let sizeSide = unit * 2.2
        player = SKSpriteNode(color: .clear, size: CGSize(width: sizeSide, height: sizeSide))
        player.name = "player"
        player.zPosition = 10
        // Leading edge start
        let startX = unit * 2.0
        player.position = CGPoint(x: startX, y: groundY + sizeSide)
        addChild(player)

        player.physicsBody = SKPhysicsBody(circleOfRadius: sizeSide / 2)
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.coin.rawValue | CollisionTypes.enemy.rawValue | CollisionTypes.platform.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.platform.rawValue
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false

        // Face toward trailing edge initially
        player.xScale = abs(player.xScale == 0 ? 1 : player.xScale)
        playerDirection = 1

        let animationTextures = [
            SKTexture(imageNamed: "player00"),
            SKTexture(imageNamed: "player01")
        ]
        let animationAction = SKAction.animate(with: animationTextures, timePerFrame: 0.3)
        let repeatAction = SKAction.repeatForever(animationAction)
        player.run(repeatAction)
    }
    
    func changePlayerDirection() {
        playerDirection *= -1
        if player.xScale == 0 { player.xScale = 1 }
        player.xScale = abs(player.xScale) * (playerDirection > 0 ? 1 : -1)
    }
    
    // MARK: - Platform Initialization
    func setupPlatforms() {
        let platformTexture = SKTexture(imageNamed: "platform")
        let tileSize = CGSize(width: unit * 2.2, height: unit * 2.2)
        var x: CGFloat = 0
        while x < size.width + tileSize.width {
            let platform = SKSpriteNode(texture: platformTexture, size: tileSize)
            platform.name = "platform"
            platform.position = CGPoint(x: x, y: groundY)
            setupPhysics(for: platform, type: .platform)
            addChild(platform)
            x += tileSize.width
        }
    }
    
    // MARK: - Enemy Initialization
    func setupEnemyAtTrailingEdge() {
        let sizeSide = unit * 2.2
        enemy = SKSpriteNode(color: .clear, size: CGSize(width: sizeSide, height: sizeSide))
        enemy.name = "enemy"
        enemy.zPosition = 10
        // Trailing edge start
        let startX = size.width - unit * 2.0
        enemy.position = CGPoint(x: startX, y: groundY + sizeSide)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: sizeSide / 2)
        enemy.physicsBody?.categoryBitMask = CollisionTypes.enemy.rawValue
        enemy.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue | CollisionTypes.platform.rawValue
        enemy.physicsBody?.collisionBitMask = CollisionTypes.platform.rawValue
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.allowsRotation = false

        let animationTextures = [
            SKTexture(imageNamed: "enemy00"),
            SKTexture(imageNamed: "enemy01")
        ]
        let animationAction = SKAction.animate(with: animationTextures, timePerFrame: 0.3)
        let repeatAction = SKAction.repeatForever(animationAction)
        enemy.run(repeatAction)

        addChild(enemy)
        
        // Ensure no immediate overlap at start
        if abs(enemy.position.x - player.position.x) < unit * 3.0 {
            enemy.position.x = min(size.width - unit, player.position.x + unit * 4.0)
        }
        
        // Reset enemy speed multiplier at spawn
        if enemy.userData == nil { enemy.userData = [:] }
        enemy.userData?["speedMultiplier"] = NSNumber(value: 1.0)
    }
    
    // MARK: - Coins
    func spawnCoinsForNewLevel() {
        // 4 to 8 coins
        coinCountThisLevel = Int.random(in: 4...8)
        coinsCollected = 0
        // Animated coin frames coin00..coin02
        let coinTextures: [SKTexture] = [
            SKTexture(imageNamed: "coin00"),
            SKTexture(imageNamed: "coin01"),
            SKTexture(imageNamed: "coin02")
        ]
        let coinAnimation = SKAction.repeatForever(SKAction.animate(with: coinTextures, timePerFrame: 0.33))
        let coinSize = CGSize(width: unit * 1.6, height: unit * 1.6)
        let leftMargin = unit * 2
        let rightMargin = unit * 2
        let span = max(unit * 4, size.width - (leftMargin + rightMargin))
        for i in 0..<coinCountThisLevel {
            let coin = SKSpriteNode(texture: coinTextures.first, size: coinSize)
            coin.name = "coin"
            coin.zPosition = 5
            let fraction = CGFloat(i + 1) / CGFloat(coinCountThisLevel + 1)
            let x = leftMargin + fraction * span
            coin.position = CGPoint(x: x, y: groundY + (unit * 2.2))
            setupPhysics(for: coin, type: .coin)
            addChild(coin)
            coin.run(coinAnimation)
        }
    }
    
#if !os(watchOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        changePlayerDirection()
    }
#endif
    
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
            node.physicsBody?.collisionBitMask = 0
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.isDynamic = false
        default:
            break
        }
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else { return }
        // Delta time for frame-rate independent movement
        let dt: CGFloat
        if lastUpdateTime == 0 {
            dt = 1.0 / 60.0
        } else {
            let raw = currentTime - lastUpdateTime
            // Clamp dt to reasonable bounds to avoid spikes on resume/first frame
            dt = CGFloat(min(1.0/30.0, max(1.0/120.0, raw)))
        }
        lastUpdateTime = currentTime

        let frameScale: CGFloat = 60.0
        // Player moves horizontally with wrap
        player.position.x += playerDirection * playerSpeedPerFrame * platformSpeedScale * (dt * frameScale)
        if player.position.x > size.width { player.position.x = 0 }
        if player.position.x < 0 { player.position.x = size.width }

        // Enemy homes toward player, no wrap; clamp to scene bounds
        let dir: CGFloat = player.position.x > enemy.position.x ? 1 : -1
        let mult = (enemy.userData?["speedMultiplier"] as? NSNumber)?.doubleValue ?? 1.0
        enemy.position.x += dir * enemySpeedPerFrame * CGFloat(mult) * platformSpeedScale * (dt * frameScale)
        enemy.position.x = min(max(enemy.position.x, 0), size.width)
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
                if coinsCollected >= coinCountThisLevel {
                    // Next level: respawn enemy slightly faster and more coins
                    currentLevel += 1
                    score += 5
//                    enemySpeedUpForNextLevel()
                    spawnCoinsForNewLevel()
                }
            }
        }
        
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue) {
            gameOver()
        }
    }
    
//    private func enemySpeedUpForNextLevel() {
//        let increment = min(0.06, 0.01 * CGFloat(currentLevel))
//        if enemy.userData == nil { enemy.userData = [:] }
//        let currentMult = CGFloat((enemy.userData?["speedMultiplier"] as? NSNumber)?.doubleValue ?? 1.0)
//        let newMult = min(currentMult + increment, 1.6)
//        enemy.userData?["speedMultiplier"] = NSNumber(value: Double(newMult))
//    }
    
    // MARK: - Game Over Logic
    func gameOver() {
        gameState = .gameOver
        removeAllChildren()
        removeAllActions()
        lastUpdateTime = 0
    }
}

