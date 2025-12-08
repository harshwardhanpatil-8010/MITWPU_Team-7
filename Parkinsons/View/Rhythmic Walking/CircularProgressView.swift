import UIKit

final class CircularProgressView: UIView {
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        let circularPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: bounds.width/2,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.systemGray4.cgColor
        trackLayer.lineWidth = 20
        trackLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.systemGreen.cgColor
        progressLayer.lineWidth = 20
        progressLayer.lineCap = .round
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = 1
        layer.addSublayer(progressLayer)
    }
    
    private var centerPoint: CGPoint {
        CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    /// Update progress (0 to 1)
    func setProgress(_ progress: CGFloat) {
        progressLayer.strokeEnd = progress
    }
}

