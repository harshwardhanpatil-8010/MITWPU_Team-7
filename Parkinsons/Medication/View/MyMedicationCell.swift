//
//  MyMedicationCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class MyMedicationCell: UICollectionViewCell {
   
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        applyCardStyle()
        containerView.layer.cornerRadius = 16
    }

    func configure(with medication: Medication) {
        titleLabel.text = medication.name
        subtitleLabel.text = medication.form
        repeatLabel.text = medication.schedule.displayString()
        frequencyLabel.text = "\(medication.doses.count)x day"
        iconImageView.image = UIImage(named: medication.iconName)
            ?? UIImage(systemName: "pills")
    }
}
