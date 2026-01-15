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

//    func configure(day: Int,
//                   isToday: Bool,
//                   isSelected: Bool,
//                   isCompleted: Bool,
//                   showTodayOutline: Bool,
//                   enabled: Bool) {
//
//        dateLabel.text = "\(day)"
//        isUserInteractionEnabled = enabled
//
//        if isCompleted {
//            labelBackgroundView.backgroundColor = UIColor(hex: "#F0B673")
//            dateLabel.textColor = .white
//            return
//        }
//
//        if isSelected {
//            
//            if isCompleted{
////                labelBackgroundView.backgroundColor = UIColor(hex: "#F0B673")
////                dateLabel.textColor = .white
//                labelBackgroundView.layer.borderWidth = 2
//                labelBackgroundView.layer.borderColor = UIColor.orange.cgColor
//                return
//            }
//            else {
//                labelBackgroundView.backgroundColor = .clear
//                labelBackgroundView.layer.borderWidth = 2
//                labelBackgroundView.layer.borderColor = UIColor.orange.cgColor
//                dateLabel.textColor = .black
//                return
//            }
//            
//        }
//
//        if isToday {
//            if showTodayOutline {
//                labelBackgroundView.backgroundColor = .clear
//                labelBackgroundView.layer.borderWidth = 2
//                labelBackgroundView.layer.borderColor =
//                    UIColor.orange.cgColor
//                dateLabel.textColor = .black
//            } else {
//                labelBackgroundView.backgroundColor = UIColor(hex: "#F0B673")
//                dateLabel.textColor = .white
//            }
//            return
//        }
//
//        labelBackgroundView.backgroundColor = .clear
//        dateLabel.textColor = enabled ? .black : .secondaryLabel
//    }
    
//    func configure(day: Int,
//                   isToday: Bool,
//                   isSelected: Bool,
//                   isCompleted: Bool,
//                   showTodayOutline: Bool,
//                   enabled: Bool) {
//
//        dateLabel.text = "\(day)"
//        isUserInteractionEnabled = enabled
//        labelBackgroundView.layer.borderWidth = 0
//
//        if isCompleted {
//            labelBackgroundView.backgroundColor = UIColor(hex: "#F0B673")
//            dateLabel.textColor = .white
//        } else if isToday && !showTodayOutline {
//            dateLabel.textColor = .black
//        } else {
//            labelBackgroundView.backgroundColor = .clear
//            dateLabel.textColor = enabled ? .black : .systemGray4
//        }
//
//        if isSelected {
//            labelBackgroundView.layer.borderWidth = 2
//            labelBackgroundView.layer.borderColor = UIColor.orange.cgColor
//            // Optional: Ensure text is black if selection is on a clear background
//            if !isCompleted { dateLabel.textColor = .black }
//        } else if isToday && showTodayOutline {
//            labelBackgroundView.layer.borderWidth = 2
//            labelBackgroundView.layer.borderColor = UIColor.orange.cgColor
//            dateLabel.textColor = .black
//        }
//    }

    func configure(day: Int,
                   isToday: Bool,
                   isSelected: Bool,
                   isCompleted: Bool,
                   showTodayOutline: Bool,
                   enabled: Bool) {

        dateLabel.text = "\(day)"
        isUserInteractionEnabled = enabled
        
        // --- CRITICAL RESET ---
        labelBackgroundView.backgroundColor = .clear // Reset background
        labelBackgroundView.layer.borderWidth = 0    // Reset border
        // -----------------------

        if isCompleted {
            labelBackgroundView.backgroundColor = UIColor(hex: "#F0B673")
            dateLabel.textColor = .white
        } else if isToday && !showTodayOutline {
            // If it's today but we aren't showing the outline,
            // you might want it filled or clear.
            // Based on your issue, let's keep it clear and text black:
            dateLabel.textColor = .orange
            labelBackgroundView.layer.borderWidth = 2
            labelBackgroundView.layer.borderColor = UIColor.orange.cgColor
        } else {
            dateLabel.textColor = enabled ? .black : .systemGray4
        }

        // Border Logic (selection or today's outline)
        if isSelected {
            labelBackgroundView.layer.borderWidth = 2
            labelBackgroundView.layer.borderColor = UIColor.orange.cgColor
            if !isCompleted { dateLabel.textColor = .black }
        }
//        else if isToday && showTodayOutline {
//            labelBackgroundView.layer.borderWidth = 2
//            labelBackgroundView.layer.borderColor = UIColor.orange.cgColor
//            dateLabel.textColor = .black
//        }
    }
    
    func configureEmpty() {
        dateLabel.text = ""
        labelBackgroundView.backgroundColor = .clear
        isUserInteractionEnabled = false
    }
}
