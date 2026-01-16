//
//  EditLogCollectionViewCell.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 15/01/26.
//

import UIKit

class EditLogCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var skippedButton: UIButton!
    @IBOutlet weak var takenButton: UIButton!
    @IBOutlet weak var formLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var medImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var MedContainer: UIView!
    var onStatusChange: ((DoseLogStatus) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        MedContainer.applyCardStyle()
        // Initialization code
    }
    func configure(with item: LoggedDoseItem) {
            nameLabel.text = item.medicationName
            formLabel.text = item.medicationForm
            medImageView.image = UIImage(named: item.iconName)

            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            timeLabel.text = formatter.string(from: item.loggedTime)

            updateSelection(status: item.status)
        }

        private func updateSelection(status: DoseLogStatus) {
            takenButton.isSelected = status == .taken
            skippedButton.isSelected = status == .skipped

            takenButton.alpha = takenButton.isSelected ? 1.0 : 0.4
            skippedButton.alpha = skippedButton.isSelected ? 1.0 : 0.4
        }
    
    
    @IBAction func skippedButtonTapped(_ sender: UIButton) {
        updateSelection(status: .skipped)
                onStatusChange?(.skipped)
    }
    @IBAction func takenButtontapped(_ sender: UIButton) {
        updateSelection(status: .taken)
                onStatusChange?(.taken)
    }
    
    
}
