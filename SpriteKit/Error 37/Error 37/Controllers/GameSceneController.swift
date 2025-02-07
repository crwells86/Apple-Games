import SpriteKit

@Observable class GameSceneController: SKScene, SKPhysicsContactDelegate {
    //var gameState: GameState = .mainMenu
    var isMultiplayer = false
    var enemiesDefeated = 0
    var coinsCollected = 0
    var score = 0
    
    var players = [SKSpriteNode]()
    let spriteSize = CGSize(width: 55, height: 55)
    
    var onGameOver: (() -> Void)?
    
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
        enemiesDefeated = 0
        coinsCollected = 0
        score = 0
        
//        gameState = .playing
        
        setupPlayers()
        setupPlatform()
        setupPlatform2()
    }
    
    // MARK: - Player Initialization
    func setPlayerCount(to count: Int) {
        players.removeAll()
        for index in 0..<count {
            let player = SKSpriteNode(texture: SKTexture(imageNamed: "playerIdle"), size: spriteSize)
            let xOffset = CGFloat(index + 1) * (spriteSize.width * 1.5)
            player.position = CGPoint(x: xOffset, y: spriteSize.height * 2)
            
            let label = SKLabelNode(text: "P\(index + 1)")
            label.fontColor = .white
            label.fontSize = 14
            label.position = CGPoint(x: 0, y: spriteSize.height / 2 + 10)
            player.addChild(label)
            
            setupPhysics(for: player, type: .player)
            addChild(player)
            players.append(player)
        }
    }
    
    func setupPlayers() {
        if isMultiplayer {
            for index in players.indices {
                let player = SKSpriteNode(texture: SKTexture(imageNamed: "playerIdle"), size: spriteSize)
                let xOffset = CGFloat(index + 1) * (spriteSize.width * 1.5)
                player.position = CGPoint(x: xOffset, y: spriteSize.height * 2)
                
                setupPhysics(for: player, type: .player)
                addChild(player)
                players.append(player)
            }
        }
        
        if !isMultiplayer {
            let player = SKSpriteNode(texture: SKTexture(imageNamed: "playerIdle"), size: spriteSize)
            player.position = CGPoint(x: spriteSize.width * 1.5, y: spriteSize.height * 2)
            
            setupPhysics(for: player, type: .player)
            addChild(player)
            players.append(player)
        }
    }
    
    // MARK: - Platform Initialization
    func setupPlatform() {
        var platformXPosition: CGFloat = 0
        
        for _ in 0..<50 {
            let platform = SKSpriteNode(color: .gray, size: spriteSize)
            platform.position.y = spriteSize.height + 12
            platform.position.x = platformXPosition
            
            platformXPosition += spriteSize.width
            setupPhysics(for: platform, type: .platform)
            
            addChild(platform)
        }
    }
    
    func setupPlatform2() {
        var platformXPosition: CGFloat = 420
        
        for _ in 0..<5 {
            let platform = SKSpriteNode(texture: SKTexture(imageNamed: "platform"), size: spriteSize)
            platform.position.y = spriteSize.height * 4
            platform.position.x = platformXPosition
            
            platformXPosition += spriteSize.width
            setupPhysics(for: platform, type: .platform)
            
            addChild(platform)
        }
    }
    
    // MARK: - Player Movement and Actions
    func playerJump(for playerIndex: Int) {
        guard playerIndex < players.count else { return }
        
        let player = players[playerIndex]
        
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 120))
    }
    
    func playerMove(for playerIndex: Int, xValue: Float, yValue: Float) {
        guard playerIndex < players.count else { return }
        let player = players[playerIndex]
        let movementSpeed: CGFloat = 5
        
        let newX = player.position.x + CGFloat(xValue) * movementSpeed
        let newY = player.position.y + CGFloat(yValue) * movementSpeed
        
        player.position = CGPoint(x: newX, y: newY)
        
        if xValue > 0 {
            // Facing right
            player.xScale = 1
        } else if xValue < 0 {
            // Facing left (flipped)
            player.xScale = -1
        }
        
        // Start or stop walking animation based on movement
        if abs(xValue) > 0.1 || abs(yValue) > 0.1 {
            startWalkingAnimation(for: player)
        } else {
            stopWalkingAnimation(for: player)
        }
    }
    
    func startWalkingAnimation(for player: SKSpriteNode) {
        if player.action(forKey: "walking") == nil {
            let walkTextures = [
                SKTexture(imageNamed: "playerWalk001"),
                SKTexture(imageNamed: "playerWalk002")
            ]
            let walkAnimation = SKAction.animate(with: walkTextures, timePerFrame: 0.1)
            let repeatAnimation = SKAction.repeatForever(walkAnimation)
            
            player.run(repeatAnimation, withKey: "walking")
        }
    }
    
    func stopWalkingAnimation(for player: SKSpriteNode) {
        player.removeAction(forKey: "walking")
        player.texture = SKTexture(imageNamed: "playerIdle")
    }
    
    // MARK: - Physics Setup
    func setupPhysics(for node: SKSpriteNode, type: CollisionTypes) {
        switch type {
        case .player:
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
            node.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.collectible.rawValue | CollisionTypes.enemy.rawValue | CollisionTypes.platform.rawValue
            node.physicsBody?.collisionBitMask = CollisionTypes.platform.rawValue
            node.physicsBody?.affectedByGravity = true
            node.physicsBody?.allowsRotation = false
            node.physicsBody?.restitution = 0
        case .platform:
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
            node.physicsBody?.categoryBitMask = CollisionTypes.platform.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue
            node.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.isDynamic = false
        default:
            break
        }
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        for player in players {
            if player.position.x > size.width {
                player.position.x = 0
            } else if player.position.x < 0 {
                player.position.x = size.width
            }
        }
    }
    
    // MARK: - Collision Detection
    func didBegin(_ contact: SKPhysicsContact) {
        handleContact(contact)
    }
    
    func handleContact(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.collectible.rawValue) {
            if let coin = contact.bodyA.categoryBitMask == CollisionTypes.collectible.rawValue ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
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
//        gameState = .gameOver
        removeAllChildren()
        onGameOver?()
    }
    
    func pauseGame() {
//        if gameState == .playing {
//            gameState = .paused
//        } else {
//            gameState = .playing
//        }
    }
}
