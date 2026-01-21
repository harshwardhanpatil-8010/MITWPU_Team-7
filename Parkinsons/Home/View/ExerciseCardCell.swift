//
//  ExerciseCardCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//


import UIKit

class ExerciseCardCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressRingContainer: UIView!
    @IBOutlet weak var backgroundCardView: UIView!

    private var progressView: CircularProgressViewHome!
    
    private var themeColor: UIColor = .systemBlue

    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        setupCircularProgress()
        setupCardStyle()
    }
    
    private func setupCircularProgress() {
        progressView = CircularProgressViewHome(frame: progressRingContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        progressRingContainer.addSubview(progressView)
        progressRingContainer.backgroundColor = .clear
    }

    func setProgress(completed: Int, total: Int) {
        progressLabel.text = "\(completed)/\(total)"
        let progress = total == 0 ? 0 : CGFloat(completed) / CGFloat(total)
        progressView.setProgress(progress)

        if completed == total && total > 0 {
            progressView.progressColor = .systemGreen // Optional: Keep green for 100% completion
        } else {
            progressView.progressColor = themeColor
        }
    }
    
    func configure(with model: ExerciseModel) {
        titleLabel.text = model.title
        detailLabel.text = model.detail
        
        self.themeColor = UIColor(hex: model.progressColorHex)
        
        progressView.progressColor = self.themeColor
        progressView.trackColor = .systemGray5
    }
        
    func setupCardStyle() {
        let cornerRadius: CGFloat = 23
        backgroundCardView.layer.cornerRadius = cornerRadius
        backgroundCardView.layer.masksToBounds = false

        backgroundCardView.layer.shadowColor = UIColor.black.cgColor
        backgroundCardView.layer.shadowOpacity = 0.15
        backgroundCardView.layer.shadowRadius = 3
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
}
