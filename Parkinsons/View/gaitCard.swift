//
//  gaitCard.swift
//  Parkinsons
//
//  Created by Noya Abraham on 29/12/25.
//

import UIKit

class gaitCard: UICollectionViewCell {

    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var cardBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. Disable clipping on the cell levels to allow shadow visibility
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        // 2. Apply the consistent card style
        setupCardStyle()
    }
    
    func setupCardStyle() {
        // Standardized shadow parameters from your other cards
        let cornerRadius: CGFloat = 16
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.15
        let shadowRadius: CGFloat = 3
        let shadowOffset: CGSize = .init(width: 0, height: 1)

        // Apply to the background view
        cardBackground.layer.cornerRadius = cornerRadius
        cardBackground.layer.masksToBounds = false // Crucial: false allows the shadow to "leak" outside

        // Shadow properties
        cardBackground.layer.shadowColor = shadowColor.cgColor
        cardBackground.layer.shadowOpacity = shadowOpacity
        cardBackground.layer.shadowRadius = shadowRadius
        cardBackground.layer.shadowOffset = shadowOffset
        
        // Ensure the background has a color, otherwise the shadow won't cast
        cardBackground.backgroundColor = .white
    }
    
    func configure(range: String) {
        rangeLabel.text = range
    }
}
