//
//  MyMedicationCollectionViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class MyMedicationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var medContainer: UIView!
    @IBOutlet weak var medImage: UIImageView!
    @IBOutlet weak var medRepeat: UILabel!
    @IBOutlet weak var medUnitandForm: UILabel!
    @IBOutlet weak var medTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        medContainer.layer.cornerRadius = 16
    }
}

extension MyMedicationCollectionViewCell {

    func configure(with medication: Medication) {

        medTitle.text = medication.medicationName
        medUnitandForm.text = medication.medicationForm

        let doseCount = medication.doses?.count ?? 0

        medImage.image = UIImage(
            named: medication.medicationIconName ?? ""
        ) ?? UIImage(systemName: "pills")

        guard let scheduleType = medication.medicationScheduleType else {
            medRepeat.text = "—"
            return
        }

        switch scheduleType {

        case "everyday":
            medRepeat.text = "Everyday"
            medRepeat.textColor = .label

        case "weekly":
            if let days = medication.medicationScheduleDays as? [Int] {
                let symbols = Calendar.current.shortWeekdaySymbols

                let text = days.sorted().compactMap {
                    symbols[safe: $0 - 1]
                }.joined(separator: ", ")

                medRepeat.text = text
            } else {
                medRepeat.text = "Weekly"
            }

        case "none":
            medRepeat.text = "—"
            medRepeat.textColor = .systemGray3

        default:
            medRepeat.text = "—"
        }
    }

}
