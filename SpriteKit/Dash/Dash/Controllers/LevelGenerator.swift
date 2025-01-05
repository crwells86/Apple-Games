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
        var currentColumn = 0
        
        for _ in 0..<numberOfSections {
            // Randomly pick a tileset
            guard let selectedTileset = tilesets.randomElement() else { continue }
            addNewSection(using: tilesets)
            
            columns = max(columns, currentColumn + selectedTileset[0].count)
            
            for (row, tilesetRow) in selectedTileset.enumerated() {
                if level.count <= row {
                    level.append(Array(repeating: TileType.empty.rawValue, count: columns))
                }
                
                for (column, tile) in tilesetRow.enumerated() {
                    let targetColumn = currentColumn + column
                    guard targetColumn < columns else { continue }
                    
                    level[row][targetColumn] = tile
                }
            }
            
            currentColumn += selectedTileset[0].count
        }
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
