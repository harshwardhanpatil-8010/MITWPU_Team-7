//
//  ExerciseCardCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//


import UIKit

class ExerciseCardCell: UICollectionViewCell {

// ⭐️ You must connect these outlets in the XIB ⭐️
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!  // e.g., "0% Done"
    @IBOutlet weak var progressRingContainer: UIView! // For the circular progress view
    //@IBOutlet weak var timeEstimateLabel: UILabel!    // e.g., "7.5"
    @IBOutlet weak var backgroundCardView: UIView! // For corner radius and shadow
    private var progressTrackLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundCardView.layer.cornerRadius = 16
        backgroundCardView.layer.masksToBounds = true
        progressRingContainer.backgroundColor = .clear
        setupProgressRing()
    }

    func configure(with model: ExerciseModel) {
        titleLabel.text = model.title
        detailLabel.text = model.detail
        progressLabel.text = "\(model.progressPercentage)%"
        // timeEstimateLabel.text = model.timeEstimate
        backgroundCardView.backgroundColor = .systemGray5
        updateProgressRing(progress: model.progressPercentage)

    }
    private func setupProgressRing() {
        if progressLayer.superlayer == nil {
                progressRingContainer.layer.addSublayer(progressTrackLayer)
                progressRingContainer.layer.addSublayer(progressLayer)
            }
        // Ensure the container is round
        progressRingContainer.layer.cornerRadius = progressRingContainer.frame.width / 2

        let center = CGPoint(x: progressRingContainer.bounds.midX, y: progressRingContainer.bounds.midY)
        let radius = progressRingContainer.bounds.width / 2.0
        let lineWidth: CGFloat = 14.0 // Thickness of the ring

        // 1. Define the circular path (a full circle)
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius - (lineWidth / 2), // Adjust radius based on line width
            startAngle: -CGFloat.pi / 2,// Start at the top (12 o'clock)
            endAngle: 2 * CGFloat.pi - (CGFloat.pi / 2),
            clockwise: true
         )

        // 2. Track Layer (The gray background)
        progressTrackLayer.path = circularPath.cgPath
        progressTrackLayer.strokeColor = UIColor.systemGray4.cgColor // Light gray color for the track
        progressTrackLayer.lineWidth = lineWidth
        progressTrackLayer.fillColor = UIColor.clear.cgColor
        progressTrackLayer.lineCap = .round
        progressRingContainer.layer.addSublayer(progressTrackLayer)

         // 3. Progress Layer (The blue line)
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.systemBlue.cgColor // Blue color for the progress
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0 // Initially 0% done
        progressRingContainer.layer.addSublayer(progressLayer)
     }
    private func updateProgressRing(progress: Int) {
        // Calculate the strokeEnd value (0.0 to 1.0)
        let normalizedProgress = CGFloat(progress) / 100.0

        // Use animation for a smooth transition (optional)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = normalizedProgress
        animation.duration = 0.5 // Animation duration in seconds
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        progressLayer.removeAllAnimations() // Remove previous animations
        progressLayer.add(animation, forKey: "animateProgress")

        // Crucially, update the model layer value immediately for non-animated views
        progressLayer.strokeEnd = normalizedProgress
        }

        // IMPORTANT: Fix for layout changes
        override func layoutSubviews() {
        super.layoutSubviews()
        // Recalculate and redraw the path if the size changes (essential when using Auto Layout)
        setupProgressRing()
    }

}
