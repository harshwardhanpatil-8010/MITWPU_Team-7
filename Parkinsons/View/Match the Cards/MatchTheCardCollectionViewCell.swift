//
//  MatchTheCardCollectionViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class MatchTheCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var frontLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    
    private var showingFront: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        // Initialization code
        frontLabel.isHidden = true
        backImageView.isHidden = false
        showingFront = false
        contentContainer.layer.cornerRadius = 20
        contentContainer.clipsToBounds = true
        contentContainer.layer.borderColor = UIColor.systemBlue.cgColor
        contentContainer.layer.borderWidth = 1.0
        frontLabel.layer.cornerRadius = 20
        frontLabel.clipsToBounds = true
        backImageView.layer.cornerRadius = 20
        backImageView.clipsToBounds = true
    }
    
    func configure(with card: Card) {
        frontLabel.text = card.content
        if card.isMatched {
            frontLabel.isHidden = false
            backImageView.isHidden = true
            contentView.alpha = 0.3
            showingFront = true
        } else {
            contentView.alpha = 1.0
            if card.isFlipped {
                frontLabel.isHidden = false
                backImageView.isHidden = true
                showingFront = true
            } else {
                frontLabel.isHidden = true
                backImageView.isHidden = false
                showingFront = false
            }
        }
    }
    
    func flip(toFront: Bool, animated: Bool) {
        if showingFront == toFront {
            return
        }
        showingFront = toFront
        let options: UIView.AnimationOptions = toFront ? .transitionFlipFromRight : .transitionFlipFromLeft
        let duration: TimeInterval = animated ? 0.32 : 0.0
        UIView.transition(with: contentContainer, duration: duration, options: options) {
            self.frontLabel.isHidden = !toFront
            self.backImageView.isHidden = toFront
        }
    }
    func revealForHint() {
        UIView.animate(withDuration: 0.25, animations: {
            self.contentContainer.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            self.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.25) {
                self.contentContainer.transform = .identity
                self.alpha = 1.0
            }
             
        }
    }
}
