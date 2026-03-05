import UIKit

class WalkingSteadinessChartView: UIView {

    private var points: [(date: Date, value: Double)] = []

    func configure(with data: [(date: Date, value: Double)]) {
        self.points = data
        setNeedsDisplay()
        animateIn()
    }

    override class var layerClass: AnyClass { CALayer.self }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func commonInit() {
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
    }

    // MARK: - Animation
    private var animationProgress: CGFloat = 1.0

    private func animateIn() {
        animationProgress = 0
        let displayLink = CADisplayLink(target: self, selector: #selector(animationStep))
        displayLink.add(to: .main, forMode: .common)
    }

    @objc private func animationStep(_ link: CADisplayLink) {
        animationProgress = min(animationProgress + 0.05, 1.0)
        if animationProgress >= 1.0 { link.invalidate() }
        setNeedsDisplay()
    }

    // MARK: - Layout constants
    private let pLeft:   CGFloat = 38
    private let pBottom: CGFloat = 30
    private let pTop:    CGFloat = 16
    private let pRight:  CGFloat = 16

    private func uw(_ r: CGRect) -> CGFloat { r.width  - pLeft - pRight  }
    private func uh(_ r: CGRect) -> CGFloat { r.height - pBottom - pTop  }

    private func pt(at i: Int, in rect: CGRect) -> CGPoint {
        let safe = max(points.count - 1, 1)
        let x = pLeft + CGFloat(i) / CGFloat(safe) * uw(rect)
        let y = rect.height - pBottom - CGFloat(points[i].value / 100.0) * uh(rect)
        return CGPoint(x: x, y: y)
    }

    // MARK: - draw

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.clear(rect)
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.fill(rect)

        if points.isEmpty {
            drawEmpty(ctx: ctx, rect: rect)
        } else {
            drawGrid(ctx: ctx, rect: rect)
            drawReferenceZones(ctx: ctx, rect: rect)
            drawGradientFill(rect: rect)
            drawSmoothLine(ctx: ctx, rect: rect)
            drawDots(ctx: ctx, rect: rect)
            drawYLabels(ctx: ctx, rect: rect)
            drawXLabels(ctx: ctx, rect: rect)
        }
        drawAxes(ctx: ctx, rect: rect)
    }

    // MARK: - Empty state (no emoji — clean text only)

    private func drawEmpty(ctx: CGContext, rect: CGRect) {
        // Dashed centre line
        ctx.setStrokeColor(UIColor.systemGray5.cgColor)
        ctx.setLineWidth(1)
        ctx.setLineDash(phase: 0, lengths: [6, 4])
        ctx.move(to: CGPoint(x: pLeft, y: rect.height / 2))
        ctx.addLine(to: CGPoint(x: rect.width - pRight, y: rect.height / 2))
        ctx.strokePath()
        ctx.setLineDash(phase: 0, lengths: [])

        // Primary message
        let title = "No walking data yet"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel,
        ]
        let titleSz = (title as NSString).size(withAttributes: titleAttrs)
        (title as NSString).draw(
            at: CGPoint(x: (rect.width - titleSz.width) / 2,
                        y: rect.height / 2 - titleSz.height - 4),
            withAttributes: titleAttrs
        )

