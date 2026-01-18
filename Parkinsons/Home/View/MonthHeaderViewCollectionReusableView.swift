//
//  MonthHeaderViewCollectionReusableView.swift
//  Parkinsons
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

//class MonthHeaderViewCollectionReusableView: UICollectionReusableView {
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//    
//}

class MonthHeaderViewCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func setupBlurBackground() {
        self.subviews.filter({ $0 is UIVisualEffectView }).forEach({ $0.removeFromSuperview() })
        
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        

        blurView.alpha = 1.0
        
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.insertSubview(blurView, at: 0)
        
        self.backgroundColor = .clear
    }
}
