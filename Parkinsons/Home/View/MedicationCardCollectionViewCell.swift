protocol MedicationCardDelegate: AnyObject {
    func didTapTaken(for dose: TodayDoseItem)
    func didTapSkipped(for dose: TodayDoseItem)
}

import UIKit

class MedicationCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var BackgroundMedication: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var takenButton: UIButton!
    @IBOutlet weak var skippedButton: UIButton!
    
    weak var delegate: MedicationCardDelegate?
    private var currentDose: TodayDoseItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true
        BackgroundMedication.isUserInteractionEnabled = true
        
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

    @IBAction func takenTapped(_ sender: Any) {
        print("Button Action: Taken Tapped")
        guard let dose = currentDose else { return }
        delegate?.didTapTaken(for: dose)
    }

    @IBAction func skippedTapped(_ sender: Any) {
        print("Button Action: Skipped Tapped")
        guard let dose = currentDose else { return }
        delegate?.didTapSkipped(for: dose)
    }

    func setupCardStyle() {
        BackgroundMedication.layer.cornerRadius = 23
        BackgroundMedication.layer.masksToBounds = false
        BackgroundMedication.layer.shadowColor = UIColor.black.cgColor
        BackgroundMedication.layer.shadowOpacity = 0.15
        BackgroundMedication.layer.shadowRadius = 3
        BackgroundMedication.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func configure(with dose: TodayDoseItem) {
        self.currentDose = dose 
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeLabel.text = formatter.string(from: dose.scheduledTime)
        
        nameLabel.text = dose.medicationName
        detailLabel.text = dose.medicationForm
        iconImageView.image = UIImage(named: dose.iconName)
        
        if dose.logStatus != .none {
            self.contentView.alpha = 0.0
            self.isHidden = true
        } else {
            self.contentView.alpha = 1.0
            self.isHidden = false
        }
    }
}
