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
        let cornerRadius: CGFloat = 16
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
    
    func configure(with model: MedicationModel) {
        timeLabel.text = model.time
        nameLabel.text = model.name
        detailLabel.text = model.detail

    }
}
