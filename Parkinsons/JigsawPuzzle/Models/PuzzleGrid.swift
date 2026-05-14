
import UIKit

struct PuzzleGrid {

    let difficulty: GameDifficulty

    let sourceImage: UIImage

    var pieces: [PuzzlePiece]


    var rows: Int    { difficulty.gridSize }
    var columns: Int { difficulty.gridSize }
    var totalPieces: Int { rows * columns }

    var isComplete: Bool {
        pieces.allSatisfy { $0.isPlacedCorrectly }
    }

    var placedCount: Int {
        pieces.filter { $0.isPlacedCorrectly }.count
    }

    func pieceSize(for boardWidth: CGFloat) -> CGFloat {
        boardWidth / CGFloat(columns)
    }
}
