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
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        setupCardStyle()
    }
    
    func setupCardStyle() {
        let cornerRadius: CGFloat = 25
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.15
        let shadowRadius: CGFloat = 3
        let shadowOffset: CGSize = .init(width: 0, height: 1)

        cardBackground.layer.cornerRadius = cornerRadius
        cardBackground.layer.masksToBounds = false

        cardBackground.layer.shadowColor = shadowColor.cgColor
        cardBackground.layer.shadowOpacity = shadowOpacity
        cardBackground.layer.shadowRadius = shadowRadius
        cardBackground.layer.shadowOffset = shadowOffset
        cardBackground.backgroundColor = .white
    }
    
    func configure(range: String) {
        rangeLabel.text = range
    }
}
