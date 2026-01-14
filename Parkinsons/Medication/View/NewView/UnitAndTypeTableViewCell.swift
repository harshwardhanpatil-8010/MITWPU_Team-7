//
//  UnitAndTypeTableViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class UnitAndTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var typeStatus: UIImageView!
    @IBOutlet weak var typeName: UILabel!
    @IBOutlet weak var typeImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(type: UnitAndType) {
        typeName.text = type.name
        typeImage.image = UIImage(named: type.image)

        if type.isSelected {
            typeStatus.image = UIImage(systemName: "checkmark")
            typeStatus.tintColor = .systemBlue
        } else {
            typeStatus.image = nil
        }
    }
}
