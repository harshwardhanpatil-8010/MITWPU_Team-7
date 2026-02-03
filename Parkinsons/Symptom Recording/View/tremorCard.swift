import UIKit

class tremorCard: UICollectionViewCell {

    @IBOutlet weak var cardBackground: UIView!
    
    @IBOutlet weak var tremorValueLabel: UILabel!
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
    }
    func configure(frequencyHz: Double?) {
        if let hz = frequencyHz {
            tremorValueLabel.text = String(format: "%.1f Hz", hz)
            tremorValueLabel.textColor = .black
        } else {
            tremorValueLabel.text = "Steady"
            tremorValueLabel.textColor = .label
        }
    }

   
}
