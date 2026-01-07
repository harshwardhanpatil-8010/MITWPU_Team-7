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

    override func layoutSubviews() {
        super.layoutSubviews()
        labelBackgroundView.layer.cornerRadius =
            labelBackgroundView.bounds.width / 2
    }

    override func prepareForReuse() {
        labelBackgroundView.backgroundColor = .clear
        labelBackgroundView.layer.borderWidth = 0
        dateLabel.textColor = .label
    }

    func configure(day: Int,
                   isToday: Bool,
                   isSelected: Bool,
                   isCompleted: Bool,
                   showTodayOutline: Bool,
                   enabled: Bool) {

        dateLabel.text = "\(day)"
        isUserInteractionEnabled = enabled

        if isCompleted {
            labelBackgroundView.backgroundColor = .systemGreen
            dateLabel.textColor = .white
            return
        }

        if isSelected {
            labelBackgroundView.backgroundColor = .systemBlue
            dateLabel.textColor = .white
            return
        }

        if isToday {
            if showTodayOutline {
                labelBackgroundView.backgroundColor = .clear
                labelBackgroundView.layer.borderWidth = 2
                labelBackgroundView.layer.borderColor =
                    UIColor.systemBlue.cgColor
                dateLabel.textColor = .systemBlue
            } else {
                labelBackgroundView.backgroundColor = .systemBlue
                dateLabel.textColor = .white
            }
            return
        }

        labelBackgroundView.backgroundColor = .clear
        dateLabel.textColor = enabled ? .black : .secondaryLabel
    }

    func configureEmpty() {
        dateLabel.text = ""
        labelBackgroundView.backgroundColor = .clear
        isUserInteractionEnabled = false
    }
}
