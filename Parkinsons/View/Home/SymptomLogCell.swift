import UIKit

protocol SymptomLogCellDelegate: AnyObject {
    func symptomLogCellDidTapLogNow(_ cell: SymptomLogCell)
}

class SymptomLogCell: UICollectionViewCell {
    
    weak var delegate: SymptomLogCellDelegate?

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logNowButton: UIButton!
    @IBOutlet weak var backgroundCardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        setupCardStyle()
        
        logNowButton.layer.cornerRadius = 15
        logNowButton.backgroundColor = UIColor.systemBlue
        logNowButton.setTitleColor(UIColor.white, for: .normal)
        
        logNowButton.addTarget(self, action: #selector(logNowButtonTapped), for: .touchUpInside)
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
    
    @objc private func logNowButtonTapped() {
        delegate?.symptomLogCellDidTapLogNow(self)
    }

    func configure(with message: String, buttonTitle: String) {
        descriptionLabel.text = message
        logNowButton.setTitle(buttonTitle, for: .normal)
    }
}
