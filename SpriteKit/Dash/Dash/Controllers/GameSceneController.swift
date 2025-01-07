import SpriteKit
import AVFoundation

@Observable class GameSceneController: SKScene, SKPhysicsContactDelegate {
    var gameState: GameState = .mainMenu
    
    var enemiesDefeated = 0
    var coinsCollected = 0
    var score = 0
    
    var player = SKSpriteNode()
    var cameraNode: SKCameraNode!
    
    var isJumping = false
    
    var isInvincible = false
    var invincibleTimer: Timer?
    
    let levelGenerator = LevelGenerator(rows: 8, columns: 128)
    var activeTiles: [SKSpriteNode] = []
    
    var backgroundMusicPlayer: AVAudioPlayer?
    let coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    let deathSound = SKAction.playSoundFileNamed("death.wav", waitForCompletion: false)
    let powerUpSound = SKAction.playSoundFileNamed("powerUp.wav", waitForCompletion: false)
    let enemyDefeatedSound = SKAction.playSoundFileNamed("enemyDefeated.wav", waitForCompletion: false)
    
    // MARK: - Game Setup
    override func didMove(to view: SKView) {
        size = getWindowSize()!
        backgroundColor = .black
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -15)
    }
    
    func getWindowSize() -> CGSize? {
#if os(iOS) || os(tvOS)
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
        isInvincible = false
        
        enemiesDefeated = 0
        coinsCollected = 0
        score = 0
        
        cameraNode = SKCameraNode()
        camera = cameraNode
        cameraNode.position.x = player.position.x + 64
        cameraNode.position.y = CGFloat(getWindowSize()!.height / 2)
        addChild(cameraNode)
        
        setupPlayer()
        
        levelGenerator.generateLevel(using: predefinedTilesets, numberOfSections: 8)
        renderLevel()
        
        playBackgroundMusic(filename: "backgroundMusic.wav")
        backgroundMusicPlayer?.volume = 0.16
    }
    
    func getJumpForDevice() -> Int {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 1800
        } else {
            return 172
        }
#elseif os(macOS)
        return 420
#elseif os(tvOS)
        return 420
