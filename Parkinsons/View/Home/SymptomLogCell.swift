// SymptomLogCell.swift

import UIKit

// 1. Define the Delegate Protocol
protocol SymptomLogCellDelegate: AnyObject {
    func symptomLogCellDidTapLogNow(_ cell: SymptomLogCell)
}

class SymptomLogCell: UICollectionViewCell {
    
    // Add the weak delegate property
    weak var delegate: SymptomLogCellDelegate?

    // ⭐️ Connect these outlets in the XIB ⭐️
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logNowButton: UIButton! // This button needs its Touch Up Inside connected to the action below
    @IBOutlet weak var backgroundCardView: UIView! // Add a background view for the rounded rectangle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clipsToBounds = false
                self.contentView.clipsToBounds = false
                
                // ⭐️ STEP 2: APPLY CUSTOM SHADOW LOGIC ⭐️
                setupCardStyle()
                
                // Styling for the button
                logNowButton.layer.cornerRadius = 15 // Adjust radius to match goal image
                logNowButton.backgroundColor = UIColor.systemBlue // Set button color
                logNowButton.setTitleColor(UIColor.white, for: .normal)
                
                // ⭐️ CRITICAL: Connect the button action programmatically or via Storyboard ⭐️
                logNowButton.addTarget(self, action: #selector(logNowButtonTapped), for: .touchUpInside)
    }
    func setupCardStyle() {
            let cornerRadius: CGFloat = 16 // Set to 16, matching the cornerRadius in your original code
            let shadowColor: UIColor = .black
            let shadowOpacity: Float = 0.15
            let shadowRadius: CGFloat = 3
            let shadowOffset: CGSize = .init(width: 0, height: 1) // Slight vertical offset

            // Apply Corner Radius to the background view
            backgroundCardView.layer.cornerRadius = cornerRadius
            
            // Disable clipping on the background view layer itself
            backgroundCardView.layer.masksToBounds = false

            // Apply Shadow properties
            backgroundCardView.layer.shadowColor = shadowColor.cgColor
            backgroundCardView.layer.shadowOpacity = shadowOpacity
            backgroundCardView.layer.shadowRadius = shadowRadius
            backgroundCardView.layer.shadowOffset = shadowOffset
        }
    // 2. Button Action calls the Delegate
    @objc private func logNowButtonTapped() {
        delegate?.symptomLogCellDidTapLogNow(self)
    }

    func configure(with message: String, buttonTitle: String) {
        descriptionLabel.text = message
        logNowButton.setTitle(buttonTitle, for: .normal)
    }
}
