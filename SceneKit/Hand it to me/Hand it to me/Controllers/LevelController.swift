import SwiftUI
import SceneKit
import GameplayKit

class LevelController {
    var scene: GameSceneController
    var level: [[Int]]
    
    init(scene: SCNScene, level: [[Int]]) {
        self.scene = scene as! GameSceneController
        self.level = level
    }
    
    func addLevel(from layout: [[Int]], currentLevel: Int) {
        for (rowIndex, row) in layout.enumerated() {
            for (columnIndex, cell) in row.enumerated() {
                
                let node: SCNNode?
                
                switch cell {
                    //                case 0:
                    //                     ?
                case 1:
                    let wallNode = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                    //                    let wallMaterial = SCNMaterial()
                    //                    
                    //                    wallMaterial.diffuse.contents = colorForPlatform(.white)
                    //                    wallMaterial.normal.contents = loadTexture(named: "plaster normal")
                    //                    wallMaterial.roughness.contents = loadTexture(named: "plaster roughness")
                    //                    
                    //                    wallNode.firstMaterial = wallMaterial
                    
                    node = SCNNode(geometry: wallNode)
                    node?.name = "wall"
                case 2:
                    node = scene.cameraController?.cameraNode
                case 3:
                    let lampLight = SCNLight()
                    lampLight.type = .omni
                    lampLight.color = colorForPlatform(.gray)
                    lampLight.intensity = 42
                    
                    let lampNode = SCNNode()
                    lampNode.light = lampLight
                    lampNode.name = "houseLamp"
                    lampNode.position = SCNVector3(0, 1, 0)
                    
                    node = lampNode
                case 4:
                    let note = SCNBox(width: 0.1, height: 0.2, length: 0.02, chamferRadius: 0)
                    let noteNode = SCNNode(geometry: note)
                    noteNode.name = "note"
                    
                    node = noteNode
                case 5:
                    let lampLight = SCNLight()
                    lampLight.type = .omni
                    lampLight.color = colorForPlatform(.white)
                    lampLight.intensity = 8
                    lampLight.temperature = 87
                    
                    let lampNode = SCNNode()
                    lampNode.light = lampLight
                    lampNode.name = "houseLamp"
                    lampNode.position = SCNVector3(0, 1, 0)
                    
                    node = lampNode
                case 9:
                    let doorGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                    doorGeometry.firstMaterial?.diffuse.contents = colorForPlatform(.green)
                    node = SCNNode(geometry: doorGeometry)
                    node?.name = "door"
                default:
                    node = nil
                }
                
                if let node = node {
#if os(iOS) || os(tvOS) || os(visionOS)
                    node.position = SCNVector3(x: Float(columnIndex), y: node.position.y, z: Float(rowIndex))
                    
#elseif os(macOS)
                    node.position = SCNVector3(x: CGFloat(columnIndex), y: node.position.y, z: CGFloat(rowIndex))
                    
#endif
                    scene.rootNode.addChildNode(node)
                }
            }
        }
    }
    
    func createFloorExcludingWalls(gridSize: Int) {
        for x in 0..<gridSize {
            for z in 0..<gridSize {
                // Determine if the current position has a wall
#if os(macOS)
                let currentPosition = SCNVector3(CGFloat(x), -0.5, CGFloat(z))
#else
                let currentPosition = SCNVector3(Float(x), -0.5, Float(z))
#endif
                
                // Create the floor
                let floor = SCNBox(width: 1, height: 0.1, length: 1, chamferRadius: 0)
                //                let floorMaterial = SCNMaterial()
                //                
                //                floorMaterial.diffuse.contents = colorForPlatform(.brown)
                //                floorMaterial.normal.contents = loadTexture(named: "plaster normal")
                //                floorMaterial.roughness.contents = loadTexture(named: "plaster roughness")
                //                
                //                floor.firstMaterial = floorMaterial
                
                let floorNode = SCNNode(geometry: floor)
                floorNode.name = "floor"
                floorNode.position = currentPosition
                
                // Add the floor node to the scene
                scene.rootNode.addChildNode(floorNode)
            }
        }
    }
    
