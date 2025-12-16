// SymptomRatingCell.swift (Must be a subclass of UITableViewCell)

import UIKit

protocol SymptomRatingCellDelegate: AnyObject {
    func didSelectIntensity(_ intensity: SymptomRating.Intensity, in cell: SymptomRatingCell)
}

class SymptomRatingCell: UITableViewCell {
    
    weak var delegate: SymptomRatingCellDelegate?

    
    @IBOutlet weak var symptomIcon: UIImageView!
    
    @IBOutlet weak var symptomLabel: UILabel!
    
    @IBOutlet var ratingButtons: [UIButton]!

    override func awakeFromNib() {
        super.awakeFromNib()
       
        ratingButtons.forEach { button in
            button.addTarget(self, action: #selector(ratingButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func ratingButtonTapped(_ sender: UIButton) {
       
        guard let intensity = SymptomRating.Intensity(rawValue: sender.tag) else { return }
        delegate?.didSelectIntensity(intensity, in: self)
    }
 func configure(with rating: SymptomRating) {
        symptomLabel.text = rating.name
        
        symptomIcon.image = UIImage(named: rating.iconName ?? "questionmark.circle.fill")
        symptomIcon.tintColor = .label
        
        ratingButtons.forEach { button in
            guard let buttonIntensity = SymptomRating.Intensity(rawValue: button.tag) else { return }
            
            let isSelected = buttonIntensity == rating.selectedIntensity
           
            let baseIconName: String
            
            switch buttonIntensity {
            case .mild:
                baseIconName = "mild"
            case .moderate:
                baseIconName = "moderate" 
            case .severe:
                baseIconName = "severe"
            case .notPresent:
                baseIconName = "notPresent"
            }
          
            let finalIconName = isSelected ? baseIconName + ".fill" : baseIconName
            button.setImage(UIImage(systemName: finalIconName), for: .normal)
           
            if isSelected {
                let selectedColor: UIColor = (buttonIntensity == .notPresent) ? .systemRed : .systemBlue
                button.tintColor = selectedColor
               
                button.layer.borderWidth = 1.0
                button.layer.borderColor = selectedColor.cgColor   
                button.layer.cornerRadius = button.frame.height / 2
                button.layer.masksToBounds = true
            } else {
                
                button.tintColor = .systemGray
                
                button.layer.borderWidth = 0.0
                button.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
}

