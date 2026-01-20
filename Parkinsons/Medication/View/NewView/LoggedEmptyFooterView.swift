//
//  LoggedEmptyFooterView.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 16/01/26.
//

import UIKit

class LoggedEmptyFooterView: UICollectionReusableView {

    @IBOutlet weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.textAlignment = .center
    }

    func configure(message: String) {
        messageLabel.text = message
    }
}

