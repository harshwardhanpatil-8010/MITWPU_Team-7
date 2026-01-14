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

    var onStatusTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleStatusTap))
        medStatusImage.addGestureRecognizer(tap)
        medStatusImage.isUserInteractionEnabled = false
    }

    func configure(with item: LoggedDoseItem) {
        medNameLabel.text = item.medicationName
        medUnitandformLabel.text = item.medicationForm
        medFormImage.image = UIImage(named: item.iconName)

        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        timeLabel.text = formatter.string(from: item.loggedTime)

        formatter.dateFormat = "a"
        timeAmPmLabel.text = formatter.string(from: item.loggedTime)

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
        medStatusImage.alpha = editing ? 1.0 : 0.4
    }

    @objc private func handleStatusTap() {
        onStatusTap?()
    }
}
