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
        // Initialization code
    }
//    private func setupBlurBackground() {
//            // Create a blur effect
//            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
//            let blurView = UIVisualEffectView(effect: blurEffect)
//            
//            // Set opacity to make it "a little opaque" as requested
//            blurView.alpha = 0.2
//            
//            blurView.frame = self.bounds
//            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            
//            // Add it as the bottom-most layer so text remains clear
//            self.insertSubview(blurView, at: 1)
//            self.backgroundColor = .clear
//        }\
    private func setupBlurBackground() {
        // 1. Clean up existing views
        self.subviews.filter({ $0 is UIVisualEffectView }).forEach({ $0.removeFromSuperview() })
        
        // 2. Use .systemMaterial to get that thicker, "opaque white" feel
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        // 3. SET ALPHA TO 1.0 (or 0.98)
        // 0 makes it invisible. 1.0 makes it fully opaque.
        blurView.alpha = 1.0
        
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 4. Ensure it's behind your titleLabel
        self.insertSubview(blurView, at: 0)
        
        // 5. Explicitly set the view's background to clear so the blur shows through
        self.backgroundColor = .clear
    }
}
