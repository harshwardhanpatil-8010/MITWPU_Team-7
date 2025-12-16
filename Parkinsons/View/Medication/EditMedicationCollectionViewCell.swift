//
//  EditMedicationCollectionViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class EditMedicationCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var medIcon: UIImageView!
    @IBOutlet weak var cardView: UIView!

    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round card corners
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        
        // Apply shadow + card styling
        applyCardStyle()
    }
    
    // MARK: - UI Helpers
    /// Converts weekday number (1...7) to short weekday name.
    private func weekdayName(_ n: Int) -> String {
        let names = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return names[n - 1]
    }
    
    /// Applies drop‑shadow and white card styling.
    
    // MARK: - Configure Cell
    /// Populates the cell UI with medication data.
    func configure(with medication: Medication) {
        
        // Title + subtitle
        titleLabel.text = medication.name
        subtitleLabel.text = "1 \(medication.form.lowercased())"
        
        // Icon
        medIcon.image = UIImage(named: medication.iconName)
        
        // Schedule text
        switch medication.schedule {
        case .everyday:
            scheduleLabel.text = "Everyday"
            
        case .none:
            scheduleLabel.text = "None"
            
        case .weekly(let days):
            scheduleLabel.text =
                days.map { weekdayName($0) }.joined(separator: ", ")
        }
        
//
//        if let firstDose = medication.doses.first {
//            let fmt = DateFormatter()
//            fmt.dateFormat = "h:mm a"
//            timeLabel.text = fmt.string(from: firstDose.time)
//        }
//        
//        ampmLabel.isHidden = true
    }
}
