
import CoreGraphics
import Foundation

enum PuzzleConstants {

    static let minimumDragDistance: CGFloat = 5

    static let snapAnimationDuration: Double = 0.25

    static let shuffleAnimationDuration: Double = 0.4

    static let shuffleDelay: Double = 0.6

    static let celebrationAnimationDuration: Double = 0.5

    static let timerInterval: TimeInterval = 1.0

    static let savedGameKey = "jigsaw_saved_game_v1"

    static let soundEnabledKey = "jigsaw_sound_enabled"

    static let dailyEmojis: [String] = [
        "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", 
        "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔",
        "🍎", "🍊", "🍋", "🍇", "🍓", "🫐", "🍑", "🍒", 
        "🌸", "🌺", "🌻", "🌹", "🦋", "🐝", "🐞"
    ]

    static func emoji(for date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return dailyEmojis[(day - 1) % dailyEmojis.count]
    }

    static let memorizeDelay: Double = 2.0

    static let boardPadding: CGFloat = 24

    static let pieceGap: CGFloat = 0

    static let pieceCornerRadius: CGFloat = 4

    static let correctPlacementBorderWidth: CGFloat = 3

    static let previewOverlayOpacity: Double = 0.6

    static let previewAutoDismissDuration: Double = 0  
}
