import UIKit

class MedicationCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var BackgroundMedication: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var takenButton: UIButton!
    @IBOutlet weak var skippedButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        setupCardStyle()
        
        takenButton.layer.cornerRadius = 18
        skippedButton.layer.cornerRadius = 18
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2.0
        iconImageView.clipsToBounds = true
    }
    
    func setupCardStyle() {
        let cornerRadius: CGFloat = 23
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.15
        let shadowRadius: CGFloat = 3
        let shadowOffset: CGSize = .init(width: 0, height: 1)

        BackgroundMedication.layer.cornerRadius = cornerRadius
        BackgroundMedication.layer.masksToBounds = false

        BackgroundMedication.layer.shadowColor = shadowColor.cgColor
        BackgroundMedication.layer.shadowOpacity = shadowOpacity
        BackgroundMedication.layer.shadowRadius = shadowRadius
        BackgroundMedication.layer.shadowOffset = shadowOffset
    }
    
    // MedicationCardCollectionViewCell.swift

    func configure(with dose: TodayDoseItem) {
        // 1. Format the Date into a String (e.g., "10:00 AM")
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeString = formatter.string(from: dose.scheduledTime)
        
        // 2. Set the labels
        nameLabel.text = dose.medicationName
        timeLabel.text = timeString
        detailLabel.text = dose.medicationForm
        
        // 3. Set the icon
        iconImageView.image = UIImage(named: dose.iconName)
        
        // 4. Handle the "Logged" state (Alpha Fading)
        if dose.logStatus != .none {
            self.contentView.alpha = 0.5
            takenButton.isHidden = true
            skippedButton.isHidden = true
        } else {
            self.contentView.alpha = 1.0
            takenButton.isHidden = false
            skippedButton.isHidden = false
        }
    }
}
