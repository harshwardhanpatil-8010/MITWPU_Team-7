// SymptomDetailCell.swift

import UIKit

class SymptomDetailCell: UITableViewCell {

    // ⭐️ Connect these outlets from the XIB/Storyboard ⭐️
    @IBOutlet weak var symptomIconImageView: UIImageView!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var intensityIconImageView: UIImageView! // The target image view
    
    static let reuseIdentifier = "SymptomDetailCell"

    // Helper function to map Intensity to an image
    private func imageForIntensity(_ intensity: SymptomRating.Intensity) -> UIImage? {
        let assetName: String
        
        // ⭐️ MODIFICATION: Use Asset Names instead of SFSymbols ⭐️
        switch intensity {
        case .mild:
            // Assumes you have an image named "face.mild" in your assets.
            assetName = "faceMild"
        case .moderate:
            // Assumes you have an image named "face.moderate" in your assets.
            assetName = "moderateFace"
        case .severe:
            // Assuming you have a severe icon in your assets, e.g., "face.severe"
            assetName = "SevereFace 1" // Replace with your actual severe asset name if different
        case .notPresent:
            // Assuming you have a not present icon, e.g., "xmark.circle.red"
            assetName = "xMark" // Replace with your actual notPresent asset name if different
        }
        
        // Load image from the main asset catalog
        return UIImage(named: assetName)
    }

    func configure(with rating: SymptomRating) {
        symptomNameLabel.text = rating.name
        
        // Symptom Icon (left side) - Remains the same, loading from assets by `rating.iconName`
        symptomIconImageView.image = UIImage(named: rating.iconName ?? "doc.text.image")
        symptomIconImageView.tintColor = .label
        
        // Intensity Icon (right side) - Now using custom assets
        intensityIconImageView.image = imageForIntensity(rating.selectedIntensity)
        
        // Set color based on intensity for visual feedback
        // NOTE: If your asset images are not template images (i.e., they are full color),
        // setting the tintColor here might not change their appearance.
        if rating.selectedIntensity == .notPresent {
            intensityIconImageView.tintColor = .systemRed
        } else if rating.selectedIntensity == .severe {
            intensityIconImageView.tintColor = .systemOrange // Or red/black depending on design
        } else {
            intensityIconImageView.tintColor = .systemBlue
        }
        
        self.selectionStyle = .none
    }
}
