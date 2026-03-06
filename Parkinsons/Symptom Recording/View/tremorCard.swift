import UIKit

class tremorCard: UICollectionViewCell {

    private var pendingPoints: [AggregatedTremorPoint] = []
    private var pendingHz: Double? = nil

    // MARK: - IBOutlets (XIB only)
    @IBOutlet weak var cardBackground: UIView!
    @IBOutlet weak var cardGraphView: UIView!   // 139 × 68 pt
    @IBOutlet weak var tremorValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        setupCardStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardGraphView.backgroundColor = .clear
        DispatchQueue.main.async { self.drawMiniGraph() }
    }

    // MARK: - Card Style

    private func setupCardStyle() {
        cardBackground.layer.cornerRadius = 20
        cardBackground.layer.masksToBounds = false
        cardBackground.layer.shadowColor   = UIColor.black.cgColor
        cardBackground.layer.shadowOpacity = 0.12
        cardBackground.layer.shadowRadius  = 8
        cardBackground.layer.shadowOffset  = CGSize(width: 0, height: 3)
    }

    // MARK: - Configure

    func configure(frequencyHz: Double?, isSteady: Bool = false, graphPoints: [AggregatedTremorPoint]) {
        pendingPoints = graphPoints
        pendingHz     = frequencyHz
        setNeedsLayout()

        if isSteady {
            // ✅ Steady = measured, no tremor
            tremorValueLabel.text      = "Steady"
            tremorValueLabel.textColor = .black
        } else if let hz = frequencyHz {
            tremorValueLabel.text = String(format: "%.1f Hz", hz)
            if hz < 4.0      { tremorValueLabel.textColor = .black }
            else if hz < 6.0 { tremorValueLabel.textColor = .black }
            else              { tremorValueLabel.textColor = .black    }
        } else {
            // nil = not yet measured (recording in progress)
            tremorValueLabel.text      = "Measuring…"
            tremorValueLabel.textColor = .secondaryLabel
        }
    }

    // MARK: - Mini Graph
    // View is 139 × 68 pt.
    // Left pad = 22 pt for Y labels ("0"/"7")
    // Bottom pad = 14 pt for X labels (time)
    // Top/right pad = 4 pt

    private func drawMiniGraph() {
        cardGraphView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        cardGraphView.backgroundColor = .clear

        let W = cardGraphView.bounds.width
        let H = cardGraphView.bounds.height
        guard W > 0, H > 0 else { return }

        // Padding — leaves room for axis labels
        let pL: CGFloat = 22   // Y label column
        let pB: CGFloat = 14   // X label row
        let pT: CGFloat = 4
        let pR: CGFloat = 4
        let uw = W - pL - pR
        let uh = H - pB - pT

        let pts   = pendingPoints
        let maxHz = max(pts.map { $0.avgHz }.max() ?? 6, 6)
        let minHz: Double = 0
        let safe  = max(pts.count - 1, 1)

        func coord(_ i: Int) -> CGPoint {
            let x = pL + CGFloat(i) / CGFloat(safe) * uw
            let y = H - pB - CGFloat((pts[i].avgHz - minHz) / (maxHz - minHz)) * uh
            return CGPoint(x: x, y: y)
        }

        // ── Y axis labels: max and 0 ──────────────────────────────
        addTextLayer(String(format: "%.0f", maxHz),
                     frame: CGRect(x: 0, y: pT - 1, width: pL - 3, height: 10),
                     alignment: .right, color: .tertiaryLabel)

        addTextLayer("0",
                     frame: CGRect(x: 0, y: H - pB - 8, width: pL - 3, height: 10),
                     alignment: .right, color: .tertiaryLabel)

        // ── Y axis line ────────────────────────────────────────────
        addLine(from: CGPoint(x: pL, y: pT), to: CGPoint(x: pL, y: H - pB),
                color: UIColor.systemGray5.cgColor, width: 0.5)

        // ── X axis line + labels ───────────────────────────────────
        addLine(from: CGPoint(x: pL, y: H - pB), to: CGPoint(x: W - pR, y: H - pB),
                color: UIColor.systemGray5.cgColor, width: 0.5)

        if pts.count >= 2 {
            let fmt = DateFormatter()
            fmt.dateFormat = "HH:mm"

            // First and last timestamps
            let x0 = pL
            let x1 = pL + uw
            addTextLayer(fmt.string(from: pts.first!.date),
                         frame: CGRect(x: x0, y: H - pB + 2, width: 30, height: 10),
                         alignment: .left, color: .tertiaryLabel)
            addTextLayer(fmt.string(from: pts.last!.date),
                         frame: CGRect(x: x1 - 30, y: H - pB + 2, width: 30, height: 10),
                         alignment: .right, color: .tertiaryLabel)
        }

        // ── No data state ─────────────────────────────────────────
        guard pts.count > 0 else {
            addLine(from: CGPoint(x: pL, y: H - pB - uh / 2),
                    to:   CGPoint(x: W - pR, y: H - pB - uh / 2),
                    color: UIColor.systemGray4.cgColor, width: 1,
                    dash: [3, 3])
            return
        }

        // Single reading — draw a centred dot + dashed horizontal
        if pts.count == 1 {
            let ny  = CGFloat((pts[0].avgHz - minHz) / (maxHz - minHz))
            let y   = H - pB - ny * uh
            let cx  = pL + uw / 2   // ← centre of usable width

            addLine(from: CGPoint(x: pL, y: y), to: CGPoint(x: W - pR, y: y),
                    color: UIColor.systemOrange.withAlphaComponent(0.3).cgColor, width: 1, dash: [3, 3])

            let ring = CAShapeLayer()
            ring.path = UIBezierPath(arcCenter: CGPoint(x: cx, y: y), radius: 4, startAngle: 0, endAngle: .pi*2, clockwise: true).cgPath
            ring.fillColor = UIColor.white.cgColor
            cardGraphView.layer.addSublayer(ring)

            let dot = CAShapeLayer()
            dot.path = UIBezierPath(arcCenter: CGPoint(x: cx, y: y), radius: 2.5, startAngle: 0, endAngle: .pi*2, clockwise: true).cgPath
            dot.fillColor = UIColor.systemOrange.cgColor
            cardGraphView.layer.addSublayer(dot)
            return
        }

        // ── Gradient fill ─────────────────────────────────────────
        if pts.count > 1 {
            let fillPath = UIBezierPath()
            fillPath.move(to: CGPoint(x: coord(0).x, y: H - pB))
            fillPath.addLine(to: coord(0))
            for i in 1..<pts.count {
                let p = coord(i - 1), c = coord(i)
                let cp1 = CGPoint(x: p.x + (c.x - p.x) * 0.4, y: p.y)
                let cp2 = CGPoint(x: c.x - (c.x - p.x) * 0.4, y: c.y)
                fillPath.addCurve(to: c, controlPoint1: cp1, controlPoint2: cp2)
            }
            fillPath.addLine(to: CGPoint(x: coord(pts.count - 1).x, y: H - pB))
            fillPath.close()

            let grad = CAGradientLayer()
            grad.frame  = cardGraphView.bounds
            grad.colors = [UIColor.systemOrange.withAlphaComponent(0.20).cgColor,
                           UIColor.systemOrange.withAlphaComponent(0.0).cgColor]
            grad.startPoint = CGPoint(x: 0.5, y: 0)
            grad.endPoint   = CGPoint(x: 0.5, y: 1)
            let mask = CAShapeLayer(); mask.path = fillPath.cgPath
            grad.mask = mask
            cardGraphView.layer.addSublayer(grad)
        }

        // ── Line ──────────────────────────────────────────────────
        if pts.count > 1 {
            let lp = UIBezierPath()
            lp.move(to: coord(0))
            for i in 1..<pts.count {
                let p = coord(i - 1), c = coord(i)
                let cp1 = CGPoint(x: p.x + (c.x - p.x) * 0.4, y: p.y)
                let cp2 = CGPoint(x: c.x - (c.x - p.x) * 0.4, y: c.y)
                lp.addCurve(to: c, controlPoint1: cp1, controlPoint2: cp2)
            }
            let ll = CAShapeLayer()
            ll.path        = lp.cgPath
            ll.strokeColor = UIColor.systemOrange.cgColor
            ll.fillColor   = UIColor.clear.cgColor
            ll.lineWidth   = 1.5
            ll.lineJoin    = .round; ll.lineCap = .round
            cardGraphView.layer.addSublayer(ll)
        }

        // ── Dots ──────────────────────────────────────────────────
        let dotR: CGFloat = pts.count > 8 ? 1.5 : 2.5
        for i in 0..<pts.count {
            let p   = coord(i)
            let col = UIColor.systemOrange

            let ring = CAShapeLayer()
            ring.path      = UIBezierPath(arcCenter: p, radius: dotR + 2, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
            ring.fillColor = UIColor.white.cgColor
            cardGraphView.layer.addSublayer(ring)

            let dot = CAShapeLayer()
            dot.path      = UIBezierPath(arcCenter: p, radius: dotR, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
            dot.fillColor = col.cgColor
            cardGraphView.layer.addSublayer(dot)
        }
    }

    // MARK: - Layer helpers

    private func addTextLayer(_ text: String, frame: CGRect, alignment: CATextLayerAlignmentMode, color: UIColor) {
        let l = CATextLayer()
        l.string         = text
        l.fontSize       = 7
        l.foregroundColor = color.cgColor
        l.frame          = frame
        l.alignmentMode  = alignment
        l.contentsScale  = UIScreen.main.scale
        cardGraphView.layer.addSublayer(l)
    }

    private func addLine(from: CGPoint, to: CGPoint, color: CGColor, width: CGFloat, dash: [NSNumber]? = nil) {
        let path = UIBezierPath()
        path.move(to: from); path.addLine(to: to)
        let l = CAShapeLayer()
        l.path        = path.cgPath
        l.strokeColor = color
        l.lineWidth   = width
        if let d = dash { l.lineDashPattern = d }
        cardGraphView.layer.addSublayer(l)
    }
}
