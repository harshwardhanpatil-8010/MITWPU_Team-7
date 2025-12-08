//
//  MemoryCellCollectionViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class MemoryCell: UICollectionViewCell {

    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var container: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        layer.masksToBounds = true
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.lightGray.cgColor
    }

    func configure(with card: MemoryCard) {
        if card.isFlipped || card.isMatched {
            cardImage.image = UIImage(named: card.imageName)
            container.backgroundColor = UIColor.white
        } else {
            cardImage.image = nil
            container.backgroundColor = UIColor.systemGray5
        }
    }
    
}

