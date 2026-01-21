//
//  EditMedicationCollectionViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class EditMedicationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var medIcon: UIImageView!
    @IBOutlet weak var cardView: UIView!


    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.applyCardStyle()
        cardView.layer.cornerRadius = 20
    }

    func configure(with medication: Medication) {
        titleLabel.text = medication.name
        subtitleLabel.text = medication.form
        medIcon.image = UIImage(named: medication.iconName) ?? UIImage(named: "tablet")

        frequencyLabel.text = "\(medication.doses.count)x day"
        switch medication.schedule {
        case .everyday:
            scheduleLabel.text = "Everyday"

        case .none:
            scheduleLabel.text = "None"

        case .weekly:
            scheduleLabel.text = medication.schedule.displayString()
        }
    }

    private func weekdayIndex(from weekday: Int) -> Int {
        switch weekday {
        case 2: return 0
        case 3: return 1
        case 4: return 2
        case 5: return 3
        case 6: return 4
        case 7: return 5
        case 1: return 6
        default: return -1
        }
    }
}

