import UIKit

class tremorCard: UICollectionViewCell {
    private var pendingPoints: [AggregatedTremorPoint] = []
    @IBOutlet weak var cardBackground: UIView!
    
    @IBOutlet weak var cardGraphView: UIView!
    @IBOutlet weak var tremorValueLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        setupCardStyle()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        drawMiniGraph(points: pendingPoints)
    }

    
    func setupCardStyle() {
        let cornerRadius: CGFloat = 25
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.15
        let shadowRadius: CGFloat = 3
        let shadowOffset: CGSize = .init(width: 0, height: 1)

        cardBackground.layer.cornerRadius = cornerRadius
        cardBackground.layer.masksToBounds = false

        cardBackground.layer.shadowColor = shadowColor.cgColor
        cardBackground.layer.shadowOpacity = shadowOpacity
        cardBackground.layer.shadowRadius = shadowRadius
        cardBackground.layer.shadowOffset = shadowOffset
    }
    func configure(
        frequencyHz: Double?,
        graphPoints: [AggregatedTremorPoint]
    ) {
        pendingPoints = graphPoints

        if let hz = frequencyHz, hz > 0 {
            tremorValueLabel.text = String(format: "%.1f Hz", hz)
        } else {
            tremorValueLabel.text = "Steady"
        }
    }

    private func drawMiniGraph(points: [AggregatedTremorPoint]) {

        cardGraphView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        guard points.count > 1 else { return }

        let width = cardGraphView.bounds.width
        let height = cardGraphView.bounds.height
        let padding: CGFloat = 8

        let usableWidth = width - 2 * padding
        let usableHeight = height - 2 * padding

        let minHz: Double = 0
        let maxHz = max(points.map { $0.avgHz }.max() ?? 6, 6)

        let safeCount = max(points.count - 1, 1)

        let path = UIBezierPath()

        for (i, point) in points.enumerated() {

            let x = padding + CGFloat(i) / CGFloat(safeCount) * usableWidth
            let y = height - padding -
                CGFloat((point.avgHz - minHz) / (maxHz - minHz)) * usableHeight

            let p = CGPoint(x: x, y: y)

            i == 0 ? path.move(to: p) : path.addLine(to: p)
        }

        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.systemBlue.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 1.5
        lineLayer.lineJoin = .round
        lineLayer.lineCap = .round

        cardGraphView.layer.addSublayer(lineLayer)
    }


   
}
