import UIKit

class CalenderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var calenderDate: UILabel!
    @IBOutlet weak var calenderBackground: UIView!
    @IBOutlet weak var calenderDay: UILabel!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        setupShadow()
    }
    
    private func setupShadow() {
        calenderBackground.layer.cornerRadius = 17.8
        
        calenderBackground.layer.masksToBounds = false
        
        calenderBackground.layer.shadowColor = UIColor.black.cgColor
        calenderBackground.layer.shadowOpacity = 0.1
        calenderBackground.layer.shadowRadius = 3
        calenderBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func configure(with model: DateModel, isSelected: Bool, isToday: Bool) {
        calenderDay.text = model.dayString
        calenderDate.text = model.dateString
        
        // Check if the date is in the future
        let isFuture = model.date > Date() && !Calendar.current.isDateInToday(model.date)
        
        // Reset defaults
        calenderBackground.backgroundColor = .white
        calenderDay.textColor = .lightGray
        calenderDate.textColor = .black
        calenderBackground.alpha = 1.0 // Reset opacity
        
        if isFuture {
            // Grayed out state for future dates
            calenderDate.textColor = .systemGray4
            calenderDay.textColor = .systemGray4
            calenderBackground.backgroundColor = UIColor.systemGray6
            calenderBackground.alpha = 0.6
            return // Skip selection/today styling for future dates
        }

        if isSelected {
            calenderDay.textColor = .white
            calenderDate.textColor = .white
            calenderBackground.backgroundColor = .systemBlue
            return
        }
        
        if isToday {
            calenderDay.textColor = .systemBlue
            calenderDate.textColor = .systemBlue
            return
        }
    }
}
