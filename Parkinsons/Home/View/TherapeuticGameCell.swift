

import UIKit

class TherapeuticGameCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var completionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    private let whackMoleHoleImageView = UIImageView()


    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        setupCardStyle()
        setupWhackMoleHoleIcon()
    }

    private func setupCardStyle() {
        backgroundCardView.layer.cornerRadius = 23
        backgroundCardView.layer.masksToBounds = false
        backgroundCardView.backgroundColor = .secondarySystemGroupedBackground
        backgroundCardView.layer.shadowColor = UIColor(red: 0.04, green: 0.06, blue: 0.15, alpha: 1.0).cgColor
        backgroundCardView.layer.shadowOpacity = 0.05
        backgroundCardView.layer.shadowRadius = 16
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        backgroundCardView.layer.borderWidth = 1.0
        backgroundCardView.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.85).cgColor
    }

    private func setupWhackMoleHoleIcon() {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        whackMoleHoleImageView.image = UIImage(systemName: "oval.fill", withConfiguration: config)
        whackMoleHoleImageView.tintColor = .systemGreen
        whackMoleHoleImageView.contentMode = .scaleToFill
        whackMoleHoleImageView.translatesAutoresizingMaskIntoConstraints = false
        whackMoleHoleImageView.isHidden = true
        contentView.addSubview(whackMoleHoleImageView)

        NSLayoutConstraint.activate([
            whackMoleHoleImageView.widthAnchor.constraint(equalToConstant: 22),
            whackMoleHoleImageView.heightAnchor.constraint(equalToConstant: 6),
            whackMoleHoleImageView.trailingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 1),
            whackMoleHoleImageView.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: -3)
        ])
    }

    func configure(with model: TherapeuticGameModel, completionText: String, isTodayCompleted: Bool) {
        titleLabel.text = model.title

        completionLabel.text = completionText

        iconImageView.image = UIImage(systemName: model.iconName ?? "")
        iconImageView.tintColor = model.iconColor
        whackMoleHoleImageView.isHidden = model.title != "Whack a Mole"
        whackMoleHoleImageView.tintColor = model.iconColor
    }
}
