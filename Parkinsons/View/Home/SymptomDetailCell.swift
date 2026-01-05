import UIKit

class SymptomDetailCell: UITableViewCell {

    @IBOutlet weak var symptomIconImageView: UIImageView!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var intensityIconImageView: UIImageView!
    
    static let reuseIdentifier = "SymptomDetailCell"

    // 1. Update the parameter type to Intensity? (Optional)
    private func imageForIntensity(_ intensity: SymptomRating.Intensity?) -> UIImage? {
        // Handle nil case
        guard let intensity = intensity else { return nil }
        
        let assetName: String
        switch intensity {
        case .mild:
            assetName = "faceMild"
        case .moderate:
            assetName = "moderateFace"
        case .severe:
            assetName = "SevereFace 1"
        case .notPresent:
            assetName = "xMark"
        }
        
        return UIImage(named: assetName)
    }

    func configure(with rating: SymptomRating) {
        symptomNameLabel.text = rating.name
        
        // Symptom Icon (left side)
        symptomIconImageView.image = UIImage(named: rating.iconName ?? "doc.text.image")
        symptomIconImageView.tintColor = .label
        
        // 2. Safely handle the optional intensity
        if let intensity = rating.selectedIntensity {
            // Show the icon if there is a selection
            intensityIconImageView.isHidden = false
            intensityIconImageView.image = imageForIntensity(intensity)
            
            // Set color based on intensity
            switch intensity {
            case .notPresent:
                intensityIconImageView.tintColor = .systemRed
            case .severe:
                intensityIconImageView.tintColor = .systemOrange
            default:
                intensityIconImageView.tintColor = .systemBlue
            }
        } else {
            // 3. Hide the intensity icon if nothing is selected
            intensityIconImageView.image = nil
            intensityIconImageView.isHidden = true
        }
        
        self.selectionStyle = .none
    }
}
