import UIKit

class MedicationSummaryCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amPmLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var medicationIconImageView: UIImageView!
    @IBOutlet weak var backgroundCardView: UIView!
    
    static let reuseIdentifier = "MedicationSummaryCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        setupCardStyle()
        
        medicationIconImageView.layer.cornerRadius = medicationIconImageView.frame.height / 2.0
        medicationIconImageView.clipsToBounds = true
    }

    func setupCardStyle() {
        let cornerRadius: CGFloat = 12
        backgroundCardView.layer.cornerRadius = cornerRadius
        backgroundCardView.layer.masksToBounds = false
        backgroundCardView.layer.shadowColor = UIColor.black.cgColor
        backgroundCardView.layer.shadowOpacity = 0.1
        backgroundCardView.layer.shadowRadius = 8
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundCardView.layer.shadowPath = UIBezierPath(
            roundedRect: backgroundCardView.bounds,
            cornerRadius: backgroundCardView.layer.cornerRadius
        ).cgPath
        medicationIconImageView.layer.cornerRadius = medicationIconImageView.frame.height / 2.0
    }
    
    func configure(with model: MedicationModel, totalTaken: Int, totalScheduled: Int) {
        let timeParts = model.time.split(separator: " ")
        timeLabel.text = String(timeParts.first ?? "9:00")
        amPmLabel.text = String(timeParts.last ?? "AM")
        
        nameLabel.text = model.name
        detailLabel.text = model.detail
        medicationIconImageView.image = UIImage(named: model.iconName)
        
        if model.status == .skipped {
            statusLabel.attributedText = imageAttachment(systemName: "xmark", color: .systemRed)
            statusLabel.textColor = .systemRed
        } else if model.status == .taken {
            statusLabel.attributedText = imageAttachment(systemName: "checkmark", color: .systemGreen)
            statusLabel.textColor = .systemGreen
        } else {
            if totalScheduled == 0 {
                statusLabel.text = "--"
                statusLabel.textColor = .systemGray
            } else if totalTaken == totalScheduled {
                statusLabel.attributedText = imageAttachment(systemName: "checkmark", color: .systemGreen)
                statusLabel.textColor = .systemGreen
            } else {
                statusLabel.attributedText = imageAttachment(systemName: "checkmark", color: .systemGreen)
                statusLabel.textColor = .systemOrange
            }
        }
    }

    func imageAttachment(systemName: String, color: UIColor) -> NSAttributedString {
        let attachment = NSTextAttachment()
        
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        let image = UIImage(systemName: systemName, withConfiguration: config)?.withTintColor(color, renderingMode: .alwaysOriginal)
        
        attachment.image = image
        
        return NSAttributedString(attachment: attachment)
    }
}
