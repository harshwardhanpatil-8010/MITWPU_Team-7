//
//  TodayMedicationCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class TodayMedicationCell: UICollectionViewCell {
    @IBOutlet weak var timeNumberLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var ampmLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    var onChevronTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        applyCardStyle()
        containerView.layer.cornerRadius = 16
    }

    func configure(with dose: MedicationDose, medication: Medication) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let fullTime = formatter.string(from: dose.time)
        let components = fullTime.split(separator: " ")

        timeNumberLabel.text = String(components[0])
        ampmLabel.text = String(components[1])

        titleLabel.text = medication.name
        subtitleLabel.text = medication.form
        iconImageView.image = UIImage(named: medication.iconName)

        switch dose.status {
        case .taken:
            statusImageView.image = UIImage(systemName: "checkmark")
            statusImageView.tintColor = .systemGreen
        case .skipped:
            statusImageView.image = UIImage(systemName: "xmark")
            statusImageView.tintColor = .systemRed
        case .none:
            if Date() > dose.time {
                statusImageView.image = UIImage(named: "Due")
                statusImageView.tintColor = nil
            } else {
                statusImageView.image = UIImage(systemName: "circle")
                statusImageView.tintColor = .systemGray5
            }
        }
    }
}
