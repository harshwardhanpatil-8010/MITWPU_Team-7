import UIKit

class TherapeuticGameCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var completionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        setupCardStyle()
    }

    private func setupCardStyle() {
        backgroundCardView.layer.cornerRadius = 23
        backgroundCardView.layer.masksToBounds = false
        backgroundCardView.layer.shadowColor = UIColor.black.cgColor
        backgroundCardView.layer.shadowOpacity = 0.15
        backgroundCardView.layer.shadowRadius = 3
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
    }

    func configure(with model: TherapeuticGameModel, completionText: String, isTodayCompleted: Bool) {
        titleLabel.text = model.title

        completionLabel.text = completionText

        iconImageView.image = UIImage(systemName: model.iconName ?? "")
             iconImageView.tintColor = model.iconColor
    }
}
