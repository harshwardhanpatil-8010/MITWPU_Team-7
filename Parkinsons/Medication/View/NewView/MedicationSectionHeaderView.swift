//
//  MedicationSectionHeaderView.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 11/01/26.
//

import UIKit

class MedicationSectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(title: String, showEdit: Bool) {
            timeLabel.text = title
            editButton.isHidden = !showEdit
        }
    
}
