//
//  EditMedicationCollectionViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class EditMedicationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var medIcon: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var ampmLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        applyCardStyle()
    }
    private func weekdayName(_ n: Int) -> String {
        let names = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return names[n - 1]
    }
    private func styleCard() {
        let cornerRadius: CGFloat = 16
        
        // Card base
        cardView.layer.cornerRadius = cornerRadius
        cardView.layer.masksToBounds = false
        cardView.backgroundColor = .white

        // Shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.shadowRadius = 5
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)

        // Fix transparent background
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }

    func configure(with medication: Medication) {
        titleLabel.text = medication.name
        subtitleLabel.text = "1 \(medication.form.lowercased())"
        medIcon.image = UIImage(named: medication.iconName)

        // Schedule
        switch medication.schedule {
        case .everyday:
            scheduleLabel.text = "Everyday"
        case .none:
            scheduleLabel.text = "None"
        case .weekly(let days):
            scheduleLabel.text = "Weekly: " + days
                .map({ weekdayName($0) })
                .joined(separator: ", ")
        }

        // Show total number of doses (example)
        if let first = medication.doses.first {
            let fmt = DateFormatter()
            fmt.dateFormat = "h:mm a"
            timeLabel.text = fmt.string(from: first.time)
        }

        ampmLabel.isHidden = true   // (You don't need AM/PM separately)
    }




}


