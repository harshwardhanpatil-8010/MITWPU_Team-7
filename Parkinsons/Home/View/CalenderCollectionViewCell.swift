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
        
        calenderBackground.backgroundColor = .white
        calenderDay.textColor = .lightGray
        calenderDate.textColor = .black
        
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
            return
        }
    }
}
