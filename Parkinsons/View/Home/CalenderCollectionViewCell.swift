import UIKit

class CalenderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var calenderDate: UILabel!
    @IBOutlet weak var calenderBackground: UIView!
    @IBOutlet weak var calenderDay: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Ensure the cell itself doesn't clip the shadow
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        setupShadow()
    }
    
    private func setupShadow() {
        calenderBackground.layer.cornerRadius = 17.8
        
        // 1. Shadows require masksToBounds to be false
        calenderBackground.layer.masksToBounds = false
        
        // 2. Apply the shadow properties
        calenderBackground.layer.shadowColor = UIColor.black.cgColor
        calenderBackground.layer.shadowOpacity = 0.1
        calenderBackground.layer.shadowRadius = 3
        calenderBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func configure(with model: DateModel, isSelected: Bool, isToday: Bool) {
        calenderDay.text = model.dayString
        calenderDate.text = model.dateString
        
        // Reset to default
        calenderBackground.backgroundColor = .white // Shadow needs a background color to be visible
        calenderDay.textColor = .lightGray
        calenderDate.textColor = .black
        
        // Reset Border (if you used the blue border from earlier)
        calenderBackground.layer.borderWidth = 0
        calenderBackground.layer.borderColor = nil

        if isSelected {
            calenderDay.textColor = .white
            calenderDate.textColor = .white
            calenderBackground.backgroundColor = .systemBlue
            return
        }
        
        if isToday {
            calenderDay.textColor = .systemBlue
            calenderDate.textColor = .systemBlue
            
            // Adding the blue border for "Today" as requested previously
            calenderBackground.layer.borderWidth = 2.0
            calenderBackground.layer.borderColor = UIColor.systemBlue.cgColor
            return
        }
    }
}
