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
    private var themeColor: UIColor = UIColor(hex: "#0088FF")
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        setupCircularProgress()
        progressView.trackColor = themeColor.withAlphaComponent(0.3)
        setupCardStyle()
    }
    
    private func setupCircularProgress() {
        progressView = CircularProgressViewHome(frame: progressRingContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        progressRingContainer.addSubview(progressView)
        progressRingContainer.backgroundColor = .clear
    }
    
    func setThemeColor(_ color: UIColor) {
        self.themeColor = color
        progressView.progressColor = color
        progressView.trackColor = color.withAlphaComponent(0.2)
    }


    func configure(with model: ExerciseModel) {
        titleLabel.text = model.title
        detailLabel.text = model.detail
        let color = UIColor(hex: model.progressColorHex)
        self.themeColor = color
        progressView.progressColor = color
        progressView.trackColor = color.withAlphaComponent(0.2)
    }

    func setProgress(completed: Int, total: Int) {
        progressLabel.text = "\(completed)/\(total)"
        let progress = total == 0 ? 0 : CGFloat(completed) / CGFloat(total)
        progressView.setProgress(progress)
        progressView.progressColor = themeColor
        progressView.trackColor = themeColor.withAlphaComponent(0.2)
    }

        
    func setupCardStyle() {
        let cornerRadius: CGFloat = 18
        backgroundCardView.layer.cornerRadius = cornerRadius
        backgroundCardView.layer.masksToBounds = false
        backgroundCardView.layer.shadowColor = UIColor.black.cgColor
        backgroundCardView.layer.shadowOpacity = 0.15
        backgroundCardView.layer.shadowRadius = 3
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
    }


}
