struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let enemy: UInt32 = 1 << 1
    static let playerAttack: UInt32 = 1 << 2
    static let enemyAttack: UInt32 = 1 << 3
    static let projectile: UInt32 = 1 << 4
    static let hazard: UInt32 = 1 << 5
    static let collectible: UInt32 = 1 << 6
    // More ??
}
