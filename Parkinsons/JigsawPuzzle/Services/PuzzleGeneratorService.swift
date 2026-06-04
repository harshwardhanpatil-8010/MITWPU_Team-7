
import UIKit

enum PuzzleGeneratorService {

    static func generateSourceImage(difficulty: GameDifficulty, date: Date? = nil) -> UIImage {
        let d = date ?? Date()
        let emoji = PuzzleConstants.emoji(for: d)
        return makeEmojiImage(emoji: emoji, size: CGSize(width: 600, height: 600))
    }

    static func generatePieces(difficulty: GameDifficulty, image: UIImage) -> [PuzzlePiece] {
        let size  = difficulty.gridSize
        let total = size * size
        
        let tiles = ImageSlicingService.sliceImage(image, rows: size, columns: size)
        guard tiles.count == total else { return [] }

        var hEdges = [[EdgeType]](repeating: [EdgeType](repeating: .flat, count: size), count: size-1)
        var vEdges = [[EdgeType]](repeating: [EdgeType](repeating: .flat, count: size-1), count: size)
        for r in 0..<(size-1) { for c in 0..<size    { hEdges[r][c] = Bool.random() ? .tab : .blank } }
        for r in 0..<size     { for c in 0..<(size-1) { vEdges[r][c] = Bool.random() ? .tab : .blank } }

        return (0..<total).map { idx in
            let r = idx / size, c = idx % size
            let top:    EdgeType = r == 0      ? .flat : hEdges[r-1][c].opposite
            let bottom: EdgeType = r == size-1 ? .flat : hEdges[r][c]
            let left:   EdgeType = c == 0      ? .flat : vEdges[r][c-1].opposite
            let right:  EdgeType = c == size-1 ? .flat : vEdges[r][c]
            return PuzzlePiece(id: idx, correctRow: r, correctColumn: c,
                               correctIndex: idx, currentIndex: idx,
                               image: tiles[idx],
                               edges: PieceEdges(top: top, right: right, bottom: bottom, left: left))
        }
    }

    static func shufflePieces(_ pieces: [PuzzlePiece]) -> [PuzzlePiece] {
        guard pieces.count > 1 else { return pieces }
        var arr = pieces; var attempts = 0
        repeat { arr.shuffle(); attempts += 1 }
        while arr.enumerated().allSatisfy({ $0.element.correctIndex == $0.offset }) && attempts < 5
        return arr.enumerated().map { idx, p in
            PuzzlePiece(id: p.id, correctRow: p.correctRow, correctColumn: p.correctColumn,
                        correctIndex: p.correctIndex, currentIndex: idx,
                        image: p.image, edges: p.edges)
        }
    }



    static func makeEmojiImage(emoji: String, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let c = ctx.cgContext
            
            let colors = [
                UIColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 1.0).cgColor,
                UIColor(red: 0.98, green: 0.88, blue: 0.75, alpha: 1.0).cgColor
            ] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: colors,
                                      locations: [0, 1])!
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = max(size.width, size.height)
            c.drawRadialGradient(gradient,
                                 startCenter: center, startRadius: 0,
                                 endCenter: center, endRadius: radius,
                                 options: .drawsAfterEndLocation)
            
            let fontSize = size.width * 0.6
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize)
            ]
            let str = NSAttributedString(string: emoji, attributes: attrs)
            let strSize = str.size()
            let origin = CGPoint(
                x: center.x - strSize.width / 2,
                y: center.y - strSize.height / 2
            )
            str.draw(at: origin)
        }
    }
}
