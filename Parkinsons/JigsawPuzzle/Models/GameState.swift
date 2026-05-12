// MARK: - GameState.swift
// Defines the possible states of the puzzle game and the
// data structure used to persist a game session.

import Foundation

// MARK: - GameState

/// The lifecycle state of the puzzle game.
enum GameState: Equatable {
    /// Player is on the home screen; no active game.
    case notStarted
    /// A game is in progress and the timer is running.
    case playing
    /// The game is paused (e.g. app backgrounded or preview shown).
    case paused
    /// The puzzle has been solved — celebration is shown.
    case completed
}

// MARK: - SavedGameData

/// Codable snapshot of an in-progress game, persisted to UserDefaults
/// so the player can resume after leaving the app.
struct SavedGameData: Codable {

    /// Which difficulty level the saved game used.
    let difficulty: GameDifficulty

    /// The name of the puzzle image used (maps to a built-in image key).
    let imageName: String

    /// The current piece order: each element is the `id` (correct index)
    /// of the piece currently occupying that slot. Length == totalPieces.
    let pieceOrder: [Int]

    /// How many seconds the player has already spent on this puzzle.
    let elapsedTime: TimeInterval

    /// How many swap moves have been made.
    let moveCount: Int

    /// When the game was originally started.
    let startedAt: Date

    /// When the game was last saved.
    let savedAt: Date
}
