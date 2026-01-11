//
//  LoggedMedicationCollectionViewCell.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 11/01/26.
//

import UIKit

class LoggedMedicationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var medContainerView: UIView!
    @IBOutlet weak var medUnitandformLabel: UILabel!
    @IBOutlet weak var medNameLabel: UILabel!
    @IBOutlet weak var medStatusImage: UIImageView!
    @IBOutlet weak var medFormImage: UIImageView!
    @IBOutlet weak var timeAmPmLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        medContainerView.applyCardStyle()
    }
    func configure(with item: LoggedDoseItem) {
            medNameLabel.text = item.medicationName

            // Time formatting
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm"
            timeLabel.text = formatter.string(from: item.scheduledTime)

            formatter.dateFormat = "a"
            timeAmPmLabel.text = formatter.string(from: item.scheduledTime)

            // Status UI
            switch item.status {
            case .taken:
                medStatusImage.image = UIImage(named: "taken_icon")
            case .skipped:
                medStatusImage.image = UIImage(named: "skipped_icon")
            case .none:
                medStatusImage.image = nil
            }
        }

}
