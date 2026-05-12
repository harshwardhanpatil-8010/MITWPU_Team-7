// MARK: - PuzzleConstants.swift
// App-wide configuration constants for the Jigsaw Puzzle game.
// Centralised here so they are easy to tune without hunting through view code.

import CoreGraphics
import Foundation

enum PuzzleConstants {

    // MARK: - Gesture thresholds

    /// Minimum drag distance (points) before a drag gesture is recognised.
    static let minimumDragDistance: CGFloat = 5

    // MARK: - Animation durations

    /// Duration for a piece snapping into a grid cell.
    static let snapAnimationDuration: Double = 0.25

    /// Duration for the shuffle animation at game start.
    static let shuffleAnimationDuration: Double = 0.4

    /// Delay before the shuffle begins after the game is started.
    static let shuffleDelay: Double = 0.6

    /// Duration of the win-celebration entry animation.
    static let celebrationAnimationDuration: Double = 0.5

    // MARK: - Timer

    /// Combine timer publish interval (seconds).
    static let timerInterval: TimeInterval = 1.0

    // MARK: - Persistence

    /// UserDefaults key for saved game data.
    static let savedGameKey = "jigsaw_saved_game_v1"

    /// UserDefaults key for sound-enabled preference.
    static let soundEnabledKey = "jigsaw_sound_enabled"

    // MARK: - Puzzle images
    // These are the built-in puzzle image names stored in the asset catalog.
    // The game cycles through them or picks one per day.

    /// Emojis used for the daily puzzle image.
    static let dailyEmojis: [String] = [
        "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", 
        "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔",
        "🍎", "🍊", "🍋", "🍇", "🍓", "🫐", "🍑", "🍒", 
        "🌸", "🌺", "🌻", "🌹", "🦋", "🐝", "🐞"
    ]

    /// Returns an emoji deterministically for a given calendar date.
    static func emoji(for date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return dailyEmojis[(day - 1) % dailyEmojis.count]
    }

    /// Duration (seconds) to show the solved puzzle before shuffling.
    static let memorizeDelay: Double = 2.0

    // MARK: - Board layout

    /// Padding between the puzzle board edge and the screen edge (points).
    static let boardPadding: CGFloat = 24

    /// Gap between adjacent puzzle pieces (points).
    static let pieceGap: CGFloat = 0

    // MARK: - Piece rendering

    /// Corner radius applied to each puzzle piece image (subtle rounding).
    static let pieceCornerRadius: CGFloat = 4

    /// Width of the highlight border shown on a correctly-placed piece.
    static let correctPlacementBorderWidth: CGFloat = 3

    // MARK: - Preview overlay

    /// Opacity of the dim overlay behind the image preview.
    static let previewOverlayOpacity: Double = 0.6

    /// How long (seconds) the full-image preview is shown before auto-dismiss.
    /// Set to 0 to require manual dismissal.
    static let previewAutoDismissDuration: Double = 0    // manual dismiss
}
