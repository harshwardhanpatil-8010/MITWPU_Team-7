//
//  MedicationSectionHeaderView.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 11/01/26.
//

import UIKit

protocol MedicationSectionHeaderViewDelegate: AnyObject {
    func didTapEditLoggedSection()
    func didTapShowAllToday()
}


class MedicationSectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    weak var delegate: MedicationSectionHeaderViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(title: String, actionTitle: String?) {
        timeLabel.text = title
        actionButton.isHidden = actionTitle == nil
        actionButton.setTitle(actionTitle, for: .normal)
    }


    @IBAction func editTapped(_ sender: Any) {
        delegate?.didTapShowAllToday()
    }
}
