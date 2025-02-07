import SceneKit

struct CameraController {
    weak var scene: GameSceneController?
    var cameraNode: SCNNode
    
    init(scene: GameSceneController) {
        self.scene = scene
        cameraNode = SCNNode()
        setupCamera()
    }
    
    private func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 45
        cameraNode.camera?.zNear = 0.1
        
        scene?.rootNode.addChildNode(cameraNode)
    }
}
