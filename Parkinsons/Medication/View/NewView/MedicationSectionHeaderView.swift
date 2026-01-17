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

enum HeaderAction {
    case showAll
    case edit
}

class MedicationSectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!

    weak var delegate: MedicationSectionHeaderViewDelegate?
    private var action: HeaderAction?

    func configure(
        title: String,
        actionTitle: String?,
        action: HeaderAction?,
        isExpanded: Bool = false
    ) {
        timeLabel.text = title
        self.action = action

        actionButton.isHidden = actionTitle == nil
        actionButton.setTitle(actionTitle, for: .normal)

        if action == .showAll {
            arrowImageView.isHidden = false
            arrowImageView.image = UIImage(
                systemName: isExpanded ? "chevron.up" : "chevron.down"
            )
        } else {
            arrowImageView.isHidden = true
        }
    }

    @IBAction func actionTapped(_ sender: Any) {
        switch action {
        case .showAll:
            delegate?.didTapShowAllToday()
        case .edit:
            delegate?.didTapEditLoggedSection()
        case .none:
            break
        }
    }
}
