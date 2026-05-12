// MARK: - DifficultyPickerView.swift
// A horizontal row of three large, tappable difficulty cards.
// Each card shows a grid icon, name, description, and piece count.
// Designed for elderly users: minimum 44-pt touch targets, large text.

import SwiftUI

struct DifficultyPickerView: View {

    @Binding var selected: GameDifficulty

    var body: some View {
        HStack(spacing: PuzzleTheme.spacingS) {
            ForEach(GameDifficulty.allCases) { difficulty in
                DifficultyCard(
                    difficulty: difficulty,
                    isSelected: selected == difficulty
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = difficulty
                    }
                }
            }
        }
    }
}

// MARK: - DifficultyCard

private struct DifficultyCard: View {

    let difficulty: GameDifficulty
    let isSelected: Bool

    private var accentColor: Color {
        PuzzleTheme.difficultyColor(for: difficulty)
    }

    var body: some View {
        VStack(spacing: PuzzleTheme.spacingS) {

            // Grid icon
            Image(systemName: difficulty.iconName)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(isSelected ? accentColor : PuzzleTheme.textSecondary)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(isSelected ? accentColor.opacity(0.15) : Color.clear)
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

            // Difficulty name
            Text(difficulty.displayName)
                .font(PuzzleTheme.headline())
                .foregroundColor(isSelected ? accentColor : PuzzleTheme.textPrimary)

            // Piece count description
            Text(difficulty.description)
                .font(PuzzleTheme.caption())
                .foregroundColor(PuzzleTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, PuzzleTheme.spacingM)
        .padding(.horizontal, PuzzleTheme.spacingS)
        .frame(maxWidth: .infinity)
        .frame(minHeight: PuzzleTheme.minimumTouchTarget * 2.5)
        .background(
            RoundedRectangle(cornerRadius: PuzzleTheme.radiusM, style: .continuous)
                .fill(PuzzleTheme.cardBackground)
                .shadow(
                    color: isSelected ? accentColor.opacity(0.25) : PuzzleTheme.shadow,
                    radius: isSelected ? 10 : 6,
                    x: 0, y: 3
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: PuzzleTheme.radiusM, style: .continuous)
                .strokeBorder(
                    isSelected ? accentColor : Color.clear,
                    lineWidth: 2
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(difficulty.displayName) difficulty, \(difficulty.description)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    @Previewable @State var selected: GameDifficulty = .medium
    DifficultyPickerView(selected: $selected)
        .padding()
        .background(PuzzleTheme.background)
}
#endif