        // Sub message
        let sub = "Walk with iPhone to collect data"
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .regular),
            .foregroundColor: UIColor.tertiaryLabel,
        ]
        let subSz = (sub as NSString).size(withAttributes: subAttrs)
        (sub as NSString).draw(
            at: CGPoint(x: (rect.width - subSz.width) / 2,
                        y: rect.height / 2 + 4),
            withAttributes: subAttrs
        )
    }

    // MARK: - Grid

    private func drawGrid(ctx: CGContext, rect: CGRect) {
        let steps = 4
        for i in 0...steps {
            let y = rect.height - pBottom - CGFloat(i) / CGFloat(steps) * uh(rect)
            ctx.setStrokeColor(UIColor.systemGray6.cgColor)
            ctx.setLineWidth(0.5)
            ctx.move(to: CGPoint(x: pLeft, y: y))
            ctx.addLine(to: CGPoint(x: rect.width - pRight, y: y))
            ctx.strokePath()
        }
    }

    // MARK: - Zone bands

    private func drawReferenceZones(ctx: CGContext, rect: CGRect) {
        let y100 = rect.height - pBottom - uh(rect)
        let y80  = rect.height - pBottom - CGFloat(80.0 / 100.0) * uh(rect)
        let y60  = rect.height - pBottom - CGFloat(60.0 / 100.0) * uh(rect)
        let y0   = rect.height - pBottom
        let w    = rect.width - pLeft - pRight

        ctx.setFillColor(UIColor.systemGreen.withAlphaComponent(0.04).cgColor)
        ctx.fill(CGRect(x: pLeft, y: y100, width: w, height: y80 - y100))
        ctx.setFillColor(UIColor.systemYellow.withAlphaComponent(0.04).cgColor)
        ctx.fill(CGRect(x: pLeft, y: y80, width: w, height: y60 - y80))
        ctx.setFillColor(UIColor.systemRed.withAlphaComponent(0.03).cgColor)
        ctx.fill(CGRect(x: pLeft, y: y60, width: w, height: y0 - y60))

        drawRefLine(at: 80, label: "Good",     color: .systemGreen,  ctx: ctx, rect: rect)
        drawRefLine(at: 60, label: "Moderate", color: .systemYellow, ctx: ctx, rect: rect)
    }

    private func drawRefLine(at value: Double, label: String, color: UIColor, ctx: CGContext, rect: CGRect) {
        let y = rect.height - pBottom - CGFloat(value / 100.0) * uh(rect)
        ctx.saveGState()
        ctx.setStrokeColor(color.withAlphaComponent(0.5).cgColor)
        ctx.setLineWidth(1)
        ctx.setLineDash(phase: 0, lengths: [5, 4])
        ctx.move(to: CGPoint(x: pLeft, y: y))
        ctx.addLine(to: CGPoint(x: rect.width - pRight, y: y))
        ctx.strokePath()
        ctx.setLineDash(phase: 0, lengths: [])
        ctx.restoreGState()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            .foregroundColor: color.withAlphaComponent(0.8),
        ]
        let sz = (label as NSString).size(withAttributes: attrs)
        (label as NSString).draw(
            at: CGPoint(x: rect.width - pRight - sz.width, y: y - sz.height - 2),
            withAttributes: attrs
        )
    }

    // MARK: - Gradient fill

    private func drawGradientFill(rect: CGRect) {
        guard points.count > 0, let ctx = UIGraphicsGetCurrentContext() else { return }
        let clipW = pLeft + uw(rect) * animationProgress
        ctx.saveGState()
        ctx.clip(to: CGRect(x: 0, y: 0, width: clipW, height: rect.height))

        let fillPath = UIBezierPath()
        fillPath.move(to: CGPoint(x: pt(at: 0, in: rect).x, y: rect.height - pBottom))
        if points.count > 1 {
            fillPath.addLine(to: pt(at: 0, in: rect))
            for i in 1..<points.count {
                let p = pt(at: i - 1, in: rect), c = pt(at: i, in: rect)
                fillPath.addCurve(to: c,
                    controlPoint1: CGPoint(x: p.x + (c.x - p.x) * 0.4, y: p.y),
                    controlPoint2: CGPoint(x: c.x - (c.x - p.x) * 0.4, y: c.y))
            }
        } else {
            fillPath.addLine(to: pt(at: 0, in: rect))
        }
        fillPath.addLine(to: CGPoint(x: pt(at: points.count - 1, in: rect).x, y: rect.height - pBottom))
        fillPath.close()
        fillPath.addClip()

        let colors = [UIColor.systemOrange.withAlphaComponent(0.22).cgColor,
                      UIColor.systemOrange.withAlphaComponent(0.0).cgColor] as CFArray
        let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
        ctx.drawLinearGradient(grad,
            start: CGPoint(x: rect.midX, y: pTop),
            end:   CGPoint(x: rect.midX, y: rect.height - pBottom), options: [])
        ctx.restoreGState()
    }

    // MARK: - Line

    private func drawSmoothLine(ctx: CGContext, rect: CGRect) {
        guard points.count > 0 else { return }
        let clipW = pLeft + uw(rect) * animationProgress
        ctx.saveGState()
        ctx.clip(to: CGRect(x: 0, y: 0, width: clipW, height: rect.height))
        ctx.setStrokeColor(UIColor.systemOrange.cgColor)
        ctx.setLineWidth(2.5); ctx.setLineJoin(.round); ctx.setLineCap(.round)

        if points.count == 1 {
            let p = pt(at: 0, in: rect)
            ctx.move(to: CGPoint(x: pLeft, y: p.y))
            ctx.addLine(to: CGPoint(x: rect.width - pRight, y: p.y))
        } else {
            ctx.move(to: pt(at: 0, in: rect))
            for i in 1..<points.count {
                let p = pt(at: i - 1, in: rect), c = pt(at: i, in: rect)
                ctx.addCurve(to: c,
                    control1: CGPoint(x: p.x + (c.x - p.x) * 0.4, y: p.y),
                    control2: CGPoint(x: c.x - (c.x - p.x) * 0.4, y: c.y))
            }
        }
        ctx.strokePath()
        ctx.restoreGState()
    }

    // MARK: - Dots

    private func drawDots(ctx: CGContext, rect: CGRect) {
        let radius: CGFloat = points.count > 14 ? 3 : 5
        let animatedCount = Int(ceil(Double(points.count) * Double(animationProgress)))
        for i in 0..<animatedCount {
            let p = pt(at: i, in: rect)
            let v = points[i].value
            let dotColor: UIColor = .systemOrange
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.addEllipse(in: CGRect(x: p.x - radius - 2, y: p.y - radius - 2,
                                      width: (radius + 2) * 2, height: (radius + 2) * 2))
            ctx.fillPath()
            ctx.setFillColor(dotColor.cgColor)
            ctx.addEllipse(in: CGRect(x: p.x - radius, y: p.y - radius,
                                      width: radius * 2, height: radius * 2))
            ctx.fillPath()
        }
    }

    // MARK: - Y Labels

    private func drawYLabels(ctx: CGContext, rect: CGRect) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedDigitSystemFont(ofSize: 9, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel,
        ]
        for v in [0, 25, 50, 75, 100] {
            let y    = rect.height - pBottom - CGFloat(v) / 100.0 * uh(rect)
            let text = "\(v)" as NSString
            let sz   = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: pLeft - sz.width - 5, y: y - sz.height / 2),
                      withAttributes: attrs)
        }
        let unitAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor.tertiaryLabel,
        ]
        ("%" as NSString).draw(at: CGPoint(x: 2, y: pTop - 4), withAttributes: unitAttrs)
    }

    // MARK: - X Labels

    private func drawXLabels(ctx: CGContext, rect: CGRect) {
        guard points.count > 1 else { return }
        let f = DateFormatter()
        f.dateFormat = points.count > 20 ? "MMM" : "d MMM"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.secondaryLabel,
        ]
        let count = min(5, points.count)
        for i in 0..<count {
            let idx  = i * (points.count - 1) / max(count - 1, 1)
            let p    = pt(at: idx, in: rect)
            let text = f.string(from: points[idx].date) as NSString
            let sz   = text.size(withAttributes: attrs)
            let x    = min(max(p.x - sz.width / 2, pLeft), rect.width - pRight - sz.width)
            text.draw(at: CGPoint(x: x, y: rect.height - pBottom + 6), withAttributes: attrs)
        }
    }

    // MARK: - Axes

    private func drawAxes(ctx: CGContext, rect: CGRect) {
        ctx.setStrokeColor(UIColor.systemGray4.cgColor)
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: pLeft, y: rect.height - pBottom))
        ctx.addLine(to: CGPoint(x: rect.width - pRight, y: rect.height - pBottom))
        ctx.move(to: CGPoint(x: pLeft, y: pTop))
        ctx.addLine(to: CGPoint(x: pLeft, y: rect.height - pBottom))
        ctx.strokePath()
    }
}
