//
//  DoseTableViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

// MARK: - Delegate Protocol
// This protocol allows the cell to notify the parent controller when:
// 1. The delete button is tapped
// 2. The time picker value is changed
protocol DoseTableViewCellDelegate: AnyObject {
    func didTapDelete(cell: DoseTableViewCell)
    func didUpdateTime(cell: DoseTableViewCell, newTime: Date)
}

class DoseTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var timePicker: UIDatePicker!   // User selects dose time
    @IBOutlet weak var doseNumberLabel: UILabel!   // Shows "Dose 1", "Dose 2", etc.
    @IBOutlet weak var doseLabel: UILabel!         // Shows dose details (optional)
    @IBOutlet weak var deleteButton: UIButton!     // Delete dose button

    // MARK: - Delegate
    weak var delegate: DoseTableViewCellDelegate?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initial setup if needed
    }

    // MARK: - Actions
    @IBAction func deleteTapped(_ sender: UIButton) {
        // Notify the delegate that delete button was pressed
        delegate?.didTapDelete(cell: self)
    }

    @IBAction func timeChanged(_ sender: UIDatePicker) {
        // Notify the delegate when dose time is updated
        delegate?.didUpdateTime(cell: self, newTime: sender.date)
    }
}
