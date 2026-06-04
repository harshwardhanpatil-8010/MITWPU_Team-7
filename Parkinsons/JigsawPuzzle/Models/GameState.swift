
import Foundation

enum GameState: Equatable {
    case notStarted
    case playing
    case paused
    case completed
}

struct SavedGameData: Codable {

    let difficulty: GameDifficulty

    let imageName: String

    let pieceOrder: [Int]

    let elapsedTime: TimeInterval

    let moveCount: Int

    let startedAt: Date

    let savedAt: Date
}
