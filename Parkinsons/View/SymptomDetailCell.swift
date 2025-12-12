// SymptomDetailCell.swift

import UIKit

class SymptomDetailCell: UITableViewCell {

    // ⭐️ Connect these outlets from the XIB/Storyboard ⭐️
    @IBOutlet weak var symptomIconImageView: UIImageView!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var intensityIconImageView: UIImageView!
    
    static let reuseIdentifier = "SymptomDetailCell"

    // Helper function to map Intensity to an image
    private func imageForIntensity(_ intensity: SymptomRating.Intensity) -> UIImage? {
        let baseIconName: String
        
        // We use the same base names from your SymptomRatingCell code,
        // assuming 'om' is a placeholder for the non-filled state.
        switch intensity {
        case .mild:
            // Assuming your non-filled icon is "face.smiling.om" (if it's a real asset)
            // If you are using standard SFSymbols, it should just be "face.smiling"
            baseIconName = "face.smiling"
        case .moderate:
            baseIconName = "face.neutral"
        case .severe:
            baseIconName = "face.sad"
        case .notPresent:
            baseIconName = "xmark.circle"
        }
        
        // In the detail cell, we always want the 'filled' version of the icon
        // to show the result clearly.
        return UIImage(systemName: baseIconName + ".fill")
    }

    func configure(with rating: SymptomRating) {
        symptomNameLabel.text = rating.name
        
        // Symptom Icon (left side)
        symptomIconImageView.image = UIImage(named: rating.iconName ?? "doc.text.image")
        symptomIconImageView.tintColor = .label
        
        // Intensity Icon (right side)
        intensityIconImageView.image = imageForIntensity(rating.selectedIntensity)
        
        // Set color based on intensity for visual feedback
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
