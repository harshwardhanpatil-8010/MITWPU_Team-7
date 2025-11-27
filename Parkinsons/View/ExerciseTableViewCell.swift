//
//  ExerciseTableViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {

    @IBOutlet weak var exerciseStatusImage: UIImageView!
    @IBOutlet weak var exerciseTypeLabel: UILabel!

    @IBOutlet weak var exerciseImageView: UIImageView!
    @IBOutlet weak var exerciseTimeLabel: UILabel!

    
    @IBOutlet weak var exerciseNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(exercise: ExerciseList) {
        exerciseNameLabel.text = exercise.exerciseName
        exerciseTypeLabel.text = exercise.exerciseType
        exerciseImageView.image = UIImage(named: exercise.exerciseImage)
        exerciseTimeLabel.text = "\(exercise.exerciseTime)"
        
        
    }

}
