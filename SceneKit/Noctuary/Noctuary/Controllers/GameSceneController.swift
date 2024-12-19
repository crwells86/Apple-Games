import SwiftUI
import SceneKit
import AVFAudio

@Observable class GameSceneController: SCNScene, SCNSceneRendererDelegate {
    var cameraController: CameraController?
    var inputController: InputController?
    var levelController: LevelController?
    
    var hasGameStarted = false
    var isGameOver = false
    
    var isNoteShowing = false
    var isPlayerCrouching = false
    
    let floor = SCNFloor()
    var floorNode = SCNNode()
    
    var deathSoundPlayer: AVAudioPlayer?
    var backgroundMusicPlayer: AVAudioPlayer?
    
    var gridMap: [[Int]] = []
    var lastLoadedLevelIndex: Int?
    
    override init() {
        super.init()
        background.contents = colorForPlatform(Color(.black))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupControllers() {
        cameraController = CameraController(scene: self)
        levelController = LevelController(scene: self, level: levels[0])
        inputController = InputController(camera: cameraController!.cameraNode, scene: self)
    }
    
    func startGame() {
        isGameOver = false
        
        setupControllers()
        
        levelController!.startProceduralLevelGeneration()
        loadLevel()
        
        levelController?.createFloorExcludingWalls(gridSize: 100)
        
        loadSounds()
        backgroundMusicPlayer?.volume = 0.087
        backgroundMusicPlayer?.play()
    }
    
    func loadLevel() {
        guard !levels.isEmpty else { return }
        
        if levels.count > 2 {
            levels.removeFirst()
            levelController?.startProceduralLevelGeneration()
        }
        
        // Pick a random level index, ensuring it is not the same as the last loaded level
        var randomIndex: Int
        repeat {
            randomIndex = Int.random(in: 0..<levels.count)
        } while randomIndex == lastLoadedLevelIndex
        
        // Clear the current level if necessary
        levelController?.clearLevel()
        
        // Load the random level
        let selectedLevel = levels[randomIndex]
        levelController?.addLevel(from: selectedLevel, currentLevel: randomIndex)
        
        // Update the grid map with the level data
        gridMap = selectedLevel
        
        // Update the last loaded level index
        lastLoadedLevelIndex = randomIndex
        
        levelController!.startProceduralLevelGeneration()
    }
    
    func loadSounds() {
        deathSoundPlayer = createAudioPlayer(forResource: "death", withExtension: "wav")
        backgroundMusicPlayer = createAudioPlayer(forResource: "backgroundMusic", withExtension: "wav")
        backgroundMusicPlayer?.numberOfLoops = -1
    }
    
    func createAudioPlayer(forResource resource: String, withExtension ext: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext) else { return nil }
        
        do {
            return try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Failed to load \(resource).\(ext): \(error)")
            return nil
        }
    }
    
    //MARK: - Collision Logic
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard !isGameOver else { return }
        
        guard let cameraNode = cameraController?.cameraNode else { return }
        
        checkCollision(objectName: "wall", interactionThreshold: 1) { collidedNode in
            
            // Get direction and normalize
            let direction = cameraNode.position - collidedNode.position
            let normalizedDirection = direction.normalized()
            
            // Adjust camera position to avoid collision
#if os(iOS) || os(tvOS) || os(visionOS)
            let safeDistance: Float = 1.0
#elseif os(macOS)
            let safeDistance: CGFloat = 1.0
#endif
            let newPosition = collidedNode.position + normalizedDirection * safeDistance
            
            // Ensure camera can still go under the object
            if cameraNode.position.y < collidedNode.position.y - 0.2 {
                return
            }
            
            cameraNode.position = newPosition
        }
        
        checkCollision(objectName: "door", interactionThreshold: 1) { _ in
            loadLevel()
        }
    }
    
#if os(iOS) || os(tvOS) || os(visionOS)
    func checkCollision(objectName: String, interactionThreshold: Float, onCollision: (SCNNode) -> Void) {
        guard let cameraController = cameraController else {
            print("Error: cameraController is nil.")
            return
        }
        
        let cameraNode = cameraController.cameraNode
        
        // Get nodes to check collisions with
        let nodesToCheck = rootNode.childNodes.filter { $0.name == objectName }
        
        for childNode in nodesToCheck {
            // Calculate the direction from the camera to the childNode
            let direction = cameraNode.position - childNode.position
            
            // Calculate distance for collision
            let horizontalDistance = direction.horizontalDistance()
            let verticalOffset = abs(cameraNode.position.y - childNode.position.y)
            
            // Only trigger collision if within the threshold horizontally
            // and the camera is not below the object's height
            if horizontalDistance < interactionThreshold && verticalOffset < 1.0 { // Adjust vertical offset as needed
                onCollision(childNode)
            }
        }
    }
#elseif os(macOS)
    func checkCollision(objectName: String, interactionThreshold: CGFloat, onCollision: (SCNNode) -> Void) {
        guard let cameraController = cameraController else {
            print("Error: cameraController is nil.")
            return
        }
        
        let cameraNode = cameraController.cameraNode
        
        // Get nodes to check collisions with
        let nodesToCheck = rootNode.childNodes.filter { $0.name == objectName }
        
        for childNode in nodesToCheck {
            // Calculate the direction from the camera to the childNode
            let direction = cameraNode.position - childNode.position
            
            // Calculate distance for collision
            let horizontalDistance = direction.horizontalDistance()
            let verticalOffset = abs(cameraNode.position.y - childNode.position.y)
            
            // Only trigger collision if within the threshold horizontally
            // and the camera is not below the object's height
            if horizontalDistance < interactionThreshold && verticalOffset < 1.0 {
                onCollision(childNode)
            }
        }
    }
#endif
    
    func colorForPlatform(_ color: Color) -> Any {
#if os(iOS) || os(tvOS) || os(visionOS)
        return UIColor(color)
#elseif os(macOS)
        return NSColor(color)
#endif
    }
}

struct PhysicsCategory {
    static let player: Int = 1
    static let enemy: Int = 2
    static let floor: Int = 4
    static let obstacle: Int = 8
}
