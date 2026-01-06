//
//  ExerciseListCollectionViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class ExerciseListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var checkmarkImageOutlet: UIImageView!
    @IBOutlet weak var thumbnailImageOutlet: UIImageView!
    @IBOutlet weak var exerciseNameOutlet: UILabel!
    @IBOutlet weak var repsOutlet: UILabel!
    
    var exercises: [Exercise] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        exercises = WorkoutManager.shared.getTodayWorkout()
        
    }
    func loadThumbnail(videoID: String) {
        let urlString = "https://img.youtube.com/vi/\(videoID)/mqdefault.jpg"
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data){
                DispatchQueue.main.async {
                    self.thumbnailImageOutlet.image = image
                }
            }
        }
    }
    
    
    func configureExercise(exercise: Exercise, state: ExerciseStore) {
        exerciseNameOutlet.text = exercise.name
        repsOutlet.text = "\(exercise.reps) reps"
        
        if let videoID = exercise.videoID {
            loadThumbnail(videoID: videoID)
        }
        
        let completed =  WorkoutManager.shared.completedToday.contains(exercise.id)
        let skipped = WorkoutManager.shared.SkippedToday.contains(exercise.id)
        
        if completed {
            checkmarkImageOutlet.image = UIImage(systemName: "checkmark")
            checkmarkImageOutlet.tintColor = UIColor.systemBlue
        } else if skipped {
            checkmarkImageOutlet.image = UIImage(systemName: "checkmark")
            checkmarkImageOutlet.tintColor = UIColor.systemGray
        } else {
            checkmarkImageOutlet.image = UIImage(systemName: "checkmark")
            checkmarkImageOutlet.tintColor = UIColor.systemGray
        }
        
    }
}
