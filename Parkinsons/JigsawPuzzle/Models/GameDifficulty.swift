

import Foundation

enum GameDifficulty: String, CaseIterable, Codable, Identifiable {

    case easy   = "Easy"
    case medium = "Medium"
    case hard   = "Hard"

    var id: String { rawValue }

    var gridSize: Int {
        switch self {
        case .easy:   return 2
        case .medium: return 3
        case .hard:   return 4
        }
    }

    var totalPieces: Int { gridSize * gridSize }


    var displayName: String { rawValue }

    var description: String {
        switch self {
        case .easy:   return "\(gridSize)×\(gridSize) grid • \(totalPieces) pieces"
        case .medium: return "\(gridSize)×\(gridSize) grid • \(totalPieces) pieces"
        case .hard:   return "\(gridSize)×\(gridSize) grid • \(totalPieces) pieces"
        }
    }
    var iconName: String {
        switch self {
        case .easy:   return "square.grid.2x2"
        case .medium: return "square.grid.3x3"
        case .hard:   return "square.grid.4x3.fill"
        }
    }

    var accentColorName: String {
        switch self {
        case .easy:   return "puzzleGreen"
        case .medium: return "puzzleTeal"
        case .hard:   return "puzzleCoral"
        }
    }
}
