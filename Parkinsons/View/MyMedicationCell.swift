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
        
        styleCard()
    }
    func configure(with medication: Medication) {
            
            titleLabel.text = medication.name
            subtitleLabel.text = medication.form           // Tablet/Capsule etc.
            
            repeatLabel.text = medication.schedule         // “Everyday”, “Mon, Wed”
            
            // Frequency = number of doses per day
            let timesPerDay = medication.doses.count
            frequencyLabel.text = "\(timesPerDay)x/day"
            
            // Medication icon
            if let icon = medication.iconName {
                iconImageView.image = UIImage(named: icon)
            } else {
                iconImageView.image = UIImage(systemName: "pills")
            }
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
