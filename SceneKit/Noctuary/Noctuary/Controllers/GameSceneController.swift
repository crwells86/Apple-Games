import SwiftUI
import SceneKit
import AVFAudio

@Observable class GameSceneController: SCNScene, SCNSceneRendererDelegate {
    var cameraController: CameraController?
    var inputController: InputController?
    var levelController: LevelController?
    
    var hasGameStarted = false
    var isGameOver = false
    
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
        checkCollision(objectName: "wall", interactionThreshold: 1) { collidedNode in
            // Assume the cameraNode is your camera's node
            guard let cameraNode = cameraController?.cameraNode else { return }
            
            // Get the direction vector between the camera and the wall
            let direction = cameraNode.position - collidedNode.position
            
            // Normalize the direction vector to get the push-away direction
            let normalizedDirection = direction.normalized()
            
            // Move the camera away from the wall by a certain offset
#if os(iOS) || os(tvOS) || os(visionOS)
            let safeDistance: Float = 1.0
#elseif os(macOS)
            let safeDistance: CGFloat = 1.0
#endif
            
            let newPosition = collidedNode.position + normalizedDirection * safeDistance
            
            // Update the camera's position
            cameraNode.position = newPosition
        }
        
        //        checkCollision(objectName: "note  ??", interactionThreshold: 4.4) { _ in
        //            moveEnemies()
        //        }
        
        checkCollision(objectName: "door", interactionThreshold: 1) { _ in
            loadLevel()
        }
    }
    
#if os(iOS) || os(tvOS) || os(visionOS)
    func checkCollision(objectName: String, interactionThreshold: Float, onCollision: (SCNNode) -> Void) {
        // Safely unwrap cameraController to avoid EXC_BAD_ACCESS
        guard let cameraController = cameraController else {
            print("Error: cameraController is nil.")
            return
        }
        
        // Ensure cameraNode is valid
        let cameraNode = cameraController.cameraNode
        
        // Filter out child nodes with the specific object name
        let nodesToCheck = rootNode.childNodes.filter { $0.name == objectName }
        
        for childNode in nodesToCheck {
            // Calculate the direction from camera to childNode
            var direction = cameraNode.position - childNode.position
            direction.y = 0 // Keep the movement horizontal
            
            // Check if the object is close enough to trigger interaction
            if cameraNode.position.distance(to: childNode.position) < interactionThreshold {
                // Safely pass childNode to the onCollision closure
                onCollision(childNode)
            }
        }
    }
#elseif os(macOS)
    func checkCollision(objectName: String, interactionThreshold: CGFloat, onCollision: (SCNNode) -> Void) {
        // Safely unwrap cameraController to avoid EXC_BAD_ACCESS
        guard let cameraController = cameraController else {
            print("Error: cameraController is nil.")
            return
        }
        
        // Ensure cameraNode is valid
        let cameraNode = cameraController.cameraNode
        
        // Filter out child nodes with the specific object name
        let nodesToCheck = rootNode.childNodes.filter { $0.name == objectName }
        
        for childNode in nodesToCheck {
            // Calculate the direction from camera to childNode
            var direction = cameraNode.position - childNode.position
            direction.y = 0 // Keep the movement horizontal
            
            // Check if the object is close enough to trigger interaction
            if cameraNode.position.distance(to: childNode.position) < interactionThreshold {
                // Safely pass childNode to the onCollision closure
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
