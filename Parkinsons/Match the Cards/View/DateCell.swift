
import UIKit

class DateCell: UICollectionViewCell {

    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var dateLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
        labelBackgroundView.layer.cornerRadius =
            labelBackgroundView.bounds.width / 2
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

        if isToday && !showTodayOutline && !isCompleted {
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
    }

    func configureEmpty() {
        resetAppearance()
        dateLabel.text = ""
        isUserInteractionEnabled = false
    }

    private func resetAppearance() {
        labelBackgroundView.backgroundColor = .clear
        labelBackgroundView.layer.borderWidth = 0
        labelBackgroundView.layer.borderColor = nil
        dateLabel.textColor = .label
    }
}
