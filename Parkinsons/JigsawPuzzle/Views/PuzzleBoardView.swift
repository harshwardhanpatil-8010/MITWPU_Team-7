// MARK: - PuzzleBoardView.swift
// Grid board: shows assembled puzzle during memorize, empty slots + placed pieces after shuffle.
// Fixed: explicit white background, pieces clipped inside board bounds.

import SwiftUI
import UniformTypeIdentifiers

struct PuzzleBoardView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @State private var hoveredSlot: Int? = nil

    var body: some View {
        GeometryReader { geo in
            let boardSize = min(geo.size.width, geo.size.height)
            let gs = viewModel.gridSize
            let ps = boardSize / CGFloat(gs)

            ZStack(alignment: .topLeading) {

                // ── Board background: always pure white ───────────────
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color(UIColor.separator).opacity(0.4), lineWidth: 1)
                    )

                // ── Slot grid ─────────────────────────────────────────
                ForEach(0..<gs, id: \.self) { row in
                    ForEach(0..<gs, id: \.self) { col in
                        let slotIdx    = row * gs + col
                        let isOccupied = viewModel.boardSlots[slotIdx] != nil
                        let isHovered  = hoveredSlot == slotIdx

                        ZStack {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(
                                    isHovered
                                        ? Color(UIColor(hex: "BF5AF2")).opacity(0.12)
                                        : isOccupied
                                            ? Color.clear
                                            : Color(UIColor.systemGray6)
                                )

                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .strokeBorder(
                                    isHovered
                                        ? Color(UIColor(hex: "BF5AF2")).opacity(0.7)
                                        : isOccupied
                                            ? Color.clear
                                            : Color(UIColor.separator).opacity(0.5),
                                    lineWidth: isHovered ? 2 : 1
                                )

                            if !isOccupied && !isHovered {
                                Text("\(slotIdx + 1)")
                                    .font(.system(size: 9, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(UIColor.tertiaryLabel))
                            }
                        }
                        .frame(width: ps - 2, height: ps - 2)
                        .offset(x: CGFloat(col) * ps + 1, y: CGFloat(row) * ps + 1)
                        .animation(.easeInOut(duration: 0.12), value: isHovered)
                    }
                }

                // ── Placed pieces (clipped to board) ──────────────────
                ForEach(viewModel.placedPositions.keys.sorted(), id: \.self) { pid in
                    if let piece = viewModel.piece(for: pid),
                       let pos   = viewModel.placedPositions[pid] {

                        Image(uiImage: piece.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: ps * 1.5, height: ps * 1.5)
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
                                .stroke(Color.white.opacity(0.6), lineWidth: 1.2)
                            )
                            .shadow(color: .black.opacity(0.10), radius: 3, x: 0, y: 1)
                            .offset(x: pos.x - ps * 0.25, y: pos.y - ps * 0.25)
                            .onDrag {
                                HapticService.shared.pieceLift()
                                return NSItemProvider(object: "\(piece.id)" as NSString)
                            }
                            .transition(.scale(scale: 0.75).combined(with: .opacity))
                    }
                }

                // ── Memorize overlay ──────────────────────────────────
                if viewModel.isMemorizing {
                    memorizeOverlay(ps: ps)
                        .transition(.opacity)
                }
            }
            .frame(width: boardSize, height: boardSize)
            // CRITICAL: clip so no piece image bleeds outside the white card
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .onDrop(
                of: [.text],
                delegate: BoardDropDelegate(vm: viewModel, boardSize: boardSize, hoveredSlot: $hoveredSlot)
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private func memorizeOverlay(ps: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // White semi-opaque wash so the image shows clearly
            Color.white.opacity(0.15)

            ForEach(viewModel.allPieces) { piece in
                Image(uiImage: piece.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: ps * 1.5, height: ps * 1.5)
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
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .offset(
                        x: CGFloat(piece.correctColumn) * ps - ps * 0.25,
                        y: CGFloat(piece.correctRow)    * ps - ps * 0.25
                    )
            }
        }
    }
}

// MARK: - Drop Delegate

private struct BoardDropDelegate: DropDelegate {
    let vm: PuzzleViewModel
    let boardSize: CGFloat
    @Binding var hoveredSlot: Int?

    private func slotIndex(at location: CGPoint) -> Int {
        let ps  = boardSize / CGFloat(vm.gridSize)
        let col = max(0, min(vm.gridSize - 1, Int(location.x / ps)))
        let row = max(0, min(vm.gridSize - 1, Int(location.y / ps)))
        return row * vm.gridSize + col
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        hoveredSlot = slotIndex(at: info.location)
        return DropProposal(operation: .move)
    }

    func dropExited(info: DropInfo) {
        hoveredSlot = nil
    }

    func performDrop(info: DropInfo) -> Bool {
        hoveredSlot = nil
        guard let provider = info.itemProviders(for: [.text]).first else { return false }

        let location = info.location
        provider.loadObject(ofClass: NSString.self) { obj, _ in
            DispatchQueue.main.async {
                guard let s = obj as? String, let pid = Int(s) else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    let ps = boardSize / CGFloat(vm.gridSize)
                    let adjustedPos = CGPoint(x: location.x - ps / 2, y: location.y - ps / 2)
                    vm.placePiece(pieceID: pid, at: adjustedPos, boardSize: boardSize)
                }
            }
        }
        return true
    }
}
