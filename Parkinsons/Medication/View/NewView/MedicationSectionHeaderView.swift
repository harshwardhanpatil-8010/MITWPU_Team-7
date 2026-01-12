//
//  MedicationSectionHeaderView.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 11/01/26.
//

import UIKit
protocol MedicationSectionHeaderViewDelegate: AnyObject {
    func didTapEditLoggedSection()
}
class MedicationSectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    weak var delegate: MedicationSectionHeaderViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    func configure(title: String, showEdit: Bool) {
            timeLabel.text = title
            editButton.isHidden = !showEdit
        }
    
    @IBAction func editTapped(_ sender: Any) {
        delegate?.didTapEditLoggedSection()
    }
}
