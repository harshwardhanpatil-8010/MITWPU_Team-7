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
        // Initialization code
        
        applyCardStyle()
        containerView.layer.cornerRadius = 16
    }
    func configure(with medication: Medication) {
        titleLabel.text = medication.name
        subtitleLabel.text = medication.form
        repeatLabel.text = medication.schedule.displayString()
        frequencyLabel.text = "\(medication.doses.count)x/day"

        iconImageView.image = UIImage(named: medication.iconName)
            ?? UIImage(systemName: "pills")
    }


        
        // MARK: - Styling
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


}
