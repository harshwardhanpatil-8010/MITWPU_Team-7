import UIKit

 class CircularProgressView: UIView {
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    var trackColor: UIColor = .systemGray4 {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }
    
    var progressColor: UIColor = .systemGreen {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }
    
    var lineWidth: CGFloat = 20 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
        }
    }
     var trackOpacity: Float = 1.0 {
         didSet {
             trackLayer.opacity = trackOpacity
         }
     }

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
             radius: bounds.width / 2,
             startAngle: -.pi / 2,
             endAngle: 3 * .pi / 2,
             clockwise: true
         )

         trackLayer.path = circularPath.cgPath
         trackLayer.strokeColor = trackColor.cgColor
         trackLayer.lineWidth = lineWidth
         trackLayer.fillColor = UIColor.clear.cgColor
         trackLayer.opacity = 0.5
         layer.addSublayer(trackLayer)

         progressLayer.path = circularPath.cgPath
         progressLayer.strokeColor = progressColor.cgColor
         progressLayer.lineWidth = lineWidth
         progressLayer.lineCap = .round
         progressLayer.fillColor = UIColor.clear.cgColor
         progressLayer.strokeEnd = 0
         layer.addSublayer(progressLayer)
     }




    
    private var centerPoint: CGPoint {
        CGPoint(x: bounds.midX, y: bounds.midY)
    }
     
     func setProgress(_ progress: CGFloat) {
         progressLayer.strokeEnd = min(max(progress, 0), 1)
     }

     
     override func layoutSubviews() {
         super.layoutSubviews()
         updatePath()
     }

     private func updatePath() {
         let circularPath = UIBezierPath(
             arcCenter: centerPoint,
             radius: min(bounds.width, bounds.height) / 2,
             startAngle: -.pi / 2,
             endAngle: 3 * .pi / 2,
             clockwise: true
         )

         trackLayer.path = circularPath.cgPath
         progressLayer.path = circularPath.cgPath
     }
}
