import UIKit

class gaitCard: UICollectionViewCell {

    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var cardBackground: UIView!
    @IBOutlet weak var walkingSteadinessView: UIView!

    private var graphPoints: [(date: Date, value: Double)] = []


    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        setupCardStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        walkingSteadinessView.backgroundColor = .clear
        DispatchQueue.main.async { self.redrawGraph() }
    }


    private func setupCardStyle() {
        cardBackground.layer.cornerRadius = 20
        cardBackground.layer.masksToBounds = false
        cardBackground.layer.shadowColor   = UIColor.black.cgColor
        cardBackground.layer.shadowOpacity = 0.12
        cardBackground.layer.shadowRadius  = 8
        cardBackground.layer.shadowOffset  = CGSize(width: 0, height: 3)
    }


    func configure(range: String) {
        configureWithPoints(range: range, points: [])
    }

    func configureWithPoints(range: String, points: [(date: Date, value: Double)]) {
        self.graphPoints = points

        if let value = parseDouble(from: range) {
            rangeLabel.text      = String(format: "%.0f", value)
            unitLabel.text       = "/ 100"
            rangeLabel.textColor = .black
        } else {
            rangeLabel.text      = range
            rangeLabel.textColor = .black
            unitLabel.text       = ""
        }
        setNeedsLayout()
    }

    private func parseDouble(from text: String) -> Double? {
        let s = text.components(separatedBy: "/").first?.trimmingCharacters(in: .whitespaces) ?? text
        return Double(s)
    }

    private func colorFor(_ v: Double) -> UIColor {
        if v >= 80 { return .systemGreen  }
        if v >= 60 { return .systemOrange }
        return .systemRed
    }


    private func redrawGraph() {
        walkingSteadinessView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        walkingSteadinessView.backgroundColor = .clear

        let W = walkingSteadinessView.bounds.width
        let H = walkingSteadinessView.bounds.height
        guard W > 0, H > 0 else { return }

        let pL: CGFloat = 22
        let pB: CGFloat = 14
        let pT: CGFloat = 4
        let pR: CGFloat = 4
        let uw = W - pL - pR
        let uh = H - pB - pT

        let pts = graphPoints
        let safe = max(pts.count - 1, 1)

        func coord(_ i: Int) -> CGPoint {
            let x = pL + CGFloat(i) / CGFloat(safe) * uw
            let y = H - pB - CGFloat(pts[i].value / 100.0) * uh
            return CGPoint(x: x, y: y)
        }

        addText("100", frame: CGRect(x: 0, y: pT - 1, width: pL - 3, height: 10),
                align: .right, color: .tertiaryLabel)
        addText("0",   frame: CGRect(x: 0, y: H - pB - 8, width: pL - 3, height: 10),
                align: .right, color: .tertiaryLabel)

        addLine(from: CGPoint(x: pL, y: pT),      to: CGPoint(x: pL, y: H - pB),
                color: UIColor.systemGray5.cgColor, w: 0.5)
        addLine(from: CGPoint(x: pL, y: H - pB),  to: CGPoint(x: W - pR, y: H - pB),
                color: UIColor.systemGray5.cgColor, w: 0.5)
        if pts.count >= 2 {
            let fmt = DateFormatter()
            let span = pts.last!.date.timeIntervalSince(pts.first!.date)
            fmt.dateFormat = span < 86400 ? "HH:mm" : "d MMM"

            addText(fmt.string(from: pts.first!.date),
                    frame: CGRect(x: pL, y: H - pB + 2, width: 30, height: 10),
                    align: .left, color: .tertiaryLabel)
            addText(fmt.string(from: pts.last!.date),
                    frame: CGRect(x: W - pR - 30, y: H - pB + 2, width: 30, height: 10),
                    align: .right, color: .tertiaryLabel)
        }

        guard pts.count > 0 else {
            addLine(from: CGPoint(x: pL,     y: H - pB - uh / 2),
                    to:   CGPoint(x: W - pR, y: H - pB - uh / 2),
                    color: UIColor.systemGray4.cgColor, w: 1, dash: [3, 3])
            return
        }

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
            grad.frame  = walkingSteadinessView.bounds
            grad.colors = [UIColor.systemOrange.withAlphaComponent(0.20).cgColor,
                           UIColor.systemOrange.withAlphaComponent(0.0).cgColor]
            grad.startPoint = CGPoint(x: 0.5, y: 0)
            grad.endPoint   = CGPoint(x: 0.5, y: 1)
            let mask = CAShapeLayer(); mask.path = fillPath.cgPath
            grad.mask = mask
            walkingSteadinessView.layer.addSublayer(grad)
        }

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
            walkingSteadinessView.layer.addSublayer(ll)
        }

        let dotR: CGFloat = pts.count > 8 ? 1.5 : 2.5
        for i in 0..<pts.count {
            let p   = coord(i)
            let val = pts[i].value
            let col: UIColor = .systemOrange

            let ring = CAShapeLayer()
            ring.path      = UIBezierPath(arcCenter: p, radius: dotR + 2, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
            ring.fillColor = UIColor.white.cgColor
            walkingSteadinessView.layer.addSublayer(ring)

            let dot = CAShapeLayer()
            dot.path      = UIBezierPath(arcCenter: p, radius: dotR, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
            dot.fillColor = col.cgColor
            walkingSteadinessView.layer.addSublayer(dot)
        }
    }

    private func addText(_ text: String, frame: CGRect, align: CATextLayerAlignmentMode, color: UIColor) {
        let l = CATextLayer()
        l.string          = text
        l.fontSize        = 7
        l.foregroundColor = color.cgColor
        l.frame           = frame
        l.alignmentMode   = align
        l.contentsScale   = UIScreen.main.scale
        walkingSteadinessView.layer.addSublayer(l)
    }

    private func addLine(from: CGPoint, to: CGPoint, color: CGColor, w: CGFloat, dash: [NSNumber]? = nil) {
        let path = UIBezierPath(); path.move(to: from); path.addLine(to: to)
        let l = CAShapeLayer()
        l.path        = path.cgPath
        l.strokeColor = color
        l.lineWidth   = w
        if let d = dash { l.lineDashPattern = d }
        walkingSteadinessView.layer.addSublayer(l)
    }
}
