//
//  MyMedicationCollectionViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class MyMedicationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var medContainer: UIView!
    @IBOutlet weak var medImage: UIImageView!
    @IBOutlet weak var medFrequency: UILabel!
    @IBOutlet weak var medRepeat: UILabel!
    @IBOutlet weak var medUnitandForm: UILabel!
    @IBOutlet weak var medTitle: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        medContainer.layer.cornerRadius = 16
    }
}

extension MyMedicationCollectionViewCell {

    func configure(with medication: Medication) {
        medTitle.text = medication.name
        medUnitandForm.text = medication.form
        medFrequency.text = "\(medication.doses.count)x day"
        medImage.image = UIImage(named: medication.iconName) ?? UIImage(systemName: "pills")

        switch medication.schedule {
        case .everyday:
            medRepeat.text = "Everyday"
            medRepeat.textColor = .label

        case .weekly:
            medRepeat.text = medication.schedule.displayString()


        case .none:
            medRepeat.text = "—"
            medRepeat.textColor = .systemGray3
        }
    }


}
