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
        
        // Check the INDIVIDUAL status first
        if model.status == .skipped {
            // Individual Skip: Red X
            statusLabel.attributedText = imageAttachment(systemName: "xmark")
            statusLabel.textColor = .systemRed
        } else if model.status == .taken {
            // Individual Taken: Green Check
            statusLabel.attributedText = imageAttachment(systemName: "checkmark")
            statusLabel.textColor = .systemGreen
        } else {
            // Fallback to your progress logic if status is none
            if totalScheduled == 0 {
                statusLabel.text = "--"
                statusLabel.textColor = .systemGray
            } else if totalTaken == totalScheduled {
                statusLabel.attributedText = imageAttachment(systemName: "checkmark.circle.fill")
                statusLabel.textColor = .systemGreen
            } else {
                statusLabel.attributedText = imageAttachment(systemName: "checkmark")
                statusLabel.textColor = .systemOrange
            }
        }
    }

    private func imageAttachment(systemName: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        attachment.image = UIImage(systemName: systemName, withConfiguration: configuration)
        return NSAttributedString(attachment: attachment)
    }
}
