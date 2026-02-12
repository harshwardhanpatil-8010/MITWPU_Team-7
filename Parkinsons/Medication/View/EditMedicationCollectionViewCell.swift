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
        
        titleLabel.text = medication.medicationName
        subtitleLabel.text = medication.medicationForm
        
        medIcon.image = UIImage(
            named: medication.medicationIconName ?? ""
        ) ?? UIImage(named: "tablet")

        let doseCount = medication.doses?.count ?? 0
        frequencyLabel.text = "\(doseCount)x day"
        
        scheduleLabel.text = Medication.scheduleDisplayText(
            type: medication.medicationScheduleType ?? "none",
            days: medication.medicationScheduleDays as? [Int]
        )

    }
}
extension Medication {

    static func scheduleDisplayText(type: String, days: [Int]?) -> String {

        switch type {

        case "everyday":
            return "Everyday"

        case "weekly":
            guard let days = days, !days.isEmpty else {
                return "Weekly"
            }

            let formatter = DateFormatter()
            let weekdaySymbols = formatter.weekdaySymbols ?? []

            let names = days.compactMap { day -> String? in
                guard day >= 1 && day <= 7 else { return nil }
                return weekdaySymbols[day - 1]
            }

            return names.joined(separator: ", ")

        case "none":
            return "—"

        default:
            return "—"
        }
    }
}


