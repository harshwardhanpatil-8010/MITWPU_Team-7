// MARK: - GameDifficulty.swift
// Defines the difficulty levels for the Jigsaw Puzzle game.
// Each difficulty maps to a specific grid dimension (e.g. Easy = 2x2).

import Foundation

/// Represents the difficulty level of the puzzle.
/// - easy:   2×2 grid  —  4 pieces (best for seniors with motor difficulties)
/// - medium: 3×3 grid  —  9 pieces
/// - hard:   4×4 grid  — 16 pieces
enum GameDifficulty: String, CaseIterable, Codable, Identifiable {

    case easy   = "Easy"
    case medium = "Medium"
    case hard   = "Hard"

    var id: String { rawValue }

    // MARK: - Grid dimensions

    /// Number of rows (and columns) for the grid.
    var gridSize: Int {
        switch self {
        case .easy:   return 2
        case .medium: return 3
        case .hard:   return 4
        }
    }

    /// Total number of puzzle pieces.
    var totalPieces: Int { gridSize * gridSize }

    // MARK: - Display metadata

    var displayName: String { rawValue }

    /// Short description shown on the difficulty card.
    var description: String {
        switch self {
        case .easy:   return "\(gridSize)×\(gridSize) grid • \(totalPieces) pieces"
        case .medium: return "\(gridSize)×\(gridSize) grid • \(totalPieces) pieces"
        case .hard:   return "\(gridSize)×\(gridSize) grid • \(totalPieces) pieces"
        }
    }

    /// SF Symbol name used for the difficulty icon.
    var iconName: String {
        switch self {
        case .easy:   return "square.grid.2x2"
        case .medium: return "square.grid.3x3"
        case .hard:   return "square.grid.4x3.fill"
        }
    }

    /// Accent color name from PuzzleTheme used for this difficulty card.
    var accentColorName: String {
        switch self {
        case .easy:   return "puzzleGreen"
        case .medium: return "puzzleTeal"
        case .hard:   return "puzzleCoral"
        }
    }
}
