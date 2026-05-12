// MARK: - PuzzleHomeView.swift
// Home screen: title, image preview, difficulty picker, Start/Resume.

import SwiftUI

struct PuzzleHomeView: View {
    @StateObject private var viewModel = PuzzleViewModel()
    @State private var selectedDifficulty: GameDifficulty = .medium
    @State private var isPlayingGame = false
    @State private var previewImage: UIImage? = nil
    @State private var animateIn = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [PuzzleTheme.background, PuzzleTheme.accent.opacity(0.05)],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: PuzzleTheme.spacingL) {
                    headerSection.opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 15)
                    imagePreviewCard.opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                    VStack(alignment: .leading, spacing: PuzzleTheme.spacingS) {
                        Text("Choose Difficulty").font(PuzzleTheme.headline()).foregroundColor(PuzzleTheme.textPrimary).padding(.leading, PuzzleTheme.spacingXS)
                        DifficultyPickerView(selected: $selectedDifficulty)
                    }.opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 25)
                    actionButtons.opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 30)
                    soundToggle.opacity(animateIn ? 1 : 0)
                    Spacer(minLength: PuzzleTheme.spacingXL)
                }
                .padding(.horizontal, PuzzleTheme.spacingM).padding(.top, PuzzleTheme.spacingM)
            }
        }
        .onAppear { loadPreview(); viewModel.refreshSavedGameStatus(); withAnimation(.easeOut(duration: 0.5)) { animateIn = true } }
        .onChange(of: selectedDifficulty) { _, _ in loadPreview() }
        .fullScreenCover(isPresented: $isPlayingGame) { PuzzleGameView(viewModel: viewModel) }
    }

    private func loadPreview() {
        previewImage = PuzzleGeneratorService.generateSourceImage(difficulty: selectedDifficulty, date: Date())
    }

    private var headerSection: some View {
        VStack(spacing: PuzzleTheme.spacingXS) {
            Image(systemName: "puzzlepiece.extension.fill").font(.system(size: 44, weight: .semibold))
                .foregroundStyle(LinearGradient(colors: [PuzzleTheme.accent, PuzzleTheme.accentSecondary], startPoint: .topLeading, endPoint: .bottomTrailing))
            Text("Jigsaw Puzzle").font(PuzzleTheme.largeTitle()).foregroundColor(PuzzleTheme.textPrimary)
            Text("Drag the pieces to solve the picture!").font(PuzzleTheme.body()).foregroundColor(PuzzleTheme.textSecondary).multilineTextAlignment(.center)
        }.padding(.top, PuzzleTheme.spacingM)
    }

    private var imagePreviewCard: some View {
        VStack(spacing: PuzzleTheme.spacingS) {
            if let img = previewImage {
                Image(uiImage: img).resizable().scaledToFit().frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: PuzzleTheme.radiusM, style: .continuous))
            }
            Text("Today's Puzzle").font(PuzzleTheme.caption()).foregroundColor(PuzzleTheme.textSecondary)
        }.padding(PuzzleTheme.spacingS).puzzleCard()
    }

    private var actionButtons: some View {
        VStack(spacing: PuzzleTheme.spacingS) {
            Button { viewModel.startNewGame(difficulty: selectedDifficulty); isPlayingGame = true } label: {
                Label("Start Game", systemImage: "play.fill").puzzlePrimaryButton(color: PuzzleTheme.accent)
            }
            if viewModel.hasSavedGame {
                Button { viewModel.startNewGame(difficulty: selectedDifficulty); isPlayingGame = true } label: {
                    Label("Resume Game", systemImage: "arrow.uturn.forward").puzzleSecondaryButton(color: PuzzleTheme.accentSecondary)
                }.transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var soundToggle: some View {
        HStack {
            Image(systemName: viewModel.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.system(size: 18, weight: .medium)).foregroundColor(PuzzleTheme.textSecondary)
            Text(viewModel.soundEnabled ? "Sound On" : "Sound Off").font(PuzzleTheme.body()).foregroundColor(PuzzleTheme.textSecondary)
            Spacer()
            Toggle("", isOn: $viewModel.soundEnabled).labelsHidden().tint(PuzzleTheme.accent)
                .onChange(of: viewModel.soundEnabled) { _, val in GamePersistenceService.saveSoundEnabled(val) }
        }
        .padding(.horizontal, PuzzleTheme.spacingM).padding(.vertical, PuzzleTheme.spacingS).puzzleCard()
    }
}

#if DEBUG
#Preview { PuzzleHomeView() }
#endif
