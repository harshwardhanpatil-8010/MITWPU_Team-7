// MedicationCardCell.swift
// (Assuming you've renamed the file and class to MedicationCardCell for consistency)

import UIKit

class MedicationCardCollectionViewCell: UICollectionViewCell {

    // 1. New/Updated Outlets (Ensure these are connected in your XIB)
    @IBOutlet weak var BackgroundMedication: UIView! // Renamed to clearly separate it from the cell
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel! // NEW: For the "1 capsule" text
    @IBOutlet weak var iconImageView: UIImageView! // NEW: For the pill icon
    @IBOutlet weak var takenButton: UIButton! // NEW
    @IBOutlet weak var skippedButton: UIButton! // NEW

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 2. Card Styling: Apply rounded corners and shadow to the main background view
        BackgroundMedication.applyCardStyle()
        BackgroundMedication.layer.cornerRadius = 16 
        // Clip subviews
        
        // 3. Button Styling
        takenButton.layer.cornerRadius = 18 // Half the button height
        skippedButton.layer.cornerRadius = 18 // Half the button height
    }

    // 4. Enhanced Configuration method
    func configure(with model: MedicationModel) {
        timeLabel.text = model.time
        nameLabel.text = model.name
        detailLabel.text = model.detail // Set the new detail text

        // Set the pill icon using SFSymbols
       // iconImageView.image = UIImage(systemName: model.iconName)
        
        // Basic styling for the card content
        //BackgroundMedication.backgroundColor = .systemGray5
        
        // Add action targets here if you want to handle button taps
        // takenButton.addTarget(self, action: #selector(takenTapped), for: .touchUpInside)
    }
    
    // Optional: Add an action handler
    // @objc func takenTapped() {
    //     // Handle button tap here, perhaps using a delegate or closure
    // }
}
