// SymptomRatingCell.swift (Must be a subclass of UITableViewCell)

import UIKit

protocol SymptomRatingCellDelegate: AnyObject {
    func didSelectIntensity(_ intensity: SymptomRating.Intensity, in cell: SymptomRatingCell)
}

class SymptomRatingCell: UITableViewCell {
    
    weak var delegate: SymptomRatingCellDelegate?

    // ⭐️ Connect these outlets from your XIB ⭐️
    // Connect the line icon to this
    @IBOutlet weak var symptomIcon: UIImageView!
    // Connect the symptom name label (e.g., "Tremor") to this
    @IBOutlet weak var symptomLabel: UILabel!
    // Connect ALL 4 rating buttons (Mild, Moderate, Severe, Not Present) to this Outlet Collection
    @IBOutlet var ratingButtons: [UIButton]!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Ensure all buttons share a single target action
        ratingButtons.forEach { button in
            button.addTarget(self, action: #selector(ratingButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func ratingButtonTapped(_ sender: UIButton) {
        // The button's tag is used to determine the intensity (0, 1, 2, 3)
        guard let intensity = SymptomRating.Intensity(rawValue: sender.tag) else { return }
        delegate?.didSelectIntensity(intensity, in: self)
    }

    // SymptomRatingCell.swift - Inside the configure(with rating: symptomModel) method

    func configure(with rating: SymptomRating) {
        symptomLabel.text = rating.name
        
        // Set the symptom icon (e.g., running_man, hand_tremor)
        symptomIcon.image = UIImage(named: rating.iconName ?? "questionmark.circle.fill")
        symptomIcon.tintColor = .label
        
        // Update button visual state
        ratingButtons.forEach { button in
            guard let buttonIntensity = SymptomRating.Intensity(rawValue: button.tag) else { return }
            
            let isSelected = buttonIntensity == rating.selectedIntensity
            
            // Fix: Use standard SF Symbols as the suffixes '.ok' are not standard SF Symbols names.
            let baseIconName: String
            
            switch buttonIntensity {
            case .mild:
                baseIconName = "mild" // Happy face for Mild
            case .moderate:
                baseIconName = "moderate" // Neutral face for Moderate
            case .severe:
                baseIconName = "severe"     // Sad face for Severe
            case .notPresent:
                baseIconName = "notPresent" // X icon for Not Present
            }
            
            // Apply the icon (using .fill if selected)
            let finalIconName = isSelected ? baseIconName + ".fill" : baseIconName
            button.setImage(UIImage(systemName: finalIconName), for: .normal)
            
            // 4. Apply the color tint
            if isSelected {
                let selectedColor: UIColor = (buttonIntensity == .notPresent) ? .systemRed : .systemBlue
                button.tintColor = selectedColor
                
                // ⭐️ FIX: Add Border Logic Here ⭐️
                button.layer.borderWidth = 1.0
                button.layer.borderColor = selectedColor.cgColor   
                button.layer.cornerRadius = button.frame.height / 2 // Makes the border circular
                button.layer.masksToBounds = true // Crucial for making sure the corner radius applies
                
            } else {
                // Use gray for all unselected buttons
                button.tintColor = .systemGray
                
                // ⭐️ FIX: Remove Border Logic Here ⭐️
                button.layer.borderWidth = 0.0
                button.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
}
//SymptomRating
