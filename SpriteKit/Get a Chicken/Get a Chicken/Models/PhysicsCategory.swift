struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0         // The playable characters
    static let enemy: UInt32 = 1 << 1          // Regular foes and adversaries
    static let playerAttack: UInt32 = 1 << 2   // Attacks initiated by the player
    static let enemyAttack: UInt32 = 1 << 3    // Attacks coming from enemies
    static let projectile: UInt32 = 1 << 4     // Ranged attacks or thrown weapons
    static let hazard: UInt32 = 1 << 5         // Environmental hazards like traps or obstacles
    static let collectible: UInt32 = 1 << 6    // Health pickups, power-ups, etc.
}