    func clearLevel() {
        scene.rootNode.childNodes.forEach { node in
            if node.name == "wall" || node.name == "floor" || node.name == "note" || node.name == "door" || node.name == "light" {
                node.removeFromParentNode()
            }
        }
    }
    
    //MARK: - Procedural Level Generation!!!
    func startProceduralLevelGeneration() {
        DispatchQueue.global(qos: .background).async {
            let randomInt = Int.random(in: 14..<34)
            let newLevel = self.generateProceduralLevel(rows: randomInt, columns: randomInt)
            
            DispatchQueue.main.async {
                levels.append(newLevel)
                print("Generated and appended a new level. Total levels: \(levels.count)")
                
                if levels.count >= 6 {
                    levels.removeFirst()
                }
            }
        }
    }
    
    func generateProceduralLevel(rows: Int, columns: Int) -> [[Int]] {
        let noiseSource = GKPerlinNoiseSource(frequency: 1.5, octaveCount: 4, persistence: 0.5, lacunarity: 2.0, seed: Int32.random(in: 0...Int32.max))
        let noiseMap = GKNoiseMap(GKNoise(noiseSource), size: vector_double2(2, 2), origin: vector_double2(0, 0), sampleCount: vector_int2(Int32(columns), Int32(rows)), seamless: false)
        
        var levelGrid: [[Int]] = Array(repeating: Array(repeating: 0, count: columns), count: rows)
        
        // Populate the grid with initial content
        for row in 0..<rows {
            for col in 0..<columns {
                if row == 0 || row == rows - 1 || col == 0 || col == columns - 1 {
                    // Outer walls
                    levelGrid[row][col] = 1
                    continue
                }
                
                let value = noiseMap.value(at: vector_int2(Int32(col), Int32(row)))
                switch value {
                case ..<(-0.2):
                    // Wall
                    levelGrid[row][col] = 1
                case -0.2..<0.2:
                    // Floor
                    levelGrid[row][col] = 0
                    // Adjusted range for collectibles (smaller range, less frequent)
                case 0.2..<0.27:
                    // Collectible
                    levelGrid[row][col] = 4
                default:
                    // Default floor
                    levelGrid[row][col] = 0
                }
            }
        }
        
        // Place the door first
        var doorPosition: (row: Int, col: Int)
        repeat {
            doorPosition = placeSingleDoor(rows: rows, columns: columns)
            // Temporarily mark the door
            levelGrid[doorPosition.row][doorPosition.col] = 9
        } while !isPathToDoor(levelGrid: levelGrid, startRow: rows / 2, startCol: columns / 2, doorRow: doorPosition.row, doorCol: doorPosition.col)
        
        // Place the player
        var playerPosition: (row: Int, col: Int)
        repeat {
            playerPosition = (row: rows / 2, col: columns / 2)
            // Player start position
            levelGrid[playerPosition.row][playerPosition.col] = 2
        } while !isPathToDoor(levelGrid: levelGrid, startRow: playerPosition.row, startCol: playerPosition.col, doorRow: doorPosition.row, doorCol: doorPosition.col)
        
        return levelGrid
    }
    
