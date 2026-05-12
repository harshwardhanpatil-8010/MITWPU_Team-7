

import UIKit

class DateCell: UICollectionViewCell {

    let outerRingView = UIView()
    let labelBackgroundView = UIView()
    let dateLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        outerRingView.translatesAutoresizingMaskIntoConstraints = false
        labelBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.textAlignment = .center
        dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)

        contentView.addSubview(outerRingView)
        contentView.addSubview(labelBackgroundView)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            outerRingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            outerRingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            outerRingView.widthAnchor.constraint(equalTo: labelBackgroundView.widthAnchor, constant: 4),
            outerRingView.heightAnchor.constraint(equalTo: outerRingView.widthAnchor),

            labelBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            labelBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelBackgroundView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.88),
            labelBackgroundView.heightAnchor.constraint(equalTo: labelBackgroundView.widthAnchor),

            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
       
        outerRingView.layer.cornerRadius = outerRingView.bounds.width / 2
        outerRingView.clipsToBounds = true

        labelBackgroundView.layer.cornerRadius = labelBackgroundView.bounds.width / 2
        labelBackgroundView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetAppearance()
    }

    func configure(day: Int,
                   isToday: Bool,
                   isSelected: Bool,
                   isCompleted: Bool,
                   showTodayOutline: Bool,
                   enabled: Bool,
                   themeColor: UIColor) {

        resetAppearance()
        dateLabel.text = "\(day)"
        isUserInteractionEnabled = enabled

        if isCompleted {
            labelBackgroundView.backgroundColor = themeColor
            dateLabel.textColor = .white
            dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        } else {
            dateLabel.textColor = enabled ? .label : .systemGray4
            dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }

        if isToday && !isSelected && !isCompleted {
            dateLabel.textColor = themeColor
        }

        if isSelected {
            labelBackgroundView.layer.borderWidth = 2
            labelBackgroundView.layer.borderColor = themeColor.cgColor
            if !isCompleted {
                dateLabel.textColor = themeColor
            }
        }
        setNeedsLayout()
        layoutIfNeeded()
    }

    func configureEmpty() {
        resetAppearance()
        dateLabel.text = ""
        isUserInteractionEnabled = false
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func resetAppearance() {
        outerRingView.isHidden = true
        outerRingView.backgroundColor = .clear
        outerRingView.layer.borderWidth = 0
        outerRingView.layer.borderColor = nil
        
        labelBackgroundView.backgroundColor = .clear
        labelBackgroundView.layer.borderWidth = 0
        labelBackgroundView.layer.borderColor = nil
        dateLabel.textColor = .label
    }
}
