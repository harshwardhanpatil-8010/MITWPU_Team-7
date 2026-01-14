//
//  HeaderViewCollectionReusableView.swift
//  TravelDesitnations
//
//  Created by SDC-USER on 21/11/25.
//

import UIKit

class HeaderViewCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        editButton.isHidden = true
        editButton.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        bringSubviewToFront(editButton)
    }

    var onEditTapped: (() -> Void)?

    @IBAction func editButtonTapped(_ sender: UIButton) {
        onEditTapped?()
    }

    func configureHeader(text: String, showEdit: Bool) {
        headerLabel.text = text
        editButton.isHidden = !showEdit
    }
}
