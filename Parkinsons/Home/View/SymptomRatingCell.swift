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
        label.alpha = 0
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addSubview(bubbleLabel)
        
        setupButtonActions()
    }
    
    private func setupButtonActions() {
        ratingButtons.forEach { button in
            let action = UIAction { [weak self] action in
                guard let self = self,
                      let sender = action.sender as? UIButton,
                      let intensity = SymptomRating.Intensity(rawValue: sender.tag) else { return }
                
                self.handleRatingSelection(intensity: intensity, from: sender)
            }
            button.addAction(action, for: .touchUpInside)
        }
    }
    
    private func handleRatingSelection(intensity: SymptomRating.Intensity, from button: UIButton) {
        showBubble(above: button, text: intensity.displayName, animated: true)
        delegate?.didSelectIntensity(intensity, in: self)
    }

    private func showBubble(above button: UIButton, text: String, animated: Bool) {
        self.layoutIfNeeded()
        
        bubbleLabel.text = text
        bubbleLabel.sizeToFit()
        
        let padding: CGFloat = 20
        bubbleLabel.frame.size.width += padding
        bubbleLabel.frame.size.height = 30
        let buttonFrameInCell = button.convert(button.bounds, to: self.contentView)
        let calculatedCenterX = buttonFrameInCell.midX
        let calculatedCenterY = buttonFrameInCell.maxY + 8
        
        bubbleLabel.center = CGPoint(x: calculatedCenterX, y: calculatedCenterY)
        contentView.bringSubviewToFront(bubbleLabel)
        
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
        
        bubbleLabel.alpha = 0
        
        ratingButtons.forEach { button in
            guard let buttonIntensity = SymptomRating.Intensity(rawValue: button.tag) else { return }
            
            let isSelected = (buttonIntensity == rating.selectedIntensity)
            
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
                showBubble(above: button, text: buttonIntensity.displayName, animated: false)
            } else {
                button.tintColor = .systemGray
            }
        }
    }
}
extension SymptomRating.Intensity {
    var displayName: String {
        switch self {
        case .notPresent: return "Not Present"
        case .mild:       return "Mild"
        case .moderate:   return "Moderate"
        case .severe:     return "Severe"
        }
    }
}
