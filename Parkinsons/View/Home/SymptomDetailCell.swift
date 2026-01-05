import UIKit

class SymptomDetailCell: UITableViewCell {

    @IBOutlet weak var symptomIconImageView: UIImageView!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var intensityIconImageView: UIImageView!
    
    static let reuseIdentifier = "SymptomDetailCell"

    // 1. Add the closure to notify the ViewController of changes
    var onRatingChanged: ((SymptomRating.Intensity) -> Void)?

    private func imageForIntensity(_ intensity: SymptomRating.Intensity?) -> UIImage? {
        guard let intensity = intensity else { return nil }
        
        let assetName: String
        switch intensity {
        case .mild: assetName = "faceMild"
        case .moderate: assetName = "moderateFace"
        case .severe: assetName = "SevereFace 1"
        case .notPresent: assetName = "xMark"
        }
        return UIImage(named: assetName)
    }

    // 2. Update signature to include isEditable
    func configure(with rating: SymptomRating, isEditable: Bool) {
        symptomNameLabel.text = rating.name
        
        // Symptom Icon
        symptomIconImageView.image = UIImage(named: rating.iconName ?? "doc.text.image")
        symptomIconImageView.tintColor = .label
        
        // Intensity Logic
        if let intensity = rating.selectedIntensity {
            intensityIconImageView.isHidden = false
            intensityIconImageView.image = imageForIntensity(intensity)
            
            switch intensity {
            case .notPresent: intensityIconImageView.tintColor = .systemRed
            case .severe: intensityIconImageView.tintColor = .systemOrange
            default: intensityIconImageView.tintColor = .systemBlue
            }
        } else {
            intensityIconImageView.image = nil
            intensityIconImageView.isHidden = true
        }
        
        // 3. Handle UI changes for "Edit Mode"
        if isEditable {
            self.backgroundColor = UIColor.systemGray6 // Light gray to show it's "active"
            self.accessoryType = .disclosureIndicator  // Shows a small arrow >
        } else {
            self.backgroundColor = .clear
            self.accessoryType = .none
        }
        
        self.selectionStyle = isEditable ? .default : .none
    }
}
