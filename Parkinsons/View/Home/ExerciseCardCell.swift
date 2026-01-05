//
//  ExerciseCardCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//


import UIKit

class ExerciseCardCell: UICollectionViewCell {

@IBOutlet weak var titleLabel: UILabel!
@IBOutlet weak var detailLabel: UILabel!
@IBOutlet weak var progressLabel: UILabel!
@IBOutlet weak var progressRingContainer: UIView!

@IBOutlet weak var backgroundCardView: UIView!
private var progressTrackLayer = CAShapeLayer()
private var progressLayer = CAShapeLayer()


private var currentProgressColor: UIColor = .systemBlue
    private var progressView: CircularProgressViewHome!
 override func awakeFromNib() {
    super.awakeFromNib()
    self.clipsToBounds = false
    self.contentView.clipsToBounds = false
     progressView = CircularProgressViewHome(frame: progressRingContainer.bounds)
     progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
     progressRingContainer.addSubview(progressView)
     
    setupCardStyle()
    backgroundCardView.layer.cornerRadius = 16
    progressRingContainer.backgroundColor = .clear
    
    }
    func setProgress(completed: Int, total: Int) {
            progressLabel.text = "\(completed)/\(total)"

            let progress = total == 0 ? 0 : CGFloat(completed) / CGFloat(total)
            progressView.setProgress(progress)

            if completed == total && total > 0 {
                progressView.progressColor = .systemGreen
            } else {
                progressView.progressColor = .systemBlue
            }
        }
        
func setupCardStyle() {
    let cornerRadius: CGFloat = 16 // Set to 16, matching the cornerRadius in awakeFromNib
    let shadowColor: UIColor = .black
    let shadowOpacity: Float = 0.15
    let shadowRadius: CGFloat = 3
    let shadowOffset: CGSize = .init(width: 0, height: 1) // Slight vertical offset

    // Apply Corner Radius to the background view
    backgroundCardView.layer.cornerRadius = cornerRadius

    // Disable clipping on the background view layer itself
    // This is crucial for displaying the shadow
    backgroundCardView.layer.masksToBounds = false

    // Apply Shadow properties
    backgroundCardView.layer.shadowColor = shadowColor.cgColor
    backgroundCardView.layer.shadowOpacity = shadowOpacity
    backgroundCardView.layer.shadowRadius = shadowRadius
    backgroundCardView.layer.shadowOffset = shadowOffset
}
    
func configure(with model: ExerciseModel) {
    titleLabel.text = model.title
    detailLabel.text = model.detail

    progressView.progressColor = .systemBlue
    progressView.trackColor = .systemGray5
}
    
override func layoutSubviews() {
    super.layoutSubviews()
   
    }

}

