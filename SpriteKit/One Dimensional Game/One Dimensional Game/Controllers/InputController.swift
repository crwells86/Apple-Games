import GameController

class InputController {
    private var movementKeys: Set<GCKeyCode> = []
    private var updateTimer: Timer?
    weak var gameSceneController: GameSceneController?
    
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
        }
        
        if let microGamepad = controller.microGamepad {
            microGamepad.buttonX.valueChangedHandler = { [weak self] _, _, pressed in
                guard let self = self else { return }
                if pressed { self.handleButtonAPress() }
            }
        }
    }
    
    private func setupKeyboardInput() {
        DispatchQueue.main.async {
            if let keyboard = GCKeyboard.coalesced?.keyboardInput {
                keyboard.keyChangedHandler = { [weak self] (_, key, keyCode, pressed) in
                    guard let self = self else { return }
                    if pressed {
                        if keyCode == .spacebar {
                            self.handleButtonAPress()
                        }
                    }
                }
            } else {
                print("Keyboard input is not available")
            }
        }
    }
    
    func handleButtonAPress() {
        gameSceneController?.changePlayerDirection()
    }
}
