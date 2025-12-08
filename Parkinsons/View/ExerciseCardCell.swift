//
//  ExerciseCardCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//


import UIKit

class ExerciseCardCell: UICollectionViewCell {
    
    // ⭐️ You must connect these outlets in the XIB ⭐️
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!        // e.g., "0% Done"
    @IBOutlet weak var progressRingContainer: UIView! // For the circular progress view
    //@IBOutlet weak var timeEstimateLabel: UILabel!    // e.g., "7.5"
    @IBOutlet weak var backgroundCardView: UIView!    // For corner radius and shadow
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundCardView.layer.cornerRadius = 16
        backgroundCardView.layer.masksToBounds = true
    }

    func configure(with model: ExerciseModel) {
        titleLabel.text = model.title
        detailLabel.text = model.detail
        progressLabel.text = "\(model.progressPercentage)% Done"
       // timeEstimateLabel.text = model.timeEstimate
        backgroundCardView.backgroundColor = .systemTeal

    }
}
