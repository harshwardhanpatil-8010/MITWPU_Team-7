//
//  DoseTableViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

protocol DoseTableViewCellDelegate: AnyObject {
    func didTapDelete(cell: DoseTableViewCell)
    func didUpdateTime(cell: DoseTableViewCell, newTime: Date)
}

class DoseTableViewCell: UITableViewCell {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var doseNumberLabel: UILabel!
    @IBOutlet weak var doseLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    weak var delegate: DoseTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func deleteTapped(_ sender: UIButton) {
        delegate?.didTapDelete(cell: self)
    }

    @IBAction func timeChanged(_ sender: UIDatePicker) {
        delegate?.didUpdateTime(cell: self, newTime: sender.date)
    }
}

