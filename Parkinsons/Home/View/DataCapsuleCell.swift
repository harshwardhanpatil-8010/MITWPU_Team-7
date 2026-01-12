import UIKit

class DateCapsuleCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Half of the height (65 / 2 = 32.5) creates the perfect capsule shape
        //containerView.layer.cornerRadius = containerView.frame.height / 2
        containerView.layer.masksToBounds = true
    }

//    func configure(with model: DayModel) {
////        dayLetterLabel.text = model.dayLetter
//        dateNumberLabel.text = model.dayNumber
//
//        // Style based on selection
//        containerView.backgroundColor = model.isSelected ? .systemBlue : .white
////        dayLetterLabel.textColor = model.isSelected ? .white : .secondaryLabel
//        dateNumberLabel.textColor = model.isSelected ? .white : .label
//        containerView.layer.borderColor = model.isSelected ? UIColor.systemBlue.cgColor : UIColor.systemGray5.cgColor
//    }
    func configure(with model: DateModel, isSelected: Bool, isToday: Bool) {
        // Only set the date number
        dateNumberLabel.text = model.dateString
        dateNumberLabel.textAlignment = .center
        
        // Selection styling
        containerView.backgroundColor = isSelected ? .systemBlue : .white
        dateNumberLabel.textColor = isSelected ? .white : .black
        
    }
}
