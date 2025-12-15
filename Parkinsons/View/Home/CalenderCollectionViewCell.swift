//
//  CalenderCollectionViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class CalenderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var calenderDate: UILabel!
    @IBOutlet weak var calenderBackground: UIView!
    @IBOutlet weak var calenderDay: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(with model: DateModel, isSelected: Bool, isToday: Bool) {
        calenderDay.text = model.dayString
        calenderDate.text = model.dateString
        calenderBackground.layer.cornerRadius = 18.5
        
        // Reset to default
        calenderBackground.backgroundColor = .clear
                calenderDay.backgroundColor = .clear // Crucial: Resetting the day label's background
                
                calenderDay.textColor = .lightGray
                calenderDate.textColor = .black


        if isSelected {
            calenderDay.textColor = .black // <-- ADD THIS LINE
            calenderDate.textColor = .white
            calenderBackground.backgroundColor = .systemCyan
            return
        }
        
        // ... isToday block remains the same ...
        if isToday {
            //calenderDay.backgroundColor = UIColor(red: 1.0, green: 0.85, blue: 0.70, alpha: 1.0) // Light orange
            calenderDay.textColor = .systemCyan // <-- You might need this too for the Today state
            calenderDate.textColor = .systemCyan
            return
        }
    }
}
