//
//import UIKit
//
//class DateCell: UICollectionViewCell {
//
//    @IBOutlet weak var labelBackgroundView: UIView!
//    @IBOutlet weak var dateLabel: UILabel!
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        labelBackgroundView.layer.cornerRadius =
//            labelBackgroundView.bounds.width / 2
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        resetAppearance()
//    }
//
//    func configure(day: Int,
//                   isToday: Bool,
//                   isSelected: Bool,
//                   isCompleted: Bool,
//                   showTodayOutline: Bool,
//                   enabled: Bool) {
//
//        resetAppearance()
//
//        dateLabel.text = "\(day)"
//        isUserInteractionEnabled = enabled
//
//        if isCompleted {
//            labelBackgroundView.backgroundColor = UIColor(hex: "#F0B673")
//            dateLabel.textColor = .white
//        } else {
//            dateLabel.textColor = enabled ? .black : .systemGray4
//        }
//
//        if isToday && !showTodayOutline && !isCompleted {
//            labelBackgroundView.layer.borderWidth = 2
//            labelBackgroundView.layer.borderColor = UIColor.orange.cgColor
//            dateLabel.textColor = .orange
//        }
//
//        if isSelected {
//            labelBackgroundView.layer.borderWidth = 2
//            labelBackgroundView.layer.borderColor = UIColor.orange.cgColor
//            if !isCompleted {
//                dateLabel.textColor = .black
//            }
//        }
//    }
//
//    func configureEmpty() {
//        resetAppearance()
//        dateLabel.text = ""
//        isUserInteractionEnabled = false
//    }
//
//    private func resetAppearance() {
//        labelBackgroundView.backgroundColor = .clear
//        labelBackgroundView.layer.borderWidth = 0
//        labelBackgroundView.layer.borderColor = nil
//        dateLabel.textColor = .label
//    }
//}


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
        // Runs after bounds are final — guarantees a perfect circle
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
                   enabled: Bool) {

        resetAppearance()
        dateLabel.text = "\(day)"
        isUserInteractionEnabled = enabled

        if isCompleted {
            labelBackgroundView.backgroundColor = UIColor(hex: "#F0B673")
            dateLabel.textColor = .white
        } else {
            dateLabel.textColor = enabled ? .black : .systemGray4
        }

        if isToday && !isSelected && !isCompleted {
            labelBackgroundView.layer.borderWidth = 2
            labelBackgroundView.layer.borderColor = UIColor.orange.cgColor
            dateLabel.textColor = .orange
        }

        if isSelected {
            labelBackgroundView.layer.borderWidth = 2
            labelBackgroundView.layer.borderColor = UIColor.orange.cgColor
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
