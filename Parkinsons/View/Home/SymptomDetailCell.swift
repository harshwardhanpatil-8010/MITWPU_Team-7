import UIKit

class SymptomDetailCell: UITableViewCell {

    @IBOutlet weak var symptomIconImageView: UIImageView!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var intensityIconImageView: UIImageView!
    
    static let reuseIdentifier = "SymptomDetailCell"

    private func imageForIntensity(_ intensity: SymptomRating.Intensity) -> UIImage? {
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
        
        // Intensity Icon (right side)
        intensityIconImageView.image = imageForIntensity(rating.selectedIntensity)
        
        // Set color based on intensity for visual feedback
        if rating.selectedIntensity == .notPresent {
            intensityIconImageView.tintColor = .systemRed
        } else if rating.selectedIntensity == .severe {
            intensityIconImageView.tintColor = .systemOrange
        } else {
            intensityIconImageView.tintColor = .systemBlue
        }
        
        self.selectionStyle = .none
    }
}
