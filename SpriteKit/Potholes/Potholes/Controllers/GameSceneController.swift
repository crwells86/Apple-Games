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
    var car: SKSpriteNode?
    let roadMargin: CGFloat = 50.0
    
    var totalDistanceDriven: Double = 0.0
    var lastUpdateTime: TimeInterval = 0
    
    var backgroundMusicPlayer: AVAudioPlayer?
    var collisionSound: AVAudioPlayer?
    
    override func didMove(to view: SKView) {
        backgroundColor = .lightGray
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        if gameState == .playing {
            startSpawningPotholes()
            addBackgroundImage()
        }
    }
    
    func addBackgroundImage() {
        let background = SKSpriteNode(imageNamed: "bg")
        background.zPosition = -10
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let scaleX = size.width / background.size.width
        let scaleY = size.height / background.size.height
        let scale = min(scaleX, scaleY)
        background.setScale(scale)
        
        addChild(background)
    }
    
    func restartGame() {
        score = 0
        removeAllChildren()
        
        playBackgroundMusic(filename: "backgroundMusic.wav")
        backgroundMusicPlayer?.volume = 0.09
        
        let carTexture = SKTexture(imageNamed: "car")
        let carSize = CGSize(width: 154, height: 274)
        let newCar = SKSpriteNode(texture: carTexture)
        
        newCar.size = carSize
        
        newCar.position = CGPoint(x: size.width / 2, y: carSize.height * 1.5)
        newCar.physicsBody = SKPhysicsBody(texture: carTexture, size: carSize)
        newCar.physicsBody?.isDynamic = true
        newCar.physicsBody?.affectedByGravity = false
        newCar.physicsBody?.categoryBitMask = PhysicsCategory.car
        newCar.physicsBody?.contactTestBitMask = PhysicsCategory.pothole
        newCar.physicsBody?.collisionBitMask = 0
        
        addChild(newCar)
        car = newCar
        
        setupScoringZone()
        
        removeAllActions()
        startSpawningPotholes()
    }
    
    // MARK: - Pothole Spawning
    func startSpawningPotholes() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnPothole()
        }
        let delay = SKAction.wait(forDuration: 1.5, withRange: 1.0)
        let spawnSequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(spawnSequence), withKey: "spawningPotholes")
    }
    
    func spawnPothole() {
        guard gameState == .playing else { return }
        
        let potholeSize = CGSize(width: 60, height: 60)
        let topRoadWidth: CGFloat = size.width * 0.4
        let startX = size.width / 2 + CGFloat.random(in: -topRoadWidth / 2 ... topRoadWidth / 2)
        let startY = size.height + potholeSize.height
        
        let pothole = SKSpriteNode(texture: SKTexture(imageNamed: "pothole"), size: potholeSize)
        pothole.position = CGPoint(x: startX, y: startY)
        pothole.zPosition = -1
        pothole.name = "pothole"
        pothole.physicsBody = SKPhysicsBody(rectangleOf: potholeSize)
        pothole.physicsBody?.isDynamic = true
        pothole.physicsBody?.categoryBitMask = PhysicsCategory.pothole
        pothole.physicsBody?.contactTestBitMask = PhysicsCategory.car | PhysicsCategory.scoringZone
        pothole.physicsBody?.collisionBitMask = 0
        addChild(pothole)
        
        pothole.setScale(0.5)
        
        let moveDuration: TimeInterval = 4.0
        let moveDown = SKAction.moveTo(y: -potholeSize.height, duration: moveDuration)
        let scaleUp = SKAction.scale(to: 1.8, duration: moveDuration)
        let moveAndScale = SKAction.group([moveDown, scaleUp])
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAndScale, remove])
        
        pothole.run(sequence)
    }
    
    func setupScoringZone() {
        let scoringZone = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: 1))
        scoringZone.position = CGPoint(x: size.width / 2, y: car!.position.y - 60)
        scoringZone.name = "scoringZone"
        scoringZone.physicsBody = SKPhysicsBody(rectangleOf: scoringZone.size)
        scoringZone.physicsBody?.isDynamic = false
        scoringZone.physicsBody?.categoryBitMask = PhysicsCategory.scoringZone
        scoringZone.physicsBody?.contactTestBitMask = PhysicsCategory.pothole
        scoringZone.physicsBody?.collisionBitMask = 0
        
        addChild(scoringZone)
    }
    
    // MARK: - Collision Handling
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.car &&
            secondBody.categoryBitMask == PhysicsCategory.pothole {
            gameOver()
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.pothole && contact.bodyB.categoryBitMask == PhysicsCategory.scoringZone) ||
            (contact.bodyA.categoryBitMask == PhysicsCategory.scoringZone && contact.bodyB.categoryBitMask == PhysicsCategory.pothole) {
            
            let potholeNode: SKNode = (contact.bodyA.categoryBitMask == PhysicsCategory.pothole)
            ? contact.bodyA.node!
            : contact.bodyB.node!
            
            if potholeNode.userData == nil {
                potholeNode.userData = NSMutableDictionary()
            }
            
            if potholeNode.userData?["scored"] as? Bool != true {
                score += 1
                potholeNode.userData?["scored"] = true
            }
        }
    }
    
    func gameOver() {
        gameState = .gameOver
        
        backgroundMusicPlayer!.stop()
        playCollisionSound(filename: "collisionSound.wav")
        collisionSound?.volume = 0.09
        removeAllActions()
        
        for node in children {
            if node.name == "pothole" {
                node.removeAllActions()
            }
        }
    }
    
    // MARK: - Touch Handling for Car Movement
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState == .playing, let touch = touches.first, let car = car else { return }
        let location = touch.location(in: self)
        let newX = max(roadMargin, min(location.x, size.width - roadMargin))
        
        car.removeAction(forKey: "moveX")
        car.removeAction(forKey: "turn")
        
        let moveDuration: TimeInterval = 0.3
        
        let moveAction = SKAction.moveTo(x: newX, duration: moveDuration)
        moveAction.timingMode = .easeInEaseOut
        
        car.run(moveAction, withKey: "moveX")
        
        let deltaX = newX - car.position.x
        let maxTilt: CGFloat = .pi / 8
        let turnAngle = max(-maxTilt, min(maxTilt, deltaX / size.width * maxTilt))
        
        let rotateAction = SKAction.sequence([
            SKAction.rotate(toAngle: turnAngle, duration: moveDuration / 2, shortestUnitArc: true),
            SKAction.rotate(toAngle: 0, duration: moveDuration / 2, shortestUnitArc: true)
        ])
        rotateAction.timingMode = .easeInEaseOut
        car.run(rotateAction, withKey: "turn")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMoved(touches, with: event)
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
    
    func playCollisionSound(filename: String) {
        if let musicURL = Bundle.main.url(forResource: filename, withExtension: nil) {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.play()
            } catch {
                print("Could not play background music: \(error)")
            }
        }
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else { return }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        let distanceThisFrame = 95.33 * deltaTime
        totalDistanceDriven += distanceThisFrame
        
        checkForAchievements()
    }
    
    func checkForAchievements() {
        let milesDriven = totalDistanceDriven / 5280
        
        let mileAchievements = [1, 5, 10, 15, 25, 35, 45, 55]
        
        for mile in mileAchievements {
            if milesDriven >= Double(mile) {
                let achievementID = "Drive\(mile)Miles" // Ensure IDs match App Store Connect
                GameCenterController.shared.reportAchievement(identifier: achievementID, percentComplete: 100)
            }
        }
    }
}
