
import SwiftUI

struct PuzzleGameView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var boardAppeared = false

    var body: some View {
        ZStack {
            PuzzleTheme.background.ignoresSafeArea()

            VStack(spacing: PuzzleTheme.spacingS) {
                topBar

                if viewModel.isMemorizing {
                    memorizeBanner.transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    HStack {
                        Text("Time: \(viewModel.elapsedTime.mmss)")
                            .font(PuzzleTheme.headline())
                            .foregroundColor(PuzzleTheme.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, PuzzleTheme.spacingL)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                PuzzleBoardView(viewModel: viewModel)
                    .padding(.horizontal, PuzzleConstants.boardPadding)
                    .scaleEffect(boardAppeared ? 1 : 0.9)
                    .opacity(boardAppeared ? 1 : 0)
                    .allowsHitTesting(!viewModel.isMemorizing)

                if !viewModel.isMemorizing && !viewModel.trayPieces.isEmpty {
                    pieceTray.transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer(minLength: 0)
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.isMemorizing)

            if viewModel.showPreview, let img = viewModel.sourceImage {
                PuzzlePreviewOverlay(image: img) { viewModel.togglePreview() }
                    .transition(.opacity).zIndex(10)
            }
        }
        .onAppear { boardAppeared = true }
        .onDisappear { if viewModel.gameState == .playing { viewModel.saveCurrentProgress() } }
    }


    private var pieceTray: some View {
        VStack(spacing: PuzzleTheme.spacingXS) {
            HStack(spacing: 6) {
                Image(systemName: "hand.draw.fill")
                    .foregroundColor(PuzzleTheme.accent)
                Text("Long press and drag pieces to the board")
                    .font(PuzzleTheme.caption())
                    .foregroundColor(PuzzleTheme.textSecondary)
            }
            .padding(.top, PuzzleTheme.spacingS)
            ScrollView(.vertical, showsIndicators: false) {
                let columns = [GridItem(.adaptive(minimum: 72, maximum: 90))]
                LazyVGrid(columns: columns, spacing: PuzzleTheme.spacingS) {
                    ForEach(viewModel.trayPieces) { piece in
                        TrayPieceView(piece: piece, size: 64)
                    }
                }
                .padding(.horizontal, PuzzleTheme.spacingM)
                .padding(.vertical, PuzzleTheme.spacingS)
            }
           
            .clipped()
        }
        .frame(maxHeight: 240)
        .background(
            RoundedRectangle(cornerRadius: PuzzleTheme.radiusM, style: .continuous)
                .fill(PuzzleTheme.cardBackground)
                .shadow(color: PuzzleTheme.shadow, radius: 8, x: 0, y: -2)
        )
        .clipShape(RoundedRectangle(cornerRadius: PuzzleTheme.radiusM, style: .continuous))
        .padding(.horizontal, PuzzleTheme.spacingS)
    }


    private var memorizeBanner: some View {
        VStack(spacing: PuzzleTheme.spacingS) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(PuzzleTheme.accent)
            Text(viewModel.memorizeLabel)
                .font(PuzzleTheme.title())
                .foregroundColor(PuzzleTheme.textPrimary)

            Capsule()
                .fill(PuzzleTheme.accent.opacity(0.2))
                .frame(width: 200, height: 6)
                .overlay(
                    Capsule()
                        .fill(PuzzleTheme.accent)
                        .frame(width: 200 * CGFloat(viewModel.memorizeProgress), height: 6),
                    alignment: .leading
                )
                .padding(.top, 4)

            Text("Study the positions carefully")
                .font(PuzzleTheme.body())
                .foregroundColor(PuzzleTheme.textSecondary)
        }
        .padding(.vertical, PuzzleTheme.spacingL)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: PuzzleTheme.radiusL, style: .continuous)
                .fill(PuzzleTheme.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, PuzzleTheme.spacingM)
    }


    private var topBar: some View {
        HStack {
            Button {
                viewModel.returnToHome()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(PuzzleTheme.textPrimary)
                    .puzzleIconButton(size: 44)
            }
            Spacer()
            Button { viewModel.togglePreview() } label: {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(PuzzleTheme.textPrimary)
                    .puzzleIconButton(size: 44)
            }
        }
        .padding(.horizontal, PuzzleTheme.spacingM)
        .padding(.top, PuzzleTheme.spacingXS)
    }
}


private struct TrayPieceView: View {
    let piece: PuzzlePiece
    let size: CGFloat

    var body: some View {
        Image(uiImage: piece.image)
            .resizable()
            .scaledToFill()
            .frame(width: size * 1.5, height: size * 1.5)
            .clipShape(
                PuzzlePieceShape(
                    top: piece.edges.top, right: piece.edges.right,
                    bottom: piece.edges.bottom, left: piece.edges.left
                )
            )
            .overlay(
                PuzzlePieceShape(
                    top: piece.edges.top, right: piece.edges.right,
                    bottom: piece.edges.bottom, left: piece.edges.left
                )
                .stroke(Color.white.opacity(0.4), lineWidth: 1.2)
            )
            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            .onDrag {
                HapticService.shared.pieceLift()
                return NSItemProvider(object: "\(piece.id)" as NSString)
            }
    }
}
