import GameController

class InputController {
    private var controllers = [GCController]()
    private var updateTimer: Timer?
    weak var gameSceneController: GameSceneController?
    
#if os(iOS)
    var virtualController: GCVirtualController?
#endif
    
    init(gameSceneController: GameSceneController) {
        self.gameSceneController = gameSceneController
        setupGameController()
        
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
        updateTimer?.invalidate()
    }
    
    func setupGameController() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleControllerDidConnect(_:)), name: .GCControllerDidConnect, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleControllerDidDisconnect(_:)), name: .GCControllerDidDisconnect, object: nil)
        
        // Check for already connected controllers
        GCController.controllers().forEach { controller in
            handleNewController(controller)
        }
        
//#if os(iOS)
//        let virtualConfiguration = GCVirtualController.Configuration()
//        virtualConfiguration.elements = [GCInputLeftThumbstick, GCInputButtonA]//GCInputRightThumbstick, GCInputRightShoulder]
//        virtualController = GCVirtualController(configuration: virtualConfiguration)
//        virtualController?.connect()
//#endif
        
#if os(iOS)
if GCController.controllers().isEmpty {
    let virtualConfiguration = GCVirtualController.Configuration()
    virtualConfiguration.elements = [GCInputLeftThumbstick, GCInputButtonA]
    virtualController = GCVirtualController(configuration: virtualConfiguration)
    virtualController?.connect()
}
#endif

    }
    
    @objc private func handleControllerDidConnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        handleNewController(controller)
    }
    
    @objc private func handleControllerDidDisconnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        controllers.removeAll { $0 == controller }
        print("Controller disconnected: \(controller.vendorName ?? "Unknown")")
    }
    
    private func handleNewController(_ controller: GCController) {
        if controllers.count < 4 {
            controllers.append(controller)
            setupInputHandlers(for: controller, playerIndex: controllers.count - 1)
            print("Controller connected: \(controller.vendorName ?? "Unknown")")
        } else {
            print("Maximum controller limit? I don't know but I only have 4 to test so I will be ignoring additional controllers.")
        }
    }
    
    private func setupInputHandlers(for controller: GCController, playerIndex: Int) {
        if let gamepad = controller.extendedGamepad {
            gamepad.buttonA.valueChangedHandler = { [weak self] _, _, pressed in
                guard let self = self else { return }
                if pressed { self.handleButtonPress(for: playerIndex, action: "jump") }
            }
            
            // Pause action (for example, using buttonB)
            gamepad.buttonB.valueChangedHandler = { [weak self] _, _, pressed in
                guard let self = self else { return }
                if pressed { self.handleButtonPress(for: playerIndex, action: "pause") }
            }
            
            gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
                guard let self = self else { return }
                self.handleMovement(for: playerIndex, xValue: xValue, yValue: yValue)
            }
        }
        
        if let microGamepad = controller.microGamepad {
            microGamepad.buttonA.valueChangedHandler = { [weak self] _, _, pressed in
                guard let self = self else { return }
                if pressed { self.handleButtonPress(for: playerIndex, action: "jump") }
            }
        }
    }
    
    private func setupKeyboardInput() {
        DispatchQueue.main.async {
            if let keyboard = GCKeyboard.coalesced?.keyboardInput {
                keyboard.keyChangedHandler = { [weak self] (_, key, keyCode, pressed) in
                    guard let self = self else { return }
                    
                    let movementSpeed: Float = pressed ? 1.0 : 0.0
                    
                    switch keyCode {
                    case .leftArrow:
                        self.handleMovement(for: 0, xValue: -movementSpeed, yValue: 0)
                    case .rightArrow:
                        self.handleMovement(for: 0, xValue: movementSpeed, yValue: 0)
                    case .spacebar:
                        if pressed { self.handleButtonPress(for: 0, action: "jump") }
                    default:
                        break
                    }
                }
            } else {
                print("Keyboard input is not available")
            }
        }
    }
    
//    func handleButtonPress(for playerIndex: Int, action: String) {
//        print("Player \(playerIndex + 1) performed action: \(action)")
//        if action == "jump" {
//            gameSceneController?.playerJump(for: playerIndex)
//        }
//    }
    
    func handleButtonPress(for playerIndex: Int, action: String) {
        print("Player \(playerIndex + 1) performed action: \(action)")
        switch action {
        case "jump":
            gameSceneController?.playerJump(for: playerIndex)
        case "pause":
            gameSceneController?.pauseGame()  // You might add this method to change state
        default:
            break
        }
    }

    
    func handleMovement(for playerIndex: Int, xValue: Float, yValue: Float) {
        print("Player \(playerIndex + 1) moved to x: \(xValue), y: \(yValue)")
        gameSceneController?.playerMove(for: playerIndex, xValue: xValue, yValue: yValue)
    }
}
