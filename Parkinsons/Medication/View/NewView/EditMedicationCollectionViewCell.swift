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

    private let shortWeekdays = "MTWTFSS"

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.applyCardStyle()
    }

    func configure(with medication: Medication) {
        titleLabel.text = medication.name
        subtitleLabel.text = "1 \(medication.form.lowercased())"
        medIcon.image = UIImage(named: medication.iconName) ?? UIImage(named: "tablet")


        switch medication.schedule {
        case .everyday:
            scheduleLabel.text = "Everyday"

        case .none:
            scheduleLabel.text = "None"

        case .weekly:
            scheduleLabel.attributedText = medication.schedule.weekdayAttributedString()

        }
    }

    private func makeWeekdayAttributedText(selectedDays: [Int]) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: shortWeekdays)

        let normalColor: UIColor = .systemGray3
        let selectedColor: UIColor = .systemBlue

        attributed.addAttribute(
            .foregroundColor,
            value: normalColor,
            range: NSRange(location: 0, length: shortWeekdays.count)
        )
        
        for day in selectedDays {
            let index = weekdayIndex(from: day)
            guard index >= 0 && index < shortWeekdays.count else { continue }

            attributed.addAttribute(
                .foregroundColor,
                value: selectedColor,
                range: NSRange(location: index, length: 1)
            )
        }

        return attributed
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

