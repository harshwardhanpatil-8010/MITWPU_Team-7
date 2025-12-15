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
@IBOutlet weak var progressLabel: UILabel!// e.g., "0% Done"
@IBOutlet weak var progressRingContainer: UIView! // For the circular progress view
//@IBOutlet weak var timeEstimateLabel: UILabel!    // e.g., "7.5"
@IBOutlet weak var backgroundCardView: UIView! // For corner radius and shadow
private var progressTrackLayer = CAShapeLayer()
private var progressLayer = CAShapeLayer()

// NEW: Property to hold the progress color
private var currentProgressColor: UIColor = .systemBlue
    private var progressView: CircularProgressView!
 override func awakeFromNib() {
    super.awakeFromNib()
    self.clipsToBounds = false
    self.contentView.clipsToBounds = false
     progressView = CircularProgressView(frame: progressRingContainer.bounds)
     progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
     progressRingContainer.addSubview(progressView)
    // ⭐️ STEP 2: APPLY CUSTOM SHADOW LOGIC ⭐️
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

    // ⭐️ UPDATE: Set the color property from the model ⭐️

     // Re-call setupProgressRing to update the progressLayer's strokeColor and the track color
    progressView.progressColor = .systemBlue
    progressView.trackColor = .systemGray5
}
    
// IMPORTANT: Fix for layout changes
override func layoutSubviews() {
    super.layoutSubviews()
    // Recalculate and redraw the path if the size changes (essential when using Auto Layout)
     
    }

}

// Extension to convert Hex String to UIColor
extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        guard hexSanitized.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)
        
        r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        b = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
