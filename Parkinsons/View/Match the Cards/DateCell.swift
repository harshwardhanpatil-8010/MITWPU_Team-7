//
//  DateCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 04/01/26.
//

import UIKit

class DateCell: UICollectionViewCell {

    @IBOutlet weak var labelBackgroundView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()

        labelBackgroundView.backgroundColor = UIColor.clear
       
        dateLabel.tintColor = UIColor.clear
        dateLabel.text = ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.isEnabled = true
        contentView.tintColor = UIColor.clear
        dateLabel.tintColor = UIColor.clear
    }

    
    override func layoutSubviews() {
           super.layoutSubviews()

           labelBackgroundView.layer.cornerRadius = labelBackgroundView.bounds.width / 2
           labelBackgroundView.clipsToBounds = true
       }

    func configure(day: Int, isToday: Bool, isPast: Bool, isCompleted: Bool) {
        dateLabel.text = "\(day)"
        
        if isCompleted {
            labelBackgroundView.backgroundColor = UIColor.systemGreen
            dateLabel.textColor = UIColor.white
            dateLabel.isEnabled = true
        } else if isToday {
            labelBackgroundView.backgroundColor = UIColor.systemBlue
            dateLabel.textColor = UIColor.white
            dateLabel.isEnabled = true
        } else {
            labelBackgroundView.backgroundColor = UIColor.clear
            if isPast {
                dateLabel.textColor = UIColor.label
                dateLabel.isEnabled = true
            } else {
                dateLabel.textColor = UIColor.secondaryLabel
                dateLabel.isEnabled = false
            }
        }
    }


           
       func configureEmpty() {
           dateLabel.text = ""
            dateLabel.textColor = UIColor.label
            labelBackgroundView.backgroundColor = UIColor.clear
       }
    }

