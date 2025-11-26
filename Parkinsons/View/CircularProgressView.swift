import UIKit

@IBDesignable
class CircularProgressView: UIView {
    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    @IBInspectable var lineWidth: CGFloat = 25 {
        didSet { configure() }
    }
    @IBInspectable var progress: CGFloat = 0 { // 0..1
        didSet { updateProgress() }
    }
    
    override init(frame: CGRect) { super.init(frame: frame); configure() }
    required init?(coder: NSCoder) { super.init(coder: coder); configure() }
    override func layoutSubviews() { super.layoutSubviews(); configurePaths() }
    
    private func configure() {
        backgroundColor = .clear
        backgroundLayer.strokeColor = UIColor.systemGray5.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = lineWidth
        layer.addSublayer(backgroundLayer)
        
        progressLayer.strokeColor = UIColor.systemGreen.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = progress
        layer.addSublayer(progressLayer)
    }
    
    private func configurePaths() {
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth/2
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + CGFloat.pi * 2
        let path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        backgroundLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }
    
    private func updateProgress() {
        DispatchQueue.main.async {
            self.progressLayer.strokeEnd = min(max(self.progress, 0), 1)
        }
    }
    
    func setProgress(_ p: CGFloat, animated: Bool = true, duration: CFTimeInterval = 0.3) {
        let clamped = min(max(p,0),1)
        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = progressLayer.strokeEnd
            anim.toValue = clamped
            anim.duration = duration
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.strokeEnd = clamped
            progressLayer.add(anim, forKey: "progress")
        } else {
            progressLayer.strokeEnd = clamped
        }
    }
}

