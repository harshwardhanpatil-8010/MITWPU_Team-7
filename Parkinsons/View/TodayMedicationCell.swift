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
            styleCard()
        }

    private func styleCard() {
        let cornerRadius: CGFloat = 16
        
        // Card base
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.masksToBounds = false
        containerView.backgroundColor = .white

        // Shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)

        // Fix transparent background
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }


        // NEW configure - accepts both medication and dose
        func configure(with dose: MedicationDose) {

            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"

            let fullTime = formatter.string(from: dose.time)   // "10:45 AM"
            let components = fullTime.split(separator: " ")    // ["10:45", "AM"]

            timeNumberLabel.text = String(components[0])       // "10:45"
            ampmLabel.text = String(components[1])             // "AM"


            titleLabel.text = dose.medication.name
            subtitleLabel.text = dose.medication.form
            iconImageView.image = UIImage(named: dose.medication.iconName ?? "")

            switch dose.status {
            case .taken:
                statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
                statusImageView.tintColor = .systemGreen

            case .skipped:
                statusImageView.image = UIImage(systemName: "xmark.circle.fill")
                statusImageView.tintColor = .systemRed

            case .none:
                statusImageView.image = UIImage(systemName: "checkmark")
                statusImageView.tintColor = .systemGray3
            }
        }


        @IBAction func chevronTapped(_ sender: UIButton) {
            onChevronTap?()
        }

}
