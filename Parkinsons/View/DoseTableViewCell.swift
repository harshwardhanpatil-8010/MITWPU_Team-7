//
//  DoseTableViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

protocol DoseTableViewCellDelegate: AnyObject {
    func didTapDelete(cell: DoseTableViewCell)
}

class DoseTableViewCell: UITableViewCell {
    weak var delegate: DoseTableViewCellDelegate?
   

    @IBAction func deleteTapped(_ sender: UIButton) {
            delegate?.didTapDelete(cell: self)
        }
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var doseNumberLabel: UILabel!
    @IBOutlet weak var doseLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
