class LevelGenerator {
    private var level: [[Int]]
    let rows: Int
    var columns: Int
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.level = Array(repeating: Array(repeating: TileType.empty.rawValue, count: columns), count: rows)
    }
    
    func generateLevel(using tilesets: [[[Int]]], numberOfSections: Int) {
        guard numberOfSections > 0 else { return }
        var currentColumn = 0
        
        // Add the first tileset explicitly so we don't kill the player as soon as they start
        let initialTileset = tileset1
        addTileset(initialTileset, at: &currentColumn)
        
        // Add remaining sections randomly
        for _ in 1..<numberOfSections {
            guard let selectedTileset = tilesets.randomElement() else { continue }
            addTileset(selectedTileset, at: &currentColumn)
        }
    }
    
    private func addTileset(_ tileset: [[Int]], at currentColumn: inout Int) {
        columns = max(columns, currentColumn + tileset[0].count)
        
        for (row, tilesetRow) in tileset.enumerated() {
            if level.count <= row {
                level.append(Array(repeating: TileType.empty.rawValue, count: columns))
            }
            
            for (column, tile) in tilesetRow.enumerated() {
                let targetColumn = currentColumn + column
                guard targetColumn < columns else { continue }
                
                level[row][targetColumn] = tile
            }
        }
        
        currentColumn += tileset[0].count
    }
    
    func addNewSection(using tilesets: [[[Int]]] = []) {
        let sectionWidth = 16
        
        let newSection = tilesets.randomElement() ??
        Array(repeating: Array(repeating: TileType.empty.rawValue, count: sectionWidth), count: rows)
        
        guard newSection.count == rows else {
            fatalError("The number of rows in newSection (\(newSection.count)) does not match the expected number of rows (\(rows)).")
        }
        
        for row in 0..<rows {
            level[row].append(contentsOf: newSection[row])
        }
        columns += sectionWidth
    }
    
    func getLevel() -> [[Int]] {
        return level
    }
}