#endif
    }
    
    func jump() {
        if !isJumping {
            isJumping = true
            let jumpImpulse = CGVector(dx: 0, dy: getJumpForDevice())
            player.physicsBody?.applyImpulse(jumpImpulse)
        }
    }
    
    // MARK: - Player Initialization
    func setupPlayer() {
        let scalingFactor = getWindowSize()!.width / 6
        let spriteSize = CGSize(width: scalingFactor, height: scalingFactor)
        
        player = SKSpriteNode(color: .clear, size: spriteSize)
        player.position = CGPoint(x: getWindowSize()!.width / 4, y: getWindowSize()!.height / 2)
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.coin.rawValue | CollisionTypes.enemy.rawValue | CollisionTypes.platform.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.platform.rawValue
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        
        let animationTextures = [
            SKTexture(image: .player01),
            SKTexture(image: .player02)
        ]
        
        let animationAction = SKAction.animate(with: animationTextures, timePerFrame: 0.3)
        let repeatAction = SKAction.repeatForever(animationAction)
        
        player.run(repeatAction)
    }
    
    // MARK: - Enemy Initialization
    func setupEnemy() -> SKSpriteNode {
        let scalingFactor = getWindowSize()!.width / 6
        let spriteSize = CGSize(width: scalingFactor, height: scalingFactor)
        let enemy = SKSpriteNode(color: .clear, size: spriteSize)
        
        enemy.position =  CGPoint(x: getWindowSize()!.width / 1.2, y: getWindowSize()!.height)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        enemy.physicsBody?.categoryBitMask = CollisionTypes.enemy.rawValue
        enemy.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue | CollisionTypes.platform.rawValue
        enemy.physicsBody?.collisionBitMask = CollisionTypes.platform.rawValue
        enemy.physicsBody?.affectedByGravity = true
        enemy.physicsBody?.allowsRotation = false
        
        let animationTextures = [
            SKTexture(image: .enemy01),
            SKTexture(image: .enemy02)
        ]
        
        let animationAction = SKAction.animate(with: animationTextures, timePerFrame: 0.3)
        let repeatAction = SKAction.repeatForever(animationAction)
        
        enemy.run(repeatAction)
        
        let walkActionOne = SKAction.move(by: CGVector(dx: spriteSize.width, dy: 0), duration: 1.5)
        let walkActionTwo = SKAction.move(by: CGVector(dx: -spriteSize.width, dy: 0), duration: 1.5)
        let repeatWalkAction = SKAction.repeatForever(SKAction.sequence([walkActionOne, walkActionTwo]))
        enemy.run(repeatWalkAction)
        
        return enemy
    }
    
    // MARK: - Level Logic
    func platformLeading() -> SKSpriteNode {
        let scalingFactor = getWindowSize()!.width / 6
        let spriteSize = CGSize(width: scalingFactor, height: scalingFactor)
        
        let texture = SKTexture(image: .platformLeading)
        
        return SKSpriteNode(texture: texture, size: spriteSize)
    }
    
    func platformCenter() -> SKSpriteNode {
        let scalingFactor = getWindowSize()!.width / 6
        let spriteSize = CGSize(width: scalingFactor, height: scalingFactor)
        
        let texture = SKTexture(image: .platformCenter)
        
        return SKSpriteNode(texture: texture, size: spriteSize)
    }
    
    func platformTrailing() -> SKSpriteNode {
        let scalingFactor = getWindowSize()!.width / 6
        let spriteSize = CGSize(width: scalingFactor, height: scalingFactor)
        
        let texture = SKTexture(image: .platformTrailing)
        
        return SKSpriteNode(texture: texture, size: spriteSize)
    }
    
    func coin() -> SKSpriteNode {
        let scalingFactor = getWindowSize()!.width / 6
        let spriteSize = CGSize(width: scalingFactor, height: scalingFactor)
        let coin = SKSpriteNode(color: .clear, size: spriteSize)
        
        let animationTextures = [
            SKTexture(image: .coin02),
            SKTexture(image: .coin03)
        ]
        
        let animationAction = SKAction.animate(with: animationTextures, timePerFrame: 0.3)
        let repeatAction = SKAction.repeatForever(animationAction)
        
        coin.run(repeatAction)
        
        return coin
    }
    
    func powerUp() -> SKSpriteNode {
        let scalingFactor = getWindowSize()!.width / 6
        let spriteSize = CGSize(width: scalingFactor, height: scalingFactor)
        let coin = SKSpriteNode(color: .clear, size: spriteSize)
        
        let animationTextures = [
            SKTexture(image: .powerUp01),
            SKTexture(image: .powerUp02),
            SKTexture(image: .powerUp03)
        ]
        
        let animationAction = SKAction.animate(with: animationTextures, timePerFrame: 0.3)
        let repeatAction = SKAction.repeatForever(animationAction)
        
        coin.run(repeatAction)
        
        return coin
    }
    
    func renderLevel() {
        let scalingFactor = getWindowSize()!.width / 6
        let spriteSize = CGSize(width: scalingFactor, height: scalingFactor)
        
        let level = levelGenerator.getLevel()
        let tileSize = spriteSize
        
        let screenHeight = getWindowSize()!.height
        var verticalOffset = -(screenHeight / 3)
        
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            verticalOffset = -(screenHeight / 18)
        } else {
            verticalOffset = -(screenHeight / 3)
        }
#elseif os(macOS)
        verticalOffset = -(screenHeight / 3)
#elseif os(tvOS)
        verticalOffset = -(screenHeight / 3)
