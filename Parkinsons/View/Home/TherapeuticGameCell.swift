import UIKit

class TherapeuticGameCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var backgroundCardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        setupCardStyle()
    }
    
    func setupCardStyle() {
        let cornerRadius: CGFloat = 16
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.15
        let shadowRadius: CGFloat = 3
        let shadowOffset: CGSize = .init(width: 0, height: 1)

        backgroundCardView.layer.cornerRadius = cornerRadius
        backgroundCardView.layer.masksToBounds = false

        backgroundCardView.layer.shadowColor = shadowColor.cgColor
        backgroundCardView.layer.shadowOpacity = shadowOpacity
        backgroundCardView.layer.shadowRadius = shadowRadius
        backgroundCardView.layer.shadowOffset = shadowOffset
    }
    
    func configure(with model: TherapeuticGameModel) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        
        if let imageName = model.iconName {
            iconImageView.image = UIImage(named: imageName)
            iconImageView.tintColor = nil
        }
    }
}
