// MARK: - PuzzleTheme.swift
// Central design system for the Jigsaw Puzzle game.
// All colors, fonts, spacing, and radii come from here — never hardcoded in views.
// Designed with a calm, therapeutic aesthetic for elderly and Parkinson's users.

import SwiftUI

enum PuzzleTheme {

    // MARK: - Colors

    /// Warm ivory background — calming, easy on eyes.
    static var background: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)   // near-black
                : UIColor.white // Pure white as requested
        })
    }

    /// Card surface — white in light, elevated dark in dark mode.
    static var cardBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1)
                : UIColor.white
        })
    }

    /// Soft teal — primary accent for buttons and highlights.
    static let accent = Color(red: 0.494, green: 0.722, blue: 0.792)          // #7EB8C9

    /// Sage green — secondary accent, correct-placement feedback.
    static let accentSecondary = Color(red: 0.722, green: 0.831, blue: 0.639) // #B8D4A3

    /// Soft coral — hard difficulty badge, warning accents.
    static let accentCoral = Color(red: 0.922, green: 0.647, blue: 0.596)     // #EBA598

    /// Success green — correctly placed piece glow.
    static let success = Color(red: 0.545, green: 0.773, blue: 0.545)         // #8BC58B

    /// Primary text — dark slate.
    static var textPrimary: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? .white : UIColor(red: 0.173, green: 0.243, blue: 0.314, alpha: 1)
        })
    }

    /// Secondary text — muted grey.
    static var textSecondary: Color { Color(UIColor.secondaryLabel) }

    /// Subtle separator / border colour.
    static var separator: Color { Color(UIColor.separator) }

    /// Shadow color — soft neutral.
    static let shadow = Color.black.opacity(0.08)

    /// Difficulty-specific accent colors (indexed by GameDifficulty).
    static func difficultyColor(for difficulty: GameDifficulty) -> Color {
        switch difficulty {
        case .easy:   return accentSecondary
        case .medium: return accent
        case .hard:   return accentCoral
        }
    }

    // MARK: - Typography

    /// Large title: used for screen headings. System rounded, bold.
    static func largeTitle() -> Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }

    /// Title: section headings.
    static func title() -> Font {
        .system(size: 24, weight: .semibold, design: .rounded)
    }

    /// Headline: card titles, HUD labels.
    static func headline() -> Font {
        .system(size: 17, weight: .semibold, design: .rounded)
    }

    /// Body: descriptions, instructions.
    static func body() -> Font {
        .system(size: 17, weight: .regular, design: .rounded)
    }

    /// Caption: small labels, badges.
    static func caption() -> Font {
        .system(size: 13, weight: .medium, design: .rounded)
    }

    /// Large button label.
    static func buttonLabel() -> Font {
        .system(size: 19, weight: .semibold, design: .rounded)
    }

    // MARK: - Spacing

    static let spacingXS: CGFloat  = 4
    static let spacingS: CGFloat   = 8
    static let spacingM: CGFloat   = 16
    static let spacingL: CGFloat   = 24
    static let spacingXL: CGFloat  = 36
    static let spacingXXL: CGFloat = 52

    // MARK: - Corner Radii

    static let radiusS: CGFloat  = 8
    static let radiusM: CGFloat  = 16
    static let radiusL: CGFloat  = 24
    static let radiusXL: CGFloat = 32

    // MARK: - Shadows

    /// Standard card shadow.
    static let shadowRadius: CGFloat  = 12
    static let shadowY: CGFloat       = 4
    static let shadowOpacity: Float   = 0.08

    // MARK: - Minimum Touch Target

    /// Apple HIG minimum touch target: 44×44 pt.
    static let minimumTouchTarget: CGFloat = 44
}
