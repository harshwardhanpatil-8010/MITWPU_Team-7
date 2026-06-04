//
//  NoMedCollectionViewCell.swift
//  ParkEase
//
//  Created by Unnatti Gogna on 10/05/26.
//

import UIKit

protocol NoMedCollectionViewCellDelegate: AnyObject {
    func didTapAddNow()
}

class NoMedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var uiView: UIView!

    weak var delegate: NoMedCollectionViewCellDelegate?

    private func setupCardStyle() {
        uiView.layer.cornerRadius = 23
        uiView.layer.masksToBounds = false
        uiView.backgroundColor = .secondarySystemGroupedBackground
        uiView.layer.shadowColor = UIColor(red: 0.04, green: 0.06, blue: 0.15, alpha: 1.0).cgColor
        uiView.layer.shadowOpacity = 0.05
        uiView.layer.shadowRadius = 16
        uiView.layer.shadowOffset = CGSize(width: 0, height: 6)
        uiView.layer.borderWidth = 1.0
        uiView.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.85).cgColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardStyle()
    }

    @IBAction func addNowButtonTapped(_ sender: Any) {
        delegate?.didTapAddNow()
    }
}
