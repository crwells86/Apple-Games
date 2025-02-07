import GameKit

@Observable class GameCenterController: NSObject {
    static let shared = GameCenterController()
    let leaderboardIDs = ["Error37HighScore", "Error37DailyHighScore"]
    var authenticated = false
    
    private override init() {
        super.init()
        authenticatePlayer()
    }
    
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController = viewController {
#if os(macOS)
                if let window = NSApplication.shared.windows.first {
                    window.contentViewController?.presentAsModalWindow(viewController)
                }
#else
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    scene.windows.first?.rootViewController?.present(viewController, animated: true, completion: nil)
                }
#endif
            } else if GKLocalPlayer.local.isAuthenticated {
                self.authenticated = true
            } else {
                print("Game Center authentication failed with error: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    //MARK: - High Score
    func submitScoreToGameCenter(score: Int) async {
        guard self.authenticated else {
            return
        }
        
        let gkScore = GKLeaderboardScore()
        gkScore.value = score
        
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: leaderboardIDs
        ) { error in
            if let error = error {
                print("Failed to report high score to Game Center: \(error.localizedDescription)")
            } else {
                print("High score reported successfully!")
            }
        }
    }
    
    //MARK: - Achievement
    // ?
}
