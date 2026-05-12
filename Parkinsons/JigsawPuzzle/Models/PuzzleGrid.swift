// MARK: - PuzzleGrid.swift
// Describes the geometry and completion state of the puzzle board.

import UIKit

/// Represents the full puzzle grid — its dimensions, pieces, and source image.
struct PuzzleGrid {

    // MARK: - Configuration

    /// Difficulty driving the grid dimensions.
    let difficulty: GameDifficulty

    /// The full-resolution source image before slicing.
    let sourceImage: UIImage

    /// All puzzle pieces in their current (possibly shuffled) order.
    var pieces: [PuzzlePiece]

    // MARK: - Convenience accessors

    var rows: Int    { difficulty.gridSize }
    var columns: Int { difficulty.gridSize }
    var totalPieces: Int { rows * columns }

    // MARK: - Completion detection

    /// Returns `true` when every piece is in its correct position.
    var isComplete: Bool {
        pieces.allSatisfy { $0.isPlacedCorrectly }
    }

    /// Number of correctly placed pieces (for progress display).
    var placedCount: Int {
        pieces.filter { $0.isPlacedCorrectly }.count
    }

    // MARK: - Grid geometry helpers

    /// Calculates the size (width = height) of each piece given a board width.
    func pieceSize(for boardWidth: CGFloat) -> CGFloat {
        boardWidth / CGFloat(columns)
    }
}
