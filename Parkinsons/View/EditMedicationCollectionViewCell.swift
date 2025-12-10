//
//  EditMedicationCollectionViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class EditMedicationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var medIcon: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var ampmLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
    }
    
    func configure(with dose: MedicationDose) {
            
            // time
            let fmt = DateFormatter()
            fmt.dateFormat = "h:mm"
            timeLabel.text = fmt.string(from: dose.time)
            
            fmt.dateFormat = "a"
            ampmLabel.text = fmt.string(from: dose.time)
            
            // title + subtitle
            titleLabel.text = dose.medication.name
            subtitleLabel.text = "1 \(dose.medication.form.lowercased())"
            
            // schedule
            scheduleLabel.text = dose.medication.schedule
            
            // icon
            medIcon.image = UIImage(named: dose.medication.iconName ?? "")
        }

}


