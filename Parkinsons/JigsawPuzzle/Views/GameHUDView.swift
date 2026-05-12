// MARK: - GameHUDView.swift
// The heads-up display shown at the top of the game screen.
// Shows: timer, move count, difficulty badge.
// All text at minimum 17pt for accessibility.

import SwiftUI

struct GameHUDView: View {

    let elapsedTime: String   // pre-formatted "MM:SS"
    let moveCount: Int
    let difficulty: GameDifficulty

    var body: some View {
        HStack(spacing: 0) {

            // Timer pill
            HUDPill(
                icon: "timer",
                value: elapsedTime,
                label: "Time"
            )

            Spacer()

            // Difficulty badge (centre)
            DifficultyBadge(difficulty: difficulty)

            Spacer()

            // Move counter pill
            HUDPill(
                icon: "arrow.left.arrow.right",
                value: "\(moveCount)",
                label: "Moves"
            )
        }
        .padding(.horizontal, PuzzleTheme.spacingM)
        .padding(.vertical, PuzzleTheme.spacingS)
        .background(PuzzleTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: PuzzleTheme.radiusM, style: .continuous))
        .shadow(color: PuzzleTheme.shadow, radius: 8, x: 0, y: 2)
    }
}

// MARK: - HUDPill

private struct HUDPill: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(PuzzleTheme.accent)
                Text(value)
                    .font(PuzzleTheme.headline())
                    .foregroundColor(PuzzleTheme.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: value)
            }
            Text(label)
                .font(PuzzleTheme.caption())
                .foregroundColor(PuzzleTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - DifficultyBadge

private struct DifficultyBadge: View {
    let difficulty: GameDifficulty

    var body: some View {
        Text(difficulty.displayName)
            .font(PuzzleTheme.caption())
            .foregroundColor(.white)
            .padding(.horizontal, PuzzleTheme.spacingS)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(PuzzleTheme.difficultyColor(for: difficulty))
            )
            .accessibilityLabel("Difficulty: \(difficulty.displayName)")
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    GameHUDView(elapsedTime: "02:45", moveCount: 12, difficulty: .medium)
        .padding()
        .background(PuzzleTheme.background)
}
#endif
