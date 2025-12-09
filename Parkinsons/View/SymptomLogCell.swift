// SymptomLogCell.swift

import UIKit

class SymptomLogCell: UICollectionViewCell {
    
    // ⭐️ Connect these outlets in the XIB ⭐️
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logNowButton: UIButton!
    @IBOutlet weak var backgroundCardView: UIView! // Add a background view for the rounded rectangle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Styling for the main card view
        backgroundCardView.layer.cornerRadius = 16
        backgroundCardView.layer.masksToBounds = true
        // Set a background color similar to the reference image (e.g., systemGray5 or lighter gray)
        backgroundCardView.backgroundColor = UIColor.systemGray5
        
        // Styling for the button
        logNowButton.layer.cornerRadius = 15 // Adjust radius to match goal image
        logNowButton.backgroundColor = UIColor.systemBlue // Set button color
        logNowButton.setTitleColor(UIColor.white, for: .normal)
    }

    func configure(with message: String, buttonTitle: String) {
        descriptionLabel.text = message
        logNowButton.setTitle(buttonTitle, for: .normal)
    }
}
