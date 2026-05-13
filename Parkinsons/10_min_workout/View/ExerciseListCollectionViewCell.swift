import UIKit
import AVFoundation

class ExerciseListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailOutlet: UIImageView!
    @IBOutlet weak var exerciseNameOutlet: UILabel!
    @IBOutlet weak var repsOutlet: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailOutlet.layer.cornerRadius = 10
        thumbnailOutlet.clipsToBounds = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailOutlet.image = nil
    }
    
    func configureCompleted() {
        exerciseNameOutlet.textColor = .systemGray
        repsOutlet.textColor = .systemGray2
        thumbnailOutlet.alpha = 0.3
    }

    func configurePendingOrSkipped() {
        exerciseNameOutlet.textColor = .label
        repsOutlet.textColor = .secondaryLabel
        thumbnailOutlet.alpha = 1
    }

    func loadThumbnail(exercise: WorkoutExercise) {
        if let name = exercise.thumbnailName {
            thumbnailOutlet.image = UIImage(named: name)
        }
    }
}
