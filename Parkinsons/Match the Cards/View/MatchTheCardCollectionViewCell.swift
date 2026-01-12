//
//  MatchTheCardCollectionViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 11/12/25.


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

        
        
        // 1. Ensure no "pointed" corners
        contentContainer.layer.cornerRadius = 15
        contentContainer.clipsToBounds = true
        
        frontLabel.layer.cornerRadius = 15
        frontLabel.clipsToBounds = true
        
        backImageView.layer.cornerRadius = 15
        backImageView.clipsToBounds = true
        
        // Initial border state
        contentContainer.layer.borderWidth = 1.0
        contentContainer.layer.borderColor = UIColor.systemGray5.cgColor
    }
    override func prepareForReuse() {
        super.prepareForReuse()

        alpha = 1.0
        isUserInteractionEnabled = true

        contentContainer.isHidden = false
        contentContainer.layer.borderWidth = 0.5
        contentContainer.layer.borderColor = UIColor.orange.cgColor

        frontLabel.isHidden = true
        backImageView.isHidden = false

        showingFront = false
    }

    func showEmpty() {
        // Reset visuals but KEEP the cell visible
        contentContainer.isHidden = false

        frontLabel.isHidden = true
        backImageView.isHidden = true

        contentContainer.backgroundColor = .clear
        contentContainer.layer.borderWidth = 0

        alpha = 0.15
        isUserInteractionEnabled = false
    }
    

    func configure(with card: Card) {
        frontLabel.text = card.content
        if card.isMatched {
            frontLabel.isHidden = false
            backImageView.isHidden = true
            contentView.alpha = 0.3
            return
        }
        contentView.alpha = 1.0
        frontLabel.isHidden = !card.isFlipped
        backImageView.isHidden = card.isFlipped
    }
//
//
//import UIKit
//
//class MatchTheCardCollectionViewCell: UICollectionViewCell {
//    @IBOutlet weak var contentContainer: UIView!
//    @IBOutlet weak var frontLabel: UILabel!
//    @IBOutlet weak var backImageView: UIImageView!
//    
//    private var showingFront: Bool = false
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        // 1. Ensure no "pointed" corners
//        contentContainer.layer.cornerRadius = 15
//        contentContainer.clipsToBounds = true
//        
//        frontLabel.layer.cornerRadius = 15
//        frontLabel.clipsToBounds = true
//        
//        backImageView.layer.cornerRadius = 15
//        backImageView.clipsToBounds = true
//        
//        // Initial border state
//        contentContainer.layer.borderWidth = 1.0
//        contentContainer.layer.borderColor = UIColor.systemGray5.cgColor
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        alpha = 1.0
//        isUserInteractionEnabled = true
//        contentContainer.isHidden = false
//        
//        // Reset border to default, not orange, so it only shows orange when selected
//        contentContainer.layer.borderWidth = 1.0
//        contentContainer.layer.borderColor = UIColor.systemGray5.cgColor
//
//        frontLabel.isHidden = true
//        backImageView.isHidden = false
//        showingFront = false
//    }
//
//    // UPDATED: Added isSelected parameter
//    func configure(with card: Card, isSelected: Bool) {
//        frontLabel.text = card.content
//        
//        // 2. Handle Matched State Visuals
//        if card.isMatched {
//            frontLabel.isHidden = false
//            backImageView.isHidden = true
//            contentView.alpha = 0.4 // Slightly faded
//        } else {
//            contentView.alpha = 1.0
//            frontLabel.isHidden = !card.isFlipped
//            backImageView.isHidden = card.isFlipped
//        }
//
//        // 3. Selection Logic (Applies to ALL cards)
//        if isSelected {
//            contentContainer.layer.borderWidth = 3.0 // Thicker to stand out
//            contentContainer.layer.borderColor = UIColor.orange.cgColor
//        } else {
//            contentContainer.layer.borderWidth = 1.0
//            contentContainer.layer.borderColor = card.isMatched ? UIColor.clear.cgColor : UIColor.systemGray5.cgColor
//        }
//    }
//    
//    // ... keep your flip() and revealForHint() methods as they are ...

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
