import UIKit

class tremorCard: UICollectionViewCell {

//    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var cardBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Match MedicationCard: Disable clipping to allow shadows to show
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        setupCardStyle()
    }
    
    func setupCardStyle() {
        // Exact same parameters from MedicationCardCollectionViewCell
        let cornerRadius: CGFloat = 25
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.15
        let shadowRadius: CGFloat = 3
        let shadowOffset: CGSize = .init(width: 0, height: 1)

        cardBackground.layer.cornerRadius = cornerRadius
        cardBackground.layer.masksToBounds = false // Important for shadow visibility

        cardBackground.layer.shadowColor = shadowColor.cgColor
        cardBackground.layer.shadowOpacity = shadowOpacity
        cardBackground.layer.shadowRadius = shadowRadius
        cardBackground.layer.shadowOffset = shadowOffset
    }
    
    // Optional: Add a configure method like your other cells
//    func configure(average: String) {
//        avgLabel.text = average
//    }
}
