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

        labelBackgroundView.backgroundColor = .clear
        dateLabel.textColor = .black
        dateLabel.tintColor = .clear
        dateLabel.text = ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.isEnabled = true
        contentView.tintColor = .clear
        dateLabel.tintColor = .clear
    }

    
    override func layoutSubviews() {
           super.layoutSubviews()

           labelBackgroundView.layer.cornerRadius = labelBackgroundView.bounds.width / 2
           labelBackgroundView.clipsToBounds = true
       }

    func configure(day: Int, isToday: Bool, isPast: Bool) {
        dateLabel.isEnabled = true
        dateLabel.text = "\(day)"

        if isToday {
            labelBackgroundView.backgroundColor = .systemBlue
            dateLabel.textColor = .white
        } else {
            labelBackgroundView.backgroundColor = .clear
            dateLabel.textColor = isPast ? .black : .lightGray
        }
    }


           
       func configureEmpty() {
           dateLabel.text = ""
            dateLabel.textColor = .black
            labelBackgroundView.backgroundColor = .clear
       }
    }

