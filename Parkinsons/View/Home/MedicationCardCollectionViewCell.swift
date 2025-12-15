// MedicationCardCell.swift
// (Assuming you've renamed the file and class to MedicationCardCell for consistency)

import UIKit

class MedicationCardCollectionViewCell: UICollectionViewCell {

    // 1. New/Updated Outlets (Ensure these are connected in your XIB)
    @IBOutlet weak var BackgroundMedication: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView! // NEW: For the pill icon
    @IBOutlet weak var takenButton: UIButton!
    @IBOutlet weak var skippedButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // ⭐️ STEP 1: FIX CLIPPING ⭐️
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        // ⭐️ STEP 2: APPLY CUSTOM SHADOW LOGIC ⭐️
        setupCardStyle()
        
        // 3. Button Styling
        takenButton.layer.cornerRadius = 18
        skippedButton.layer.cornerRadius = 18
        
        // NOTE: The iconImageView's frame is not final here, so we apply circularity in layoutSubviews.
    }
    
    // ⭐️ CRITICAL: Use layoutSubviews to ensure circularity ⭐️
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Apply circular mask to the iconImageView
        // This makes the icon circular and clips the image content to the circle.
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2.0
        iconImageView.clipsToBounds = true
    }
    
    func setupCardStyle() {
        let cornerRadius: CGFloat = 16
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.15
        let shadowRadius: CGFloat = 3
        let shadowOffset: CGSize = .init(width: 0, height: 1)

        // Apply Corner Radius to the background view
        BackgroundMedication.layer.cornerRadius = cornerRadius
        
        // Disable clipping on the background view layer itself
        BackgroundMedication.layer.masksToBounds = false

        // Apply Shadow properties
        BackgroundMedication.layer.shadowColor = shadowColor.cgColor
        BackgroundMedication.layer.shadowOpacity = shadowOpacity
        BackgroundMedication.layer.shadowRadius = shadowRadius
        BackgroundMedication.layer.shadowOffset = shadowOffset
    }
    
    // 4. Enhanced Configuration method
    func configure(with model: MedicationModel) {
        timeLabel.text = model.time
        nameLabel.text = model.name
        detailLabel.text = model.detail

        // Note: The image source (model.iconName) is commented out in the original code,
        // but this is where you would configure it:
        // iconImageView.image = UIImage(systemName: model.iconName)
    }
    
    // Optional: Add an action handler
    // @objc func takenTapped() {
    //     // Handle button tap here, perhaps using a delegate or closure
    // }
}
