

import UIKit

class DateCell: UICollectionViewCell {

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
        labelBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.textAlignment = .center
        dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)

        contentView.addSubview(labelBackgroundView)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            labelBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            labelBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelBackgroundView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            labelBackgroundView.heightAnchor.constraint(equalTo: labelBackgroundView.widthAnchor),

            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
       
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
        } else {
            dateLabel.textColor = enabled ? .black : .systemGray4
        }

        if isToday && !isSelected && !isCompleted {
            dateLabel.textColor = themeColor
        }

        if isSelected {
            labelBackgroundView.layer.borderWidth = 2
            labelBackgroundView.layer.borderColor = themeColor.cgColor
            if !isCompleted {
                dateLabel.textColor = .black
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
        labelBackgroundView.backgroundColor = .clear
        labelBackgroundView.layer.borderWidth = 0
        labelBackgroundView.layer.borderColor = nil
        dateLabel.textColor = .label
    }
}
