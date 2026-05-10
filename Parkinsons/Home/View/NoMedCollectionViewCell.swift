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
        uiView.layer.shadowColor = UIColor.black.cgColor
        uiView.layer.shadowOpacity = 0.15
        uiView.layer.shadowRadius = 3
        uiView.layer.shadowOffset = CGSize(width: 0, height: 1)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardStyle()
    }

    @IBAction func addNowButtonTapped(_ sender: Any) {
        delegate?.didTapAddNow()
    }
}
