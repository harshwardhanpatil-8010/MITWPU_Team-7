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

    var onStatusTap: (() -> Void)?

    func configure(with item: LoggedDoseItem) {
        medNameLabel.text = item.medicationName
        medFormImage.image = UIImage(named: item.iconName)

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeStr = formatter.string(from: item.loggedTime)
        medUnitandformLabel.text = "\(item.medicationForm) · Logged at \(timeStr)"

        switch item.status {
        case .taken:
            medStatusImage.image = UIImage(systemName: "checkmark")
            medStatusImage.tintColor = .systemGreen
        case .skipped:
            medStatusImage.image = UIImage(systemName: "xmark")
            medStatusImage.tintColor = .systemRed
        case .none:
            medStatusImage.image = UIImage(systemName: "circle")
            medStatusImage.tintColor = .systemGray5
        }
    }

    func setEditing(_ editing: Bool) {
        medStatusImage.isUserInteractionEnabled = editing
    }
}
