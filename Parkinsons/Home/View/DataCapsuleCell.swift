import UIKit

class DateCapsuleCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateNumberLabel: UILabel!

    override func awakeFromNib() {
            super.awakeFromNib()
            self.clipsToBounds = false
            self.contentView.clipsToBounds = false
            
        containerView.layer.cornerRadius = 20
            containerView.layer.masksToBounds = false
            
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOpacity = 0.1
            containerView.layer.shadowRadius = 3
            containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            containerView.layer.borderWidth = 0
        }

        func configure(with model: DateModel, isSelected: Bool, isToday: Bool) {
            dateNumberLabel.text = model.dateString
            dateNumberLabel.textAlignment = .center
            
            containerView.backgroundColor = .white
            dateNumberLabel.textColor = .black
            
            if isSelected {
                containerView.backgroundColor = .systemBlue
                dateNumberLabel.textColor = .white
                return
            }
            
            if isToday {
                dateNumberLabel.textColor = .systemBlue
            }
        }
    }
