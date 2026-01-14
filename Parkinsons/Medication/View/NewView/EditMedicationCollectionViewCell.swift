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

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.applyCardStyle()
    }

    private func weekdayName(_ n: Int) -> String {
        let names = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return names[n - 1]
    }

    func configure(with medication: Medication) {
        titleLabel.text = medication.name
        subtitleLabel.text = "1 \(medication.form.lowercased())"
        medIcon.image = UIImage(named: medication.iconName)

        switch medication.schedule {
        case .everyday:
            scheduleLabel.text = "Everyday"
        case .none:
            scheduleLabel.text = "None"
        case .weekly(let days):
            scheduleLabel.text = days.map { weekdayName($0) }.joined(separator: ", ")
        }
    }
}
