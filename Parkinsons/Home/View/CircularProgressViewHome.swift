//
//  CircularProgressViewHome.swift
//  Parkinsons
//
//  Created by SDC-USER on 04/01/26.
//

import UIKit

 class CircularProgressViewHome: UIView {
    
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
            radius: (bounds.width / 2) - 7,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = CGFloat(14.0)
        trackLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = CGFloat(14.0)
        progressLayer.lineCap = .round
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = 1
        layer.addSublayer(progressLayer)
    }
    
    private var centerPoint: CGPoint {
        CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    func setProgress(_ progress: CGFloat) {
        progressLayer.strokeEnd = progress
    }
}
