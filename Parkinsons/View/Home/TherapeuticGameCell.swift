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
        
        super.awakeFromNib()
                
                // ⭐️ STEP 1: FIX CLIPPING (Crucial for shadows to show on all edges) ⭐️
                // Disable clipping on the cell and its content view to allow the shadow to render outside the bounds.
                self.clipsToBounds = false
                self.contentView.clipsToBounds = false
                
                // ⭐️ STEP 2: APPLY CUSTOM SHADOW LOGIC ⭐️
                setupCardStyle()
    }
    func setupCardStyle() {
            let cornerRadius: CGFloat = 16
            let shadowColor: UIColor = .black
            let shadowOpacity: Float = 0.15
            let shadowRadius: CGFloat = 3
            let shadowOffset: CGSize = .init(width: 0, height: 1) // Slight vertical offset

            // Apply Corner Radius to the background view
            backgroundCardView.layer.cornerRadius = cornerRadius
            
            // Disable clipping on the background view layer itself
            backgroundCardView.layer.masksToBounds = false

            // Apply Shadow properties
            backgroundCardView.layer.shadowColor = shadowColor.cgColor
            backgroundCardView.layer.shadowOpacity = shadowOpacity
            backgroundCardView.layer.shadowRadius = shadowRadius
            backgroundCardView.layer.shadowOffset = shadowOffset
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

