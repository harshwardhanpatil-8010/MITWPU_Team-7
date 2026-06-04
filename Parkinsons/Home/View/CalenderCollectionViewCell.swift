import UIKit

struct CalendarActivityProgress {
    let workoutProgress: CGFloat
    let walkingProgress: CGFloat
    let workoutCompleted: Int
    let workoutTotal: Int
    let walkingElapsed: Int
    let walkingGoal: Int
}

enum CalendarActivityProgressProvider {
    private static func clampedProgress(completed: Int, total: Int) -> CGFloat {
        guard total > 0 else { return 0 }
        return min(max(CGFloat(completed) / CGFloat(total), 0), 1)
    }

    static func progress(for date: Date, calendar: Calendar = Calendar.current) -> CalendarActivityProgress {
        let summary = DailyWorkoutSummaryStore.shared.fetchSummary(for: date)
        let isToday = calendar.isDateInToday(date)

        let storedCompleted = Int(summary?.completedCount ?? 0)
        let storedTotal = Int(summary?.totalExercises ?? 0)
        let liveCompleted = isToday ? WorkoutManager.shared.completedToday.count : 0
        let liveTotal = isToday ? WorkoutManager.shared.exercises.count : 0

        let workoutCompleted = isToday ? max(storedCompleted, liveCompleted) : storedCompleted
        let workoutTotal = max(isToday ? max(storedTotal, liveTotal) : storedTotal, 7)

        let sessions = DataStore.shared.fetchSessions(for: date)
        let walkingElapsed = sessions.reduce(0) { $0 + $1.elapsedSeconds }
        let walkingGoal = sessions.map(\.requestedDurationSeconds).max() ?? 600

        return CalendarActivityProgress(
            workoutProgress: clampedProgress(completed: workoutCompleted, total: workoutTotal),
            walkingProgress: sessions.isEmpty ? 0 : clampedProgress(completed: walkingElapsed, total: walkingGoal),
            workoutCompleted: workoutCompleted,
            workoutTotal: workoutTotal,
            walkingElapsed: walkingElapsed,
            walkingGoal: walkingGoal
        )
    }
}

final class CalendarActivityRingsView: UIView {
    private let workoutTrackLayer = CAShapeLayer()
    private let workoutProgressLayer = CAShapeLayer()
    private let walkingTrackLayer = CAShapeLayer()
    private let walkingProgressLayer = CAShapeLayer()

    private var workoutProgress: CGFloat = 0
    private var walkingProgress: CGFloat = 0

    var workoutColor: UIColor = UIColor(hex: "0088FF") {
        didSet { updateLayerColors() }
    }

    var walkingColor: UIColor = UIColor(hex: "90AF81") {
        didSet { updateLayerColors() }
    }

