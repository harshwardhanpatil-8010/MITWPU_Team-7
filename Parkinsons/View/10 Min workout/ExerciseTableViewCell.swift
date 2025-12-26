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
    @IBOutlet weak var exerciseImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // Prevents "ghosting" or wrong images appearing during fast scrolling
    override func prepareForReuse() {
        super.prepareForReuse()
        exerciseImage.image = UIImage(systemName: "figure.run")
        exerciseNameLabel.text = nil
        repsLabel.text = nil
        checkMarkImageOutlet.isHidden = true
    }
    
    private func setupUI() {
        exerciseImage.layer.cornerRadius = 12
        exerciseImage.clipsToBounds = true
        containerView.layer.cornerRadius = 15
        
        // High contrast shadow for better visibility
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 6
    }
    
    func configure(with exercise: ExerciseStoreItem) {
        exerciseNameLabel.text = exercise.name
        repsLabel.text = "\(exercise.reps) Reps"
        checkMarkImageOutlet.isHidden = !exercise.isSuppressed // Example logic
        loadThumbnail(videoID: exercise.videoID)
    }

    func loadThumbnail(videoID: String) {
        let urlString = "https://img.youtube.com/vi/\(videoID)/mqdefault.jpg"
        guard let url = URL(string: urlString) else { return }
        
        // Optimized background loading using URLSession
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.exerciseImage.image = image
                }
            }
        }.resume()
    }
}
