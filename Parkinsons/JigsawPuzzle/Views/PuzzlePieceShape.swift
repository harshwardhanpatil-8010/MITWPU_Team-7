// MARK: - PuzzlePieceShape.swift
// Custom SwiftUI Shape that draws a jigsaw piece with tab/blank bezier curves.

import SwiftUI

struct PuzzlePieceShape: Shape {
    let top: EdgeType; let right: EdgeType; let bottom: EdgeType; let left: EdgeType
    let bleed: CGFloat = 0.25 // Matches ImageSlicingService default

    func path(in rect: CGRect) -> Path {
        var p = Path()
        
        // The logical tile dimensions
        let w = rect.width / (1.0 + 2.0 * bleed)
        let h = rect.height / (1.0 + 2.0 * bleed)
        
        // Origin of the core tile within the bleed-inclusive rect
        let x = rect.minX + w * bleed
        let y = rect.minY + h * bleed
        
        p.move(to: CGPoint(x: x, y: y))
        
        // Edges reach out into the bleed area (h * 0.22 < h * 0.25 bleed)
        addEdge(&p, ax: x, ay: y, bx: x+w, by: y, type: top, dx: 0, dy: -h*0.22)
        addEdge(&p, ax: x+w, ay: y, bx: x+w, by: y+h, type: right, dx: w*0.22, dy: 0)
        addEdge(&p, ax: x+w, ay: y+h, bx: x, by: y+h, type: bottom, dx: 0, dy: h*0.22)
        addEdge(&p, ax: x, ay: y+h, bx: x, by: y, type: left, dx: -w*0.22, dy: 0)
        
        p.closeSubpath()
        return p
    }

    private func addEdge(_ p: inout Path, ax: CGFloat, ay: CGFloat,
                          bx: CGFloat, by: CGFloat, type: EdgeType,
                          dx: CGFloat, dy: CGFloat) {
        guard type != .flat else { p.addLine(to: CGPoint(x: bx, y: by)); return }
        
        let s: CGFloat = type == .tab ? 1 : -1
        let odx = dx * s, ody = dy * s
        let mx = (ax+bx)/2, my = (ay+by)/2
        
        // Classic bulb shape math
        let neck: CGFloat = 0.25
        let t0x = ax + (bx-ax)*(0.5 - neck), t0y = ay + (by-ay)*(0.5 - neck)
        let t1x = ax + (bx-ax)*(0.5 + neck), t1y = ay + (by-ay)*(0.5 + neck)
        
        let tip = CGPoint(x: mx+odx, y: my+ody)
        
        p.addLine(to: CGPoint(x: t0x, y: t0y))
        
        // First half of the bulb
        p.addCurve(to: tip,
                   control1: CGPoint(x: t0x + odx * 0.5, y: t0y + ody * 0.5),
                   control2: CGPoint(x: tip.x - (bx-ax)*0.2, y: tip.y - (by-ay)*0.2))
        
        // Second half of the bulb
        p.addCurve(to: CGPoint(x: t1x, y: t1y),
                   control1: CGPoint(x: tip.x + (bx-ax)*0.2, y: tip.y + (by-ay)*0.2),
                   control2: CGPoint(x: t1x + odx * 0.5, y: t1y + ody * 0.5))
        
        p.addLine(to: CGPoint(x: bx, y: by))
    }
}
