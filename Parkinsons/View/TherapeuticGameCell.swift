// TherapeuticGameCell.swift

import UIKit

class TherapeuticGameCell: UICollectionViewCell {
    
    // ⭐️ Connect these outlets in the XIB ⭐️
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var backgroundCardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Styling for the card
        backgroundCardView.layer.cornerRadius = 16
        backgroundCardView.layer.masksToBounds = true
        backgroundCardView.backgroundColor = UIColor.systemGray5 // Light background
    }

    func configure(with model: TherapeuticGameModel) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        
        // Use images
        if let imageName = model.iconName {
                // ⭐️ Load image from Assets.xcassets ⭐️
                iconImageView.image = UIImage(named: imageName)
                
                // When using custom images, you usually don't set a tintColor,
                // as the image should already contain its intended color.
                iconImageView.tintColor = nil
            }
        }
        
        
        // Use an SFSymbol for the icon
//        if let iconName = model.iconName {
//            iconImageView.image = UIImage(systemName: iconName)
//            iconImageView.tintColor = .black // Adjust color as needed
//        }
    }

