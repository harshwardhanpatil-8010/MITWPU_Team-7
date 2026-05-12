// MARK: - PuzzlePreviewOverlay.swift
// Full-screen overlay showing the completed puzzle image. Tap to dismiss.

import SwiftUI

struct PuzzlePreviewOverlay: View {
    let image: UIImage; let onDismiss: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(appeared ? 0.6 : 0).ignoresSafeArea().onTapGesture { dismiss() }
            VStack(spacing: PuzzleTheme.spacingM) {
                VStack(spacing: PuzzleTheme.spacingXS) {
                    Text("Complete Picture").font(PuzzleTheme.title()).foregroundColor(.white)
                    Text("Tap anywhere to continue").font(PuzzleTheme.caption()).foregroundColor(.white.opacity(0.7))
                }.padding(.top, PuzzleTheme.spacingL)

                Image(uiImage: image).resizable().scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: PuzzleTheme.radiusM, style: .continuous))
                    .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
                    .padding(.horizontal, PuzzleTheme.spacingL)
                    .scaleEffect(appeared ? 1 : 0.85)

                Button(action: dismiss) {
                    Label("Got it", systemImage: "checkmark.circle.fill")
                        .font(PuzzleTheme.headline()).foregroundColor(.white)
                        .padding(.horizontal, PuzzleTheme.spacingL)
                        .padding(.vertical, PuzzleTheme.spacingM)
                        .background(Capsule().fill(PuzzleTheme.accent.opacity(0.9)))
                }.padding(.bottom, PuzzleTheme.spacingXL)
            }
            .opacity(appeared ? 1 : 0)
        }
        .onAppear { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { appeared = true } }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) { appeared = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onDismiss() }
    }
}
