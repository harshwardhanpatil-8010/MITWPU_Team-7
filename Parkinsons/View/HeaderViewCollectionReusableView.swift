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
        // Initialization code
        editButton.isHidden = true
        editButton.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        bringSubviewToFront(editButton)

    }
    
    func configureHeader(text: String, showEdit: Bool){
        headerLabel.text = text
        headerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        editButton.isHidden = !showEdit
    }
}

