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
        
        // Styling for the main card view
        backgroundCardView.layer.cornerRadius = 16
        backgroundCardView.applyCardStyle() // Assuming this is defined in an extension
        
        // Styling for the button
        logNowButton.layer.cornerRadius = 15 // Adjust radius to match goal image
        logNowButton.backgroundColor = UIColor.systemBlue // Set button color
        logNowButton.setTitleColor(UIColor.white, for: .normal)
        
        // ⭐️ CRITICAL: Connect the button action programmatically or via Storyboard ⭐️
        logNowButton.addTarget(self, action: #selector(logNowButtonTapped), for: .touchUpInside)
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
