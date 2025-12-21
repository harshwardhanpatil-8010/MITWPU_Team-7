import UIKit

class CalenderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var calenderDate: UILabel!
    @IBOutlet weak var calenderBackground: UIView!
    @IBOutlet weak var calenderDay: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with model: DateModel, isSelected: Bool, isToday: Bool) {
        calenderDay.text = model.dayString
        calenderDate.text = model.dateString
        calenderBackground.layer.cornerRadius = 17.8
        
        // Reset to default
        calenderBackground.backgroundColor = .clear
        calenderDay.backgroundColor = .clear
        calenderDay.textColor = .lightGray
        calenderDate.textColor = .black

        if isSelected {
            calenderDay.textColor = .black
            calenderDate.textColor = .white
            calenderBackground.backgroundColor = .systemCyan
            return
        }
        
        if isToday {
            calenderDay.textColor = .systemCyan
            calenderDate.textColor = .systemCyan
            return
        }
    }
}