    func isPathToDoor(levelGrid: [[Int]], startRow: Int, startCol: Int, doorRow: Int, doorCol: Int) -> Bool {
        var visited = Array(repeating: Array(repeating: false, count: levelGrid[0].count), count: levelGrid.count)
        var queue: [(row: Int, col: Int)] = [(startRow, startCol)]
        
        while !queue.isEmpty {
            let (currentRow, currentCol) = queue.removeFirst()
            
            // If we've reached the door, return true
            if currentRow == doorRow && currentCol == doorCol {
                return true
            }
            
            // Mark as visited
            visited[currentRow][currentCol] = true
            
            // Explore neighbors (up, down, left, right)
            let neighbors = [
                (currentRow - 1, currentCol),
                (currentRow + 1, currentCol),
                (currentRow, currentCol - 1),
                (currentRow, currentCol + 1)
            ]
            
            for (neighborRow, neighborCol) in neighbors {
                if neighborRow >= 0, neighborRow < levelGrid.count,
                   neighborCol >= 0, neighborCol < levelGrid[0].count,
                   !visited[neighborRow][neighborCol],
                   levelGrid[neighborRow][neighborCol] != 1 { // Not a wall
                    queue.append((neighborRow, neighborCol))
                }
            }
        }
        
        // No path found
        return false
    }
    
    func placeSingleDoor(rows: Int, columns: Int) -> (row: Int, col: Int) {
        let edges: [Edge] = [
            // Top edge
            Edge(isHorizontal: true, position: 0, range: 1..<columns - 1),
            // Bottom edge
            Edge(isHorizontal: true, position: rows - 1, range: 1..<columns - 1),
            // Left edge
            Edge(isHorizontal: false, position: 0, range: 1..<rows - 1),
            // Right edge
            Edge(isHorizontal: false, position: columns - 1, range: 1..<rows - 1)
        ]
        
        let selectedEdge = edges.randomElement()!
        let selectedPosition = selectedEdge.range.randomElement()!
        
        if selectedEdge.isHorizontal {
            return (row: selectedEdge.position, col: selectedPosition)
        } else {
            return (row: selectedPosition, col: selectedEdge.position)
        }
    }
    
    func colorForPlatform(_ color: Color) -> Any {
#if os(iOS) || os(tvOS) || os(visionOS)
        return UIColor(color)
#elseif os(macOS)
        return NSColor(color)
#endif
    }
    
    func loadTexture(named textureName: String) -> Any {
#if os(iOS) || os(tvOS) || os(visionOS)
        return UIImage(named: textureName)!
#elseif os(macOS)
        return NSImage(named: textureName)!
#endif
    }
}



struct Edge {
    var isHorizontal: Bool
    var position: Int
    var range: Range<Int>
}



var levels: [[[Int]]] = [
    [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 2, 0, 0, 0, 3, 9, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ],
    [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 4, 3, 0, 5, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1],
        [1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1, 1, 1, 0, 4, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 2, 1, 1, 1, 1, 1, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1],
        [1, 1, 1, 1, 1, 1, 0, 0, 0, 4, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1],
        [1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1],
        [1, 0, 0, 1, 1, 1, 1, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 4, 0, 0, 0, 1, 1, 0, 0, 4, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1],
        [1, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1],
        [1, 4, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1],
        [1, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 4, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],
        [1, 1, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ],
    [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 0, 0, 4, 4, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 0, 0, 5, 4, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 1, 1, 1, 1, 1, 4, 0, 1, 1, 1, 1, 1, 1],
        [1, 0, 4, 0, 1, 1, 0, 4, 3, 0, 1, 1, 1, 1, 0, 1],
        [1, 0, 0, 0, 0, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 1, 1, 1, 4, 0, 0, 1, 1, 0, 0, 4, 4, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        [1, 0, 4, 4, 0, 1, 0, 1, 2, 1, 0, 4, 0, 0, 0, 1],
        [1, 0, 4, 4, 0, 0, 0, 1, 1, 1, 0, 0, 4, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1],
        [1, 0, 4, 0, 4, 4, 0, 0, 0, 0, 0, 4, 0, 0, 0, 1],
        [1, 0, 1, 0, 0, 4, 0, 4, 4, 0, 4, 4, 0, 0, 0, 1],
        [1, 4, 1, 0, 0, 0, 4, 4, 0, 0, 0, 4, 4, 0, 0, 1],
        [1, 4, 1, 0, 0, 0, 4, 4, 0, 4, 4, 4, 0, 0, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ]
]
