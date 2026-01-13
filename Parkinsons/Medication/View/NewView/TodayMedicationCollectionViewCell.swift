//
//  TodayMedicationCollectionViewCell.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 11/01/26.
//

import UIKit

class TodayMedicationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var medUnitAndTypeLabel: UILabel!
    @IBOutlet weak var medNameLabel: UILabel!
    @IBOutlet weak var medFormImage: UIImageView!
    @IBOutlet weak var timeAmPmLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var medContainerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        medContainerView.applyCardStyle()
    }
    func configure(with dose: TodayDoseItem) {

            medNameLabel.text = dose.medicationName
            medUnitAndTypeLabel.text = dose.medicationForm

            // Icon
            medFormImage.image = UIImage(named: dose.iconName)

            // Time formatting
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm"

            timeLabel.text = formatter.string(from: dose.scheduledTime)

            formatter.dateFormat = "a"
            timeAmPmLabel.text = formatter.string(from: dose.scheduledTime)

            // Optional visual state (future-proof)
            switch dose.logStatus {
            case .none:
                medContainerView.alpha = 1.0
            case .taken, .skipped:
                medContainerView.alpha = 0.5
            }
        }

}
