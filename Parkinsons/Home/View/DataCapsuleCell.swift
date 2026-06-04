import UIKit

class DateCapsuleCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateNumberLabel: UILabel!

    private let dayBadgeView = UIView()
    private let ringsView = CalendarActivityRingsView()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        setupRingCalendarCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.alpha = 1
        isUserInteractionEnabled = true
        ringsView.setProgress(workout: 0, walking: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let badgeSize: CGFloat = min(26, max(20, bounds.width * 0.42))
        let ringTop = badgeSize + 4
        let ringDiameter = min(bounds.width - 6, bounds.height - ringTop)
        let ringX = (bounds.width - ringDiameter) / 2

        dayBadgeView.frame = CGRect(
            x: (bounds.width - badgeSize) / 2,
            y: 0,
            width: badgeSize,
            height: badgeSize
        )
        dayBadgeView.layer.cornerRadius = badgeSize / 2
        dateNumberLabel.frame = dayBadgeView.bounds
        ringsView.frame = CGRect(x: ringX, y: ringTop, width: ringDiameter, height: ringDiameter)
    }

    private func setupRingCalendarCell() {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        containerView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        dayBadgeView.backgroundColor = .clear
        dayBadgeView.clipsToBounds = true
        containerView.addSubview(dayBadgeView)
        dayBadgeView.addSubview(dateNumberLabel)
        containerView.addSubview(ringsView)

        dateNumberLabel.translatesAutoresizingMaskIntoConstraints = true
        dateNumberLabel.textAlignment = .center
        dateNumberLabel.contentMode = .center
        dateNumberLabel.baselineAdjustment = .alignCenters
        dateNumberLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        dateNumberLabel.adjustsFontSizeToFitWidth = true
        dateNumberLabel.minimumScaleFactor = 0.75
    }

    func configure(
        with model: DateModel,
        isSelected: Bool,
        isToday: Bool,
        isFuture: Bool,
        progress: CalendarActivityProgress
    ) {
        dateNumberLabel.text = model.dateString
        ringsView.setProgress(workout: progress.workoutProgress, walking: progress.walkingProgress)
        ringsView.isDimmed = isFuture

        dateNumberLabel.textColor = isFuture ? .systemGray3 : .label
        dayBadgeView.backgroundColor = .clear

        if isSelected {
            dateNumberLabel.textColor = .white
            dayBadgeView.backgroundColor = .systemGray2
            return
        }

        if isToday && !isFuture {
            dateNumberLabel.textColor = .systemBlue
        }
    }
}
