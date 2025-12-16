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
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.1
        let shadowRadius: CGFloat = 8
        let shadowOffset: CGSize = .init(width: 0, height: 4)

        backgroundCardView.layer.cornerRadius = cornerRadius
        backgroundCardView.layer.masksToBounds = false

        backgroundCardView.layer.shadowColor = shadowColor.cgColor
        backgroundCardView.layer.shadowOpacity = shadowOpacity
        backgroundCardView.layer.shadowRadius = shadowRadius
        backgroundCardView.layer.shadowOffset = shadowOffset
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
        medicationIconImageView.backgroundColor = .systemBlue
        medicationIconImageView.tintColor = .white
        
        let totalRemaining = totalScheduled - totalTaken
        
        if totalScheduled == 0 {
            statusLabel.text = "No meds scheduled"
            statusLabel.textColor = .systemGray
        } else if totalTaken == totalScheduled {
            let checkmarkImage = UIImage(systemName: "checkmark.circle.fill")
            let checkmarkAttachment = NSTextAttachment(image: checkmarkImage!)
            
            let attributedString = NSMutableAttributedString(string: "")
            attributedString.append(NSAttributedString(attachment: checkmarkAttachment))
            attributedString.append(NSAttributedString(string: " Completed"))
            
            statusLabel.attributedText = attributedString
            statusLabel.textColor = .systemGreen
            
        } else if totalTaken > 0 {
            statusLabel.attributedText = nil
            statusLabel.text = "\(totalTaken) / \(totalScheduled) taken"
            statusLabel.textColor = .systemOrange
        } else {
            statusLabel.attributedText = nil
            statusLabel.text = "\(totalScheduled) remaining"
            statusLabel.textColor = .systemRed
        }
    }
}