#endif
        
        for (row, rowArray) in level.enumerated() {
            for (col, tile) in rowArray.enumerated() {
                guard let tileType = TileType(rawValue: tile) else { continue }
                
                let node: SKSpriteNode
                switch tileType {
                case .platformLeading:
                    node = platformLeading()
                case .platformCenter:
                    node = platformCenter()
                case .platformTrailing:
                    node = platformTrailing()
                case .coin:
                    node = coin()
                case .enemy:
                    node = setupEnemy()
                case .powerUp:
                    node = powerUp()
                case .empty:
                    continue
                }
                
                let x = CGFloat(col) * tileSize.width
                let y = screenHeight - (CGFloat(row + 1) * tileSize.height) + verticalOffset
                
                node.position = CGPoint(x: x, y: y)
                addChild(node)
                
                if tileType == .platformLeading {
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.platform.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue
                    node.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue
                    node.physicsBody?.affectedByGravity = false
                    node.physicsBody?.isDynamic = false
                } else if tileType == .platformCenter {
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.platform.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue
                    node.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue
                    node.physicsBody?.affectedByGravity = false
                    node.physicsBody?.isDynamic = false
                } else if tileType == .platformTrailing {
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.platform.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue
                    node.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue
                    node.physicsBody?.affectedByGravity = false
                    node.physicsBody?.isDynamic = false
                } else if tileType == .coin {
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.categoryBitMask = CollisionTypes.coin.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.affectedByGravity = false
                    node.physicsBody?.isDynamic = false
                } else if tileType == .powerUp {
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.categoryBitMask = CollisionTypes.powerUp.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.affectedByGravity = false
                    node.physicsBody?.isDynamic = false
                }
            }
        }
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        let moveAction = SKAction.move(by: CGVector(dx: 6, dy: 0), duration: 1)
        
        if gameState == .playing {
            player.run(moveAction)
        }
        
        cameraNode.position.x = player.position.x + 120
        
        if player.position.y < -self.size.height / 2 {
            if gameState == .playing {
                gameOver()
            }
        }
        
        let offScreenX = cameraNode.position.x - size.width
        activeTiles.removeAll { tile in
            if tile.position.x < offScreenX {
                tile.removeFromParent()
                return true
            }
            return false
        }
        
        if let lastTileX = activeTiles.last?.position.x, lastTileX < cameraNode.position.x + size.width {
            levelGenerator.addNewSection()
            renderLevel()
        }
    }
    
    // MARK: - Collision Detection
    func didBegin(_ contact: SKPhysicsContact) {
        handleContact(contact)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Reset jump state when the player lands on a platform
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.platform.rawValue) {
            isJumping = false
        }
    }
    
    func handleContact(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.coin.rawValue) {
            if let coin = contact.bodyA.categoryBitMask == CollisionTypes.coin.rawValue ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                coin.removeFromParent()
                score += 2
                coinsCollected += 1
                
                run(coinSound)
            }
        }
        
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.powerUp.rawValue) {
            if let powerUp = contact.bodyA.categoryBitMask == CollisionTypes.powerUp.rawValue ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                powerUp.removeFromParent()
                activatePowerUp(duration: 10)
            }
        }
        
        if contactMask == (CollisionTypes.player.rawValue | CollisionTypes.enemy.rawValue) {
            if isInvincible {
                if let enemy = contact.bodyA.categoryBitMask == CollisionTypes.enemy.rawValue ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                    enemy.removeFromParent()
                    score += 5
                    enemiesDefeated += 1
                    
                    run(enemyDefeatedSound)
                }
            } else {
                gameOver()
            }
        }
    }
    
    // MARK: - Power-Up Logic
    func activatePowerUp(duration: TimeInterval) {
        guard !isInvincible else { return }
        
        isInvincible = true
        
        let pulseOut = SKAction.fadeAlpha(to: 0.5, duration: 0.5)
        let pulseIn = SKAction.fadeAlpha(to: 0.04, duration: 0.5)
        let pulseSequence = SKAction.sequence([pulseOut, pulseIn])
        let pulseRepeat = SKAction.repeatForever(pulseSequence)
        
        player.run(pulseRepeat, withKey: "pulseAction")
        
        // play powerup sound
        
        // Set up a timer to end invincibility after the duration
        invincibleTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.endPowerUp()
        }
    }
    
    func endPowerUp() {
        isInvincible = false
        invincibleTimer?.invalidate()
        invincibleTimer = nil
        
        player.removeAction(forKey: "pulse")
        player.alpha = 1.0
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
    
    // MARK: - Game Over Logic
    func gameOver() {
        gameState = .gameOver
        backgroundMusicPlayer!.stop()
        run(deathSound)
        removeAllChildren()
    }
}
