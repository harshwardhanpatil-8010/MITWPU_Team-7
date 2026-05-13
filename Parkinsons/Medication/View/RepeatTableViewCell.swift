//
//  RepeatTableViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class RepeatTableViewCell: UITableViewCell {

    @IBOutlet weak var repeatStatus: UIImageView!
    @IBOutlet weak var repeatLabel: UILabel!

    func configureCell(type: RepeatOption) {
        repeatLabel.text = type.name

        if type.isSelected {
            repeatStatus.image = UIImage(systemName: "checkmark")
            repeatStatus.tintColor = .systemBlue
        } else {
            repeatStatus.image = nil
        }
    }
}
