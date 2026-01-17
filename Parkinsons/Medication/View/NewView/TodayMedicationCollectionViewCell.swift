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

    @IBOutlet weak var dueStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        medContainerView.applyCardStyle()
    }

    func configure(with dose: TodayDoseItem) {
        medNameLabel.text = dose.medicationName
        medUnitAndTypeLabel.text = dose.medicationForm
        medFormImage.image = UIImage(named: dose.iconName)

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        timeLabel.text = formatter.string(from: dose.scheduledTime)
        formatter.dateFormat = "a"
        timeAmPmLabel.text = formatter.string(from: dose.scheduledTime)

       
        dueStatus.isHidden = true
        medContainerView.alpha = 1.0
        medContainerView.layer.borderWidth = 0

        
        if dose.logStatus != .none {
            medContainerView.alpha = 0.5
            return
        }

      
        switch dose.dueState {
        case .dueNow:
            applyDueStyle(
                text: "Due",
                color: .systemOrange
            )

        case .late:
            applyDueStyle(
                text: "Due",
                color: .systemOrange
            )

        case .veryLate:
            applyDueStyle(
                text: "Due",
                color: .systemOrange
            )

        case .none:
            break
        }
    }
    private func applyDueStyle(text: String, color: UIColor) {
        dueStatus.isHidden = false
        dueStatus.text = text
        dueStatus.textColor = color
    }



}
