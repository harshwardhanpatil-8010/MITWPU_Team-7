// MARK: - WinCelebrationView.swift
// Shown when the player solves the puzzle.
// Displays animated confetti, completion stats, and navigation options.

import SwiftUI

struct WinCelebrationView: View {

    let elapsedTime: String
    let moveCount: Int
    let difficulty: GameDifficulty
    let onPlayAgain: () -> Void   // restart same puzzle re-shuffled
    let onNewGame: () -> Void     // go back to home screen

    @State private var appeared     = false
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(appeared ? 0.55 : 0)
                .ignoresSafeArea()

            // Main celebration card
            VStack(spacing: PuzzleTheme.spacingL) {

                // Confetti layer (simple emoji burst)
                if showConfetti {
                    ConfettiEmoji()
                        .allowsHitTesting(false)
                }

                // Trophy icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.5), radius: 12)
                    .scaleEffect(appeared ? 1 : 0.3)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.6).delay(0.1),
                        value: appeared
                    )

                // Title
                Text("Puzzle Complete!")
                    .font(PuzzleTheme.largeTitle())
                    .foregroundColor(PuzzleTheme.textPrimary)
                    .multilineTextAlignment(.center)

                // Subtitle
                Text("Well done! Keep it up 🎉")
                    .font(PuzzleTheme.body())
                    .foregroundColor(PuzzleTheme.textSecondary)

                // Stats row
                HStack(spacing: PuzzleTheme.spacingM) {
                    StatBubble(icon: "timer",
                               value: elapsedTime,
                               label: "Time")
                    StatBubble(icon: "arrow.left.arrow.right",
                               value: "\(moveCount)",
                               label: "Moves")
                    StatBubble(icon: difficulty.iconName,
                               value: difficulty.displayName,
                               label: "Level")
                }
                .padding(.vertical, PuzzleTheme.spacingS)

                // Action buttons
                VStack(spacing: PuzzleTheme.spacingS) {
                    Button(action: onPlayAgain) {
                        Label("Play Again", systemImage: "arrow.counterclockwise")
                            .puzzlePrimaryButton(color: PuzzleTheme.accent)
                    }
                    .padding(.horizontal, PuzzleTheme.spacingS)
                    .accessibilityLabel("Play Again: restart the same puzzle")

                    Button(action: onNewGame) {
                        Label("New Puzzle", systemImage: "house.fill")
                            .puzzleSecondaryButton(color: PuzzleTheme.accentSecondary)
                    }
                    .padding(.horizontal, PuzzleTheme.spacingS)
                    .accessibilityLabel("New Puzzle: return to home screen")
                }
            }
            .padding(PuzzleTheme.spacingXL)
            .background(
                RoundedRectangle(cornerRadius: PuzzleTheme.radiusXL, style: .continuous)
                    .fill(PuzzleTheme.cardBackground)
                    .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 10)
            )
            .padding(.horizontal, PuzzleTheme.spacingL)
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
}

// MARK: - StatBubble

private struct StatBubble: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(PuzzleTheme.accent)
            Text(value)
                .font(PuzzleTheme.headline())
                .foregroundColor(PuzzleTheme.textPrimary)
                .monospacedDigit()
            Text(label)
                .font(PuzzleTheme.caption())
                .foregroundColor(PuzzleTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PuzzleTheme.spacingS)
        .background(
            RoundedRectangle(cornerRadius: PuzzleTheme.radiusS, style: .continuous)
                .fill(PuzzleTheme.accent.opacity(0.08))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Simple confetti animation

private struct ConfettiEmoji: View {

    private struct Particle: Identifiable {
        let id = UUID()
        let emoji: String
        let x: CGFloat
        let delay: Double
        let duration: Double
        let size: CGFloat
    }

    private let emojis = ["🎉", "⭐️", "🌟", "✨", "🎊", "🏆", "🌈"]
    @State private var particles: [Particle] = []
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    Text(p.emoji)
                        .font(.system(size: p.size))
                        .position(
                            x: p.x,
                            y: animate ? geo.size.height + 60 : -60
                        )
                        .animation(
                            .easeIn(duration: p.duration)
                            .delay(p.delay)
                            .repeatForever(autoreverses: false),
                            value: animate
                        )
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            particles = (0..<20).map { _ in
                Particle(
                    emoji:    emojis.randomElement()!,
                    x:        CGFloat.random(in: 20...340),
                    delay:    Double.random(in: 0...1.2),
                    duration: Double.random(in: 1.5...3.0),
                    size:     CGFloat.random(in: 18...36)
                )
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animate = true
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    WinCelebrationView(
        elapsedTime: "03:22",
        moveCount: 14,
        difficulty: .medium,
        onPlayAgain: {},
        onNewGame: {}
    )
}
#endif
