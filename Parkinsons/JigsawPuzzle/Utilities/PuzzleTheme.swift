
import SwiftUI

enum PuzzleTheme {

    static var background: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
                : UIColor.white
        })
    }
    static var cardBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1)
                : UIColor.white
        })
    }

    static let accent = Color(red: 0.494, green: 0.722, blue: 0.792)
    static let accentSecondary = Color(red: 0.722, green: 0.831, blue: 0.639)
    static let accentCoral = Color(red: 0.922, green: 0.647, blue: 0.596)

    static let success = Color(red: 0.545, green: 0.773, blue: 0.545)
    static var textPrimary: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? .white : UIColor(red: 0.173, green: 0.243, blue: 0.314, alpha: 1)
        })
    }

    static var textSecondary: Color { Color(UIColor.secondaryLabel) }

    static var separator: Color { Color(UIColor.separator) }

    static let shadow = Color.black.opacity(0.08)

    static func difficultyColor(for difficulty: GameDifficulty) -> Color {
        switch difficulty {
        case .easy:   return accentSecondary
        case .medium: return accent
        case .hard:   return accentCoral
        }
    }

    static func largeTitle() -> Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }

    static func title() -> Font {
        .system(size: 24, weight: .semibold, design: .rounded)
    }

    static func headline() -> Font {
        .system(size: 17, weight: .semibold, design: .rounded)
    }

    static func body() -> Font {
        .system(size: 17, weight: .regular, design: .rounded)
    }

    static func caption() -> Font {
        .system(size: 13, weight: .medium, design: .rounded)
    }

    static func buttonLabel() -> Font {
        .system(size: 19, weight: .semibold, design: .rounded)
    }


    static let spacingXS: CGFloat  = 4
    static let spacingS: CGFloat   = 8
    static let spacingM: CGFloat   = 16
    static let spacingL: CGFloat   = 24
    static let spacingXL: CGFloat  = 36
    static let spacingXXL: CGFloat = 52


    static let radiusS: CGFloat  = 8
    static let radiusM: CGFloat  = 16
    static let radiusL: CGFloat  = 24
    static let radiusXL: CGFloat = 32

    static let shadowRadius: CGFloat  = 12
    static let shadowY: CGFloat       = 4
    static let shadowOpacity: Float   = 0.08

    static let minimumTouchTarget: CGFloat = 44
}
