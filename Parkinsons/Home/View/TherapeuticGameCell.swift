////import UIKit
////
////class TherapeuticGameCell: UICollectionViewCell {
////    
////    @IBOutlet weak var titleLabel: UILabel!
////    @IBOutlet weak var descriptionLabel: UILabel!
////    @IBOutlet weak var iconImageView: UIImageView!
////    @IBOutlet weak var backgroundCardView: UIView!
////    
////    override func awakeFromNib() {
////        super.awakeFromNib()
////        
////        self.clipsToBounds = false
////        self.contentView.clipsToBounds = false
////        
////        setupCardStyle()
////    }
////    
////    func setupCardStyle() {
////        let cornerRadius: CGFloat = 23
////        let shadowColor: UIColor = .black
////        let shadowOpacity: Float = 0.15
////        let shadowRadius: CGFloat = 3
////        let shadowOffset: CGSize = .init(width: 0, height: 1)
////
////        backgroundCardView.layer.cornerRadius = cornerRadius
////        backgroundCardView.layer.masksToBounds = false
////
////        backgroundCardView.layer.shadowColor = shadowColor.cgColor
////        backgroundCardView.layer.shadowOpacity = shadowOpacity
////        backgroundCardView.layer.shadowRadius = shadowRadius
////        backgroundCardView.layer.shadowOffset = shadowOffset
////    }
////    
////    func configure(with model: TherapeuticGameModel) {
////        titleLabel.text = model.title
////        descriptionLabel.text = model.description
////        
////        if let imageName = model.iconName {
////            iconImageView.image = UIImage(named: imageName)
////            iconImageView.tintColor = nil
////        }
////    }
////}
//
//
//
//
//
//import UIKit
//
//class TherapeuticGameCell: UICollectionViewCell {
//
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var backgroundCardView: UIView!
//    
//    @IBOutlet weak var completionLabel: UILabel!
//    
//    // Badge: [orange circle ✓]  [X/Y]
//    private let badgeContainer: UIView = {
//        let v = UIView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.isHidden = true
//        return v
//    }()
//
//    private let badgeCircle: UIView = {
//        let v = UIView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.backgroundColor = UIColor(hex: "F0B673")
//        v.layer.cornerRadius = 14
//        v.clipsToBounds = true
//        return v
//    }()
//
//    private let badgeCheckmark: UIImageView = {
//        let iv = UIImageView()
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
//        iv.image = UIImage(systemName: "checkmark", withConfiguration: config)
//        iv.tintColor = .white
//        iv.contentMode = .scaleAspectFit
//        return iv
//    }()
//
//    private let badgeLabel: UILabel = {
//        let l = UILabel()
//        l.translatesAutoresizingMaskIntoConstraints = false
//        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        l.textColor = .label
//        return l
//    }()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.clipsToBounds = false
//        self.contentView.clipsToBounds = false
//        setupCardStyle()
//        setupBadgeView()
//    }
//
//    private func setupCardStyle() {
//        backgroundCardView.layer.cornerRadius = 23
//        backgroundCardView.layer.masksToBounds = false
//        backgroundCardView.layer.shadowColor = UIColor.black.cgColor
//        backgroundCardView.layer.shadowOpacity = 0.15
//        backgroundCardView.layer.shadowRadius = 3
//        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
//    }
//
//    private func setupBadgeView() {
//        badgeCircle.addSubview(badgeCheckmark)
//        badgeContainer.addSubview(badgeCircle)
//        badgeContainer.addSubview(badgeLabel)
//        backgroundCardView.addSubview(badgeContainer)
//
//        NSLayoutConstraint.activate([
//            // Checkmark inside circle
//            badgeCheckmark.centerXAnchor.constraint(equalTo: badgeCircle.centerXAnchor),
//            badgeCheckmark.centerYAnchor.constraint(equalTo: badgeCircle.centerYAnchor),
//            badgeCheckmark.widthAnchor.constraint(equalToConstant: 12),
//            badgeCheckmark.heightAnchor.constraint(equalToConstant: 12),
//
//            // Circle size (28×28 matches screenshot)
//            badgeCircle.widthAnchor.constraint(equalToConstant: 28),
//            badgeCircle.heightAnchor.constraint(equalToConstant: 28),
//            badgeCircle.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor),
//            badgeCircle.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor),
//
//            // Label right of circle
//            badgeLabel.leadingAnchor.constraint(equalTo: badgeCircle.trailingAnchor, constant: 8),
//            badgeLabel.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor),
//            badgeLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor),
//
//            // Container height
//            badgeContainer.heightAnchor.constraint(equalToConstant: 28),
//
//            // Pin to card: left-aligned with title, below it
//            badgeContainer.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            badgeContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
//        ])
//    }
//
//    func configure(with model: TherapeuticGameModel) {
//        titleLabel.text = model.title
//
//        if let p = model.progress, p.completed > 0 {
//            descriptionLabel.isHidden = true
//            badgeContainer.isHidden = false
//            badgeLabel.text = "\(p.completed)/\(p.total)"
//        } else {
//            descriptionLabel.isHidden = false
//            badgeContainer.isHidden = true
//            descriptionLabel.text = model.description
//        }
//
////        if let imageName = model.iconName {
////            iconImageView.image = UIImage(named: imageName)
////            iconImageView.tintColor = nil
////        }
//    }
//}


import UIKit

class TherapeuticGameCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var completionLabel: UILabel!

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
        descriptionLabel.text = isTodayCompleted ? "Daily challenge completed!" : model.description
        completionLabel.text = completionText
    }
}
