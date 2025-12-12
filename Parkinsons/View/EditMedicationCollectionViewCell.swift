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
    }
    private func weekdayName(_ n: Int) -> String {
        let names = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return names[n - 1]
    }

    func configure(with dose: MedicationDose, medication: Medication) {
        // time
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm"
        timeLabel.text = fmt.string(from: dose.time)

        fmt.dateFormat = "a"
        ampmLabel.text = fmt.string(from: dose.time)

        // title + subtitle
        titleLabel.text = medication.name
        subtitleLabel.text = "1 \(medication.form.lowercased())"

        // schedule
        switch medication.schedule {
        case .everyday:
            scheduleLabel.text = "Everyday"
        case .none:
            scheduleLabel.text = "None"
        case .weekly(let days):
            scheduleLabel.text = "Weekly: " + days.map({ weekdayName($0) }).joined(separator: ", ")
        }

        // icon
        medIcon.image = UIImage(named: medication.iconName ?? "")
    }


}


