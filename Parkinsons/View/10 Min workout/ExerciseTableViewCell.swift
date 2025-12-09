//
//  ExerciseTableViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var checkMarkImageOutlet: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