    var isDimmed: Bool = false {
        didSet { updateLayerColors() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePaths()
    }

    func setProgress(workout: CGFloat, walking: CGFloat) {
        workoutProgress = min(max(workout, 0), 1)
        walkingProgress = min(max(walking, 0), 1)
        workoutProgressLayer.strokeEnd = workoutProgress
        walkingProgressLayer.strokeEnd = walkingProgress
    }

    private func setupLayers() {
        [workoutTrackLayer, walkingTrackLayer].forEach { layer in
            layer.fillColor = UIColor.clear.cgColor
            layer.lineCap = .round
        }

        [workoutProgressLayer, walkingProgressLayer].forEach { layer in
            layer.fillColor = UIColor.clear.cgColor
            layer.lineCap = .round
            layer.strokeEnd = 0
        }

        layer.addSublayer(workoutTrackLayer)
        layer.addSublayer(workoutProgressLayer)
        layer.addSublayer(walkingTrackLayer)
        layer.addSublayer(walkingProgressLayer)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        updateLayerColors()
    }

    private func updatePaths() {
        let diameter = min(bounds.width, bounds.height)
        guard diameter > 0 else { return }

        let lineWidth = max(3, diameter * 0.13)
        let ringGap = max(2, diameter * 0.08)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let outerRadius = (diameter / 2) - (lineWidth / 2) - 1
        let innerRadius = max(1, outerRadius - lineWidth - ringGap)
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + (2 * CGFloat.pi)

        let workoutPath = UIBezierPath(
            arcCenter: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        let walkingPath = UIBezierPath(
            arcCenter: center,
            radius: innerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        [workoutTrackLayer, workoutProgressLayer].forEach {
            $0.path = workoutPath.cgPath
            $0.lineWidth = lineWidth
        }
        [walkingTrackLayer, walkingProgressLayer].forEach {
            $0.path = walkingPath.cgPath
            $0.lineWidth = lineWidth
        }

        setProgress(workout: workoutProgress, walking: walkingProgress)
    }

    private func updateLayerColors() {
        if isDimmed {
            let trackColor = UIColor.systemGray4.withAlphaComponent(0.75).cgColor
            let progressColor = UIColor.systemGray3.withAlphaComponent(0.9).cgColor
            workoutTrackLayer.strokeColor = trackColor
            walkingTrackLayer.strokeColor = trackColor
            workoutProgressLayer.strokeColor = progressColor
            walkingProgressLayer.strokeColor = progressColor
            return
        }

        workoutTrackLayer.strokeColor = workoutColor.withAlphaComponent(0.18).cgColor
        walkingTrackLayer.strokeColor = walkingColor.withAlphaComponent(0.18).cgColor
        workoutProgressLayer.strokeColor = workoutColor.cgColor
        walkingProgressLayer.strokeColor = walkingColor.cgColor
    }
}

class CalenderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var calenderDate: UILabel!
    @IBOutlet weak var calenderBackground: UIView!
    @IBOutlet weak var calenderDay: UILabel!

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
        calenderDay.frame = dayBadgeView.bounds
        ringsView.frame = CGRect(x: ringX, y: ringTop, width: ringDiameter, height: ringDiameter)
        calenderDate.frame = .zero
    }

    private func setupRingCalendarCell() {
        calenderBackground.removeFromSuperview()
        calenderDay.removeFromSuperview()
        calenderDate.removeFromSuperview()

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        dayBadgeView.backgroundColor = .clear
        dayBadgeView.clipsToBounds = true
        contentView.addSubview(dayBadgeView)
        dayBadgeView.addSubview(calenderDay)
        contentView.addSubview(ringsView)
        contentView.addSubview(calenderDate)

        calenderDay.translatesAutoresizingMaskIntoConstraints = true
        calenderDay.textAlignment = .center
        calenderDay.contentMode = .center
        calenderDay.baselineAdjustment = .alignCenters
        calenderDay.font = .systemFont(ofSize: 15, weight: .semibold)

        calenderDate.translatesAutoresizingMaskIntoConstraints = true
        calenderDate.textAlignment = .center
        calenderDate.font = .systemFont(ofSize: 12, weight: .semibold)
        calenderDate.adjustsFontSizeToFitWidth = true
        calenderDate.minimumScaleFactor = 0.75
        calenderDate.isHidden = true
    }

    func configure(
        with model: DateModel,
        isSelected: Bool,
        isToday: Bool,
        isFuture: Bool,
        progress: CalendarActivityProgress
    ) {
        calenderDay.text = model.dayString
        calenderDate.text = model.dateString
        ringsView.setProgress(workout: progress.workoutProgress, walking: progress.walkingProgress)
        ringsView.isDimmed = isFuture

        self.accessibilityLabel = model.dateString
        self.accessibilityTraits = isFuture ? [.notEnabled] : (isSelected ? [.selected] : [])

        if isFuture {
            calenderDay.textColor = .systemGray3
            calenderDate.textColor = .systemGray3
            dayBadgeView.backgroundColor = .clear
            return
        }

        calenderDay.textColor = .label
        calenderDate.textColor = .label
        dayBadgeView.backgroundColor = .clear

        if isSelected {
            calenderDay.textColor = .white
            calenderDate.textColor = .label
            dayBadgeView.backgroundColor = .systemGray2
            return
        }

        if isToday {
            calenderDay.textColor = .systemBlue
            calenderDate.textColor = .systemBlue
            return
        }
    }
}
