import UIKit

class SymptomDetailCell: UITableViewCell {

    @IBOutlet weak var symptomIconImageView: UIImageView!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var intensityIconImageView: UIImageView!

    static let reuseIdentifier = "SymptomDetailCell"

    var onRatingChanged: ((SymptomRating.Intensity) -> Void)?

    private func imageForIntensity(_ intensity: SymptomRating.Intensity?) -> UIImage? {
        guard let intensity = intensity else { return nil }

        let assetName: String
        switch intensity {
        case .mild: assetName = "mild1"
        case .moderate: assetName = "moderate1"
        case .severe: assetName = "severe1"
        case .notPresent: assetName = "notpresent1"
        }
        return UIImage(named: assetName)
    }

    func configure(with rating: SymptomRating, isEditable: Bool) {
        symptomNameLabel.text = rating.name

        if let iconName = rating.iconName {
            symptomIconImageView.image = UIImage(named: iconName)
        } else {
            symptomIconImageView.image = UIImage(systemName: "doc.text.image")
        }
        symptomIconImageView.tintColor = .label

        if let intensity = rating.selectedIntensity {
            intensityIconImageView.isHidden = false
            intensityIconImageView.image = imageForIntensity(intensity)
            intensityIconImageView.tintColor = nil
        } else {
            intensityIconImageView.image = nil
            intensityIconImageView.isHidden = true
        }

        if isEditable {
            self.backgroundColor = UIColor.systemGray6
            self.accessoryType = .disclosureIndicator
        } else {
            self.backgroundColor = .clear
            self.accessoryType = .none
        }

        self.selectionStyle = isEditable ? .default : .none
    }
}
