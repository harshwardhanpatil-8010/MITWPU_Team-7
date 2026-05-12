// MARK: - PuzzlePiece.swift

import UIKit

enum EdgeType: Int, Codable {
    case flat, tab, blank
    var opposite: EdgeType {
        switch self { case .flat: return .flat; case .tab: return .blank; case .blank: return .tab }
    }
}

struct PieceEdges {
    let top: EdgeType; let right: EdgeType; let bottom: EdgeType; let left: EdgeType
}

struct PuzzlePiece: Identifiable, Equatable {
    let id: Int
    let correctRow: Int; let correctColumn: Int; let correctIndex: Int
    var currentIndex: Int
    let image: UIImage
    let edges: PieceEdges
    var isPlacedCorrectly: Bool { currentIndex == correctIndex }
    static func == (lhs: PuzzlePiece, rhs: PuzzlePiece) -> Bool { lhs.id == rhs.id }
}
