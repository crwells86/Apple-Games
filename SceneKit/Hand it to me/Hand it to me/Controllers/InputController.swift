import SwiftUI
import SceneKit
import GameController

class InputController {
    var camera: SCNNode
    var scene: GameSceneController
    
    private var movementKeys: Set<GCKeyCode> = []
    private var updateTimer: Timer?
    
#if os(iOS)
    var virtualController: GCVirtualController?
#endif
    
    init(camera: SCNNode, scene: SCNScene) {
        self.camera = camera
        self.scene = scene as! GameSceneController
        setupGameController()
        setupMouseInput()
        startMovementUpdateLoop()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.setupKeyboardInput()
        }
    }
    
    deinit {
        cleanup()
    }
    
    func cleanup() {
        NotificationCenter.default.removeObserver(self, name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .GCControllerDidDisconnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .GCMouseDidConnect, object: nil)
        updateTimer?.invalidate()
    }
    
    func setupGameController() {
#if os(iOS)
        let virtualConfiguration = GCVirtualController.Configuration()
        virtualConfiguration.elements = [GCInputLeftThumbstick, GCInputRightThumbstick, GCInputRightShoulder]
        virtualController = GCVirtualController(configuration: virtualConfiguration)
        virtualController?.connect()
#endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleControllerDidConnect(_:)), name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleControllerDidDisconnect(_:)), name: .GCControllerDidDisconnect, object: nil)
        
        // Check for connected controllers
        let controllers = GCController.controllers()
        if controllers.isEmpty {
            print("No controllers detected initially")
        } else {
            for controller in controllers {
                print("Found connected controller: \(controller.vendorName ?? "Unknown")")
                setupInputHandlers(for: controller)
            }
        }
    }
    
    func setupMouseInput() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleMouseDidConnect(_:)), name: .GCMouseDidConnect, object: nil)
        
        if let mouse = GCMouse.current {
            setupMouseHandlers(mouse: mouse)
        }
    }
    
    @objc private func handleMouseDidConnect(_ notification: Notification) {
        guard let mouse = notification.object as? GCMouse else { return }
        
        setupMouseHandlers(mouse: mouse)
    }
    
    private func setupMouseHandlers(mouse: GCMouse) {
        mouse.mouseInput?.mouseMovedHandler = { [weak self] _, deltaX, deltaY in
            guard let self = self else { return }
            self.handleMouseMovement(deltaX: deltaX, deltaY: deltaY)
        }
    }
    
    private func handleMouseMovement(deltaX: Float, deltaY: Float) {
#if os(macOS)
        let sensitivity: Float = 0.005
        camera.eulerAngles.y -= CGFloat(deltaX * sensitivity)
        camera.eulerAngles.x = max(min(camera.eulerAngles.x - CGFloat(deltaY * sensitivity), .pi / 4), -.pi / 4)
#endif
    }
    
    @objc private func handleControllerDidConnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        print("Controller connected: \(controller.vendorName ?? "Unknown")")
        setupInputHandlers(for: controller)
    }
    
    @objc private func handleControllerDidDisconnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        print("Controller disconnected: \(controller.vendorName ?? "Unknown")")
    }
    
    private func setupInputHandlers(for controller: GCController) {
        if let gamepad = controller.extendedGamepad {
            gamepad.rightShoulder.valueChangedHandler = { [weak self] _, _, pressed in
                guard let self = self else { return }
                if pressed { self.handleButtonAPress() }
            }
            
            gamepad.leftShoulder.valueChangedHandler = { [weak self] _, _, pressed in
                guard let self = self else { return }
                if pressed { self.handleLeftShoulderPress() }
            }
            
            setupThumbstickHandlers(gamepad)
        }
    }
    
    private func setupThumbstickHandlers(_ gamepad: GCExtendedGamepad) {
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, x, y in
            guard let self = self else { return }
            self.handleMovementInput(delta: vector_float2(x, y))
        }
        
        gamepad.rightThumbstick.valueChangedHandler = { [weak self] _, x, y in
            guard let self = self else { return }
            self.handleRotationInput(delta: vector_float2(x, y))
        }
    }
    
    private func setupKeyboardInput() {
        DispatchQueue.main.async {
            if let keyboard = GCKeyboard.coalesced?.keyboardInput {
                keyboard.keyChangedHandler = { [weak self] (_, key, keyCode, pressed) in
                    guard let self = self else { return }
                    if pressed {
                        self.movementKeys.insert(keyCode)
                        
                        if keyCode == .spacebar {
                            self.handleButtonAPress()
                        }
                    } else {
                        self.movementKeys.remove(keyCode)
                    }
                }
            } else {
                print("Keyboard input is not available")
            }
        }
    }
    
    private func startMovementUpdateLoop() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(updateKeyboardMovement), userInfo: nil, repeats: true)
    }
    
    @objc private func updateKeyboardMovement() {
        var delta = vector_float2(0, 0)
        
        if movementKeys.contains(.keyW) {
            delta.y += 1
        }
        if movementKeys.contains(.keyS) {
            delta.y -= 1
        }
        if movementKeys.contains(.keyA) {
            delta.x -= 1
        }
        if movementKeys.contains(.keyD) {
            delta.x += 1
        }
        
        if delta != .zero {
            delta = simd_normalize(delta)
            self.handleMovementInput(delta: delta)
        }
    }
    
    private func handleMovementInput(delta: vector_float2) {
        let moveSpeed: Float = 0.04
        let yaw = camera.eulerAngles.y
        
        let forwardVectorX = Float(-sin(yaw))
        let forwardVectorZ = Float(-cos(yaw))
        let rightVectorX = Float(cos(yaw))
        let rightVectorZ = Float(-sin(yaw))
        
        let deltaX = delta.x * rightVectorX + delta.y * forwardVectorX
        let deltaZ = delta.x * rightVectorZ + delta.y * forwardVectorZ
        
        let newX = Float(camera.position.x) + deltaX * moveSpeed
        let newZ = Float(camera.position.z) + deltaZ * moveSpeed
        
#if os(macOS)
        camera.position = SCNVector3(CGFloat(newX), camera.position.y, CGFloat(newZ))
#elseif os(iOS) || os(tvOS)
        camera.position = SCNVector3(newX, camera.position.y, newZ)
#endif
    }
    
    private func handleRotationInput(delta: vector_float2) {
        let rotationSpeed: Float = 0.02
#if os(macOS)
        camera.eulerAngles.y -= CGFloat(delta.x * rotationSpeed)
        camera.eulerAngles.x = max(min(camera.eulerAngles.x + CGFloat(delta.y * rotationSpeed), .pi / 4), -.pi / 4)
#elseif os(iOS) || os(tvOS)
        camera.eulerAngles.y -= delta.x * rotationSpeed
        camera.eulerAngles.x = max(min(camera.eulerAngles.x + delta.y * rotationSpeed, .pi / 4), -.pi / 4)
#endif
    }
    
    private func handleButtonAPress() {
        isNoteInCenterOfCameraView()
    }
    
    func handleLeftShoulderPress() {
        // ?
    }
    
    private func isNoteInCenterOfCameraView() {
        let cameraTransform = camera.presentation.worldTransform
        let forwardDirection = SCNVector3(-cameraTransform.m31, -cameraTransform.m32, -cameraTransform.m33)
        var closestNote: SCNNode? = nil
        
#if os(macOS)
        let detectionDistance: CGFloat = 0.87
        var closestDistance: CGFloat = detectionDistance
#else
        let detectionDistance: Float = 0.87
        var closestDistance: Float = detectionDistance
#endif
        
        // Check all nodes to find the closest "note"
        for node in scene.rootNode.childNodes where node.name == "note" {
            let toNote = SCNVector3(node.position.x - camera.position.x,
                                    node.position.y - camera.position.y,
                                    node.position.z - camera.position.z)
            
            let toNoteNormalized = normalizeVector(toNote)
            let forwardDirectionNormalized = normalizeVector(forwardDirection)
            
            let dotProduct = toNoteNormalized.x * forwardDirectionNormalized.x +
            toNoteNormalized.y * forwardDirectionNormalized.y +
            toNoteNormalized.z * forwardDirectionNormalized.z
            
            let distanceToNote = lengthOfVector(toNote)
            if dotProduct > 0.886 && distanceToNote < closestDistance {
                closestNote = node
                closestDistance = distanceToNote
            }
        }
        
        // If a note is close and centered, show it
        if let _ = closestNote {
            scene.isNoteShowing.toggle()
        } else {
            // Crouch or uncrouch the player
            //            toggleCrouch()
        }
    }
    
    //    private func crouchPlayer() {
    //        let crouchAction = SCNAction.move(by: SCNVector3(0, -0.4, 0), duration: 0.3)
    //        crouchAction.timingMode = .easeInEaseOut
    //        camera.runAction(crouchAction)
    //    }
    //
    //    private func uncrouchPlayer() {
    //        let uncrouchAction = SCNAction.move(by: SCNVector3(0, 0.4, 0), duration: 0.3)
    //        uncrouchAction.timingMode = .easeInEaseOut
    //        camera.runAction(uncrouchAction)
    //    }
    //
    //    private func toggleCrouch() {
    //        // Decide whether to crouch or uncrouch based on current state
    //        if !scene.isPlayerCrouching {
    //            crouchPlayer()
    //            scene.isPlayerCrouching = true
    //        } else {
    //            uncrouchPlayer()
    //            scene.isPlayerCrouching = false
    //        }
    //    }
    
#if os(macOS)
    typealias Scalar = CGFloat
#else
    typealias Scalar = Float
#endif
    
    func normalizeVector(_ vector: SCNVector3) -> SCNVector3 {
        let length = lengthOfVector(vector)
        guard length > 0 else { return SCNVector3Zero }
        return SCNVector3(
            Scalar(vector.x) / length,
            Scalar(vector.y) / length,
            Scalar(vector.z) / length
        )
    }
    
    func lengthOfVector(_ vector: SCNVector3) -> Scalar {
        return Scalar(sqrt(
            Scalar(vector.x) * Scalar(vector.x) +
            Scalar(vector.y) * Scalar(vector.y) +
            Scalar(vector.z) * Scalar(vector.z)
        ))
    }
    
    func colorForPlatform(_ color: Color) -> Any {
#if os(iOS) || os(tvOS) || os(visionOS)
        return UIColor(color)
#elseif os(macOS)
        return NSColor(color)
#endif
    }
}
