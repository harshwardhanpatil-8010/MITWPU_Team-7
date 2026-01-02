import UIKit

protocol SymptomRatingCellDelegate: AnyObject {
    func didSelectIntensity(_ intensity: SymptomRating.Intensity, in cell: SymptomRatingCell)
}

class SymptomRatingCell: UITableViewCell {
    
    weak var delegate: SymptomRatingCellDelegate?
    
    @IBOutlet weak var symptomIcon: UIImageView!
    @IBOutlet weak var symptomLabel: UILabel!
    @IBOutlet var ratingButtons: [UIButton]!
    
    private let bubbleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.systemGray6
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.alpha = 0 // Initially completely invisible
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addSubview(bubbleLabel)
        ratingButtons.forEach { button in
            button.addTarget(self, action: #selector(ratingButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func ratingButtonTapped(_ sender: UIButton) {
        guard let intensity = SymptomRating.Intensity(rawValue: sender.tag) else { return }
        
        // Show the bubble with animation only when a button is physically tapped
        showBubble(above: sender, text: intensity.displayName, animated: true)
        
        delegate?.didSelectIntensity(intensity, in: self)
    }

    private func showBubble(above button: UIButton, text: String, animated: Bool) {
        bubbleLabel.text = text
        bubbleLabel.sizeToFit()
        
        let padding: CGFloat = 20
        bubbleLabel.frame.size.width += padding
        bubbleLabel.frame.size.height = 30
        
        // Aligning to center of the button
        let centerX = button.center.x
        let centerY = button.frame.maxY + 15
        bubbleLabel.center = CGPoint(x: centerX, y: centerY)
        
        if animated {
            bubbleLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .beginFromCurrentState, animations: {
                self.bubbleLabel.alpha = 1.0
                self.bubbleLabel.transform = .identity
            }, completion: nil)
        } else {
            self.bubbleLabel.alpha = 1.0
            self.bubbleLabel.transform = .identity
        }
    }

    func configure(with rating: SymptomRating) {
        symptomLabel.text = rating.name
        symptomIcon.image = UIImage(named: rating.iconName ?? "questionmark.circle.fill")
        
        // Start with bubble hidden
        bubbleLabel.alpha = 0
        
        ratingButtons.forEach { button in
            guard let buttonIntensity = SymptomRating.Intensity(rawValue: button.tag) else { return }
            
            // If rating.selectedIntensity is nil, isSelected will be false for everyone
            let isSelected = (buttonIntensity == rating.selectedIntensity)
            
            // ... (your existing icon switching logic) ...
            let baseIconName: String
            switch buttonIntensity {
            case .mild: baseIconName = "mild"
            case .moderate: baseIconName = "moderate"
            case .severe: baseIconName = "severe"
            case .notPresent: baseIconName = "notPresent"
            }
            let finalIconName = isSelected ? baseIconName + ".fill" : baseIconName
            button.setImage(UIImage(systemName: finalIconName), for: .normal)
            
            if isSelected {
                let selectedColor: UIColor = (buttonIntensity == .notPresent) ? .systemRed : .systemBlue
                button.tintColor = selectedColor
                
                // This will now only run if a button was actually clicked/saved
                showBubble(above: button, text: buttonIntensity.displayName, animated: false)
            } else {
                button.tintColor = .systemGray
            }
        }
    }
}

// Fixed Extension - Place this at the very bottom of the file
extension SymptomRating.Intensity {
    var displayName: String {
        switch self {
        case .notPresent: return "None"
        case .mild:       return "Mild"
        case .moderate:   return "Moderate"
        case .severe:     return "Severe"
        }
    }
}
