import UIKit

protocol MedicationCardDelegate: AnyObject {
    func didTapTaken(for dose: TodayDoseItem)
    func didTapSkipped(for dose: TodayDoseItem)
}

class MedicationCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var BackgroundMedication: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var takenButton: UIButton!
    @IBOutlet weak var skippedButton: UIButton!
    @IBOutlet weak var noMedicationLabelStack: UIStackView!
    
    weak var delegate: MedicationCardDelegate?
    private var currentDose: TodayDoseItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardStyle()
        takenButton.layer.cornerRadius = 18
        skippedButton.layer.cornerRadius = 18
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        iconImageView.clipsToBounds = true
    }
    
    @IBAction func takenTapped(_ sender: Any) {
        guard let dose = currentDose else { return }
        delegate?.didTapTaken(for: dose)
    }
    
    @IBAction func skippedTapped(_ sender: Any) {
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
        currentDose = dose
        
        noMedicationLabelStack.isHidden = true
        BackgroundMedication.isHidden = false
        nameLabel.isHidden = false
        timeLabel.isHidden = false
        detailLabel.isHidden = false
        iconImageView.isHidden = false
        takenButton.isHidden = false
        skippedButton.isHidden = false
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeLabel.text = formatter.string(from: dose.scheduledTime)
        
        nameLabel.text = dose.medicationName
        detailLabel.text = dose.medicationForm
        iconImageView.image = UIImage(named: dose.iconName)
        
        isUserInteractionEnabled = true
    }
    
    func configureEmptyState() {
        currentDose = nil
        noMedicationLabelStack.isHidden = false
        BackgroundMedication.isHidden = true
        nameLabel.isHidden = true
        timeLabel.isHidden = true
        detailLabel.isHidden = true
        iconImageView.isHidden = true
        takenButton.isHidden = true
        skippedButton.isHidden = true
        
        isUserInteractionEnabled = false
    }
}
