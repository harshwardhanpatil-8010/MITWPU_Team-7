//
//import UIKit
//
//class SessionSummaryViewController: UIViewController {
//
//    @IBOutlet weak var timeLabel:                  UILabel!
//    @IBOutlet weak var walkingUIView:              UIView!
//    @IBOutlet weak var GaitUIView:                 UIView!
//    @IBOutlet weak var timeContainer:              UIView!
//    @IBOutlet weak var stepsTaken:                 UILabel!
//    @IBOutlet weak var distanceCovered:            UILabel!
//    @IBOutlet weak var speed:                      UILabel!
//    @IBOutlet weak var stepsLength:                UILabel!
//    @IBOutlet weak var walkingAsymmetry:           UILabel!
//    @IBOutlet weak var walkingSteadiness:          UILabel!
//    @IBOutlet weak var stepLengthPercent:          UILabel!
//    @IBOutlet weak var walkingAsymmetryPercent:    UILabel!
//    @IBOutlet weak var walkingSteadinessPercent:   UILabel!
//    @IBOutlet weak var goalCompletedTLabel:        UIStackView!
//
//    var sessionData: RhythmicSessionDTO?
//
//    var isHistoryView: Bool = false
//    private var progressView: CircularProgressView!
//    private func setupProgressView() {
//        progressView = CircularProgressView(frame: timeContainer.bounds)
//        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        timeContainer.addSubview(progressView)
//    }
//
//    private func setupBackButton() {
//        let backButton = UIBarButtonItem(
//            image: UIImage(systemName: "chevron.left"),
//            style: .plain,
//            target: self,
//            action: #selector(backTapped)
//        )
//        backButton.tintColor             = .label   // black in light mode
//        navigationItem.leftBarButtonItem  = backButton
//        navigationItem.hidesBackButton    = false
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//        navigationController?.interactivePopGestureRecognizer?.delegate  = nil
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        goalCompletedTLabel.isHidden = true
//
//        setupProgressView()
//        setupBackButton()
//
//        walkingUIView.applyCardStyle()
//        GaitUIView.applyCardStyle()
//
//        progressView.progressColor = UIColor(hex: "90AF81")
//        progressView.lineWidth     = 15
//        progressView.trackColor    = UIColor(hex: "90AF81", alpha: 0.3)
//
//        loadData()
//        if !isHistoryView,
//           let session = sessionData,
//           session.elapsedSeconds >= session.requestedDurationSeconds {
//            showConfetti()
//        }
//        if isHistoryView, let session = sessionData {
//            navigationItem.title = "Session \(session.sessionNumber)"
//        } else {
//            navigationItem.title = "Rhythmic Walking"
//        }
//    }
//
//    @objc private func backTapped() {
//        navigationController?.popViewController(animated: true)
//    }
//
//    func loadData() {
//        guard var session = sessionData else {
//            timeLabel.text = "00:00:00"
//            progressView.setProgress(0.0)
//            return
//        }
//        if session.endDate == nil {
//            session.endDate = session.startDate
//                .addingTimeInterval(TimeInterval(session.elapsedSeconds))
//            sessionData = session
//        }
//        let h = session.elapsedSeconds / 3600
//        let m = (session.elapsedSeconds % 3600) / 60
//        let s = session.elapsedSeconds % 60
//        timeLabel.text = String(format: "%02d:%02d:%02d", h, m, s)
//
//        let progress = session.requestedDurationSeconds > 0
//            ? Float(session.elapsedSeconds) / Float(session.requestedDurationSeconds) : 1.0
//        progressView.setProgress(CGFloat(progress))
//
//        guard let fixedSession = sessionData else { return }
//
//        if let cached = DataStore.shared.cachedSummary(for: fixedSession) {
//            apply(summary: cached)
//        } else {
//            setPlaceholders()
//        }
//        let previousManaged = DataStore.shared.previousSession(before: fixedSession)
//
//        HealthKitManagerRhythmic.shared.fetchFullSummary(for: fixedSession) { [weak self] summary in
//            guard let self else { return }
//            if summary.steps > 0 || summary.distanceMeters > 0 {
//                self.apply(summary: summary)
//                self.applyChangePercents(summary: summary, previous: previousManaged)
//            } else if let cached = DataStore.shared.cachedSummary(for: fixedSession) {
//                self.applyChangePercents(summary: cached, previous: previousManaged)
//            }
//        }
//    }
//
//    private func apply(summary: GaitSummary) {
//        stepsTaken.text       = summary.steps > 0 ? "\(summary.steps)" : "No data"
//        distanceCovered.text  = String(format: "%.1f km", summary.distanceMeters / 1000.0)
//        speed.text            = String(format: "%.1f km/h", summary.speedKmH)
//        stepsLength.text      = String(format: "%.2f m", summary.stepLengthMeters)
//        walkingAsymmetry.text = String(format: "%.1f%%", summary.walkingAsymmetryPercent)
//        walkingSteadiness.text      = summary.walkingSteadiness
//        walkingSteadiness.textColor = summary.walkingSteadiness == "OK" ? .systemGreen : .systemRed
//    }
//
//    private func setPlaceholders() {
//        for label in [stepsTaken, distanceCovered, speed,
//                       stepsLength, walkingAsymmetry, walkingSteadiness,
//                       stepLengthPercent, walkingAsymmetryPercent, walkingSteadinessPercent] {
//            label?.text = "--"
//        }
//        walkingSteadiness.textColor = .label
//    }
//
//    private func applyChangePercents(summary: GaitSummary, previous: RhythmicSession?) {
//        guard let prev = previous else {
//            for label in [stepLengthPercent, walkingAsymmetryPercent, walkingSteadinessPercent] {
//                label?.text      = ""
//                label?.textColor = .secondaryLabel
//            }
//            return
//        }
//
//        applyChange(label:          stepLengthPercent,
//                    current:        summary.stepLengthMeters,
//                    previous:       prev.stepLengthMeters,
//                    higherIsBetter: true)
//
//        applyChange(label:          walkingAsymmetryPercent,
//                    current:        summary.walkingAsymmetryPercent,
//                    previous:       prev.walkingAsymmetry,
//                    higherIsBetter: false)
//
//        applyChange(label:          walkingSteadinessPercent,
//                    current:        steadinessScore(summary.walkingSteadiness),
//                    previous:       prev.walkingSteadiness,
//                    higherIsBetter: true)
//    }
//
//    private func applyChange(label: UILabel?,
//                              current: Double,
//                              previous: Double,
//                              higherIsBetter: Bool) {
//        guard let label else { return }
//        guard previous > 0 else {
//            label.text      = ""
//            label.textColor = .secondaryLabel
//            return
//        }
//        let changePct = ((current - previous) / previous) * 100.0
//        let improved  = higherIsBetter ? changePct >= 0 : changePct <= 0
//        label.text      = String(format: "%@ %.1f%%", improved ? "↑" : "↓", abs(changePct))
//        label.textColor = improved ? .systemGreen : .systemRed
//    }
//
//    private func steadinessScore(_ classification: String) -> Double {
//        switch classification {
//        case "OK":  return 83.5
//        case "Low": return 56.0
//        default:    return 22.5
//        }
//    }
//
//    private func showConfetti() {
//        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        blurEffectView.alpha = 0
//        view.addSubview(blurEffectView)
//
//        let confettiLayer = CAEmitterLayer()
//        confettiLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
//        confettiLayer.emitterShape    = .line
//        confettiLayer.emitterSize     = CGSize(width: view.bounds.width, height: 2)
//        confettiLayer.emitterCells    = [UIColor.systemRed, .systemBlue, .systemGreen,
//                                         .systemOrange, .systemPurple, .systemYellow, .systemPink]
//            .map { color in
//                let cell = CAEmitterCell()
//                cell.birthRate = 6; cell.lifetime = 10; cell.velocity = 180
//                cell.velocityRange = 60; cell.emissionLongitude = .pi
//                cell.emissionRange = .pi / 4; cell.spin = 3; cell.spinRange = 4
//                cell.scale = 0.05; cell.scaleRange = 0.03
//                cell.color    = color.cgColor
//                cell.contents = confettiImage().cgImage
//                return cell
//            }
//        view.layer.addSublayer(confettiLayer)
//        view.bringSubviewToFront(goalCompletedTLabel)
//
//        goalCompletedTLabel.isHidden  = false
//        goalCompletedTLabel.alpha     = 1.0
//        goalCompletedTLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//
//        UIView.animate(withDuration: 0.7, delay: 0,
//                       usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5,
//                       options: .curveEaseOut) {
//            self.goalCompletedTLabel.transform = .identity
//            blurEffectView.alpha = 0.9
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { confettiLayer.birthRate = 0 }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            UIView.animate(withDuration: 1.0, animations: {
//                self.goalCompletedTLabel.alpha = 0
//                blurEffectView.alpha = 0
//            }) { _ in
//                self.goalCompletedTLabel.isHidden = true
//                blurEffectView.removeFromSuperview()
//                confettiLayer.removeFromSuperlayer()
//            }
//        }
//    }
//
//    private func confettiImage() -> UIImage {
//        let size = CGSize(width: 32, height: 20)
//        return UIGraphicsImageRenderer(size: size).image { ctx in
//            ctx.cgContext.setFillColor(UIColor.white.cgColor)
//            if Bool.random() {
//                ctx.cgContext.fill(CGRect(origin: .zero, size: size))
//            } else {
//                let r = min(size.width, size.height) / 2
//                ctx.cgContext.addArc(center: CGPoint(x: size.width / 2, y: size.height / 2),
//                                     radius: r, startAngle: 0, endAngle: .pi * 2, clockwise: false)
//                ctx.cgContext.fillPath()
//            }
//        }
//    }
//}





import UIKit

class SessionSummaryViewController: UIViewController {

    @IBOutlet weak var timeLabel:                  UILabel!
    @IBOutlet weak var walkingUIView:              UIView!
    @IBOutlet weak var GaitUIView:                 UIView!
    @IBOutlet weak var timeContainer:              UIView!
    @IBOutlet weak var stepsTaken:                 UILabel!
    @IBOutlet weak var distanceCovered:            UILabel!
    @IBOutlet weak var speed:                      UILabel!
    @IBOutlet weak var stepsLength:                UILabel!
    @IBOutlet weak var walkingAsymmetry:           UILabel!
    @IBOutlet weak var walkingSteadiness:          UILabel!
    @IBOutlet weak var stepLengthPercent:          UILabel!
    @IBOutlet weak var walkingAsymmetryPercent:    UILabel!
    @IBOutlet weak var walkingSteadinessPercent:   UILabel!
    @IBOutlet weak var goalCompletedTLabel:        UIStackView!

    var sessionData: RhythmicSessionDTO?

    var isHistoryView: Bool = false
    private var progressView: CircularProgressView!
    private func setupProgressView() {
        progressView = CircularProgressView(frame: timeContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timeContainer.addSubview(progressView)
    }

    private func setupBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backButton.tintColor             = .label   // black in light mode
        navigationItem.leftBarButtonItem  = backButton
        navigationItem.hidesBackButton    = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate  = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        goalCompletedTLabel.isHidden = true

        setupProgressView()
        setupBackButton()

        walkingUIView.applyCardStyle()
        GaitUIView.applyCardStyle()

        progressView.progressColor = UIColor(hex: "90AF81")
        progressView.lineWidth     = 15
        progressView.trackColor    = UIColor(hex: "90AF81", alpha: 0.3)

        loadData()
        if !isHistoryView,
           let session = sessionData,
           session.elapsedSeconds >= session.requestedDurationSeconds {
            showConfetti()
        }
        if isHistoryView, let session = sessionData {
            navigationItem.title = "Session \(session.sessionNumber)"
        } else {
            navigationItem.title = "Rhythmic Walking"
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    func loadData() {
        guard var session = sessionData else {
            timeLabel.text = "00:00:00"
            progressView.setProgress(0.0)
            return
        }
        // Only compute a fallback endDate if none was recorded.
        // Do NOT overwrite a real endDate that was set when the session finished.
        if session.endDate == nil {
            let fallback = session.startDate
                .addingTimeInterval(TimeInterval(session.elapsedSeconds))
            // Only apply fallback if elapsedSeconds > 0, otherwise HealthKit window is zero-width
            if session.elapsedSeconds > 0 {
                session.endDate = fallback
                sessionData = session
            }
        }
        let h = session.elapsedSeconds / 3600
        let m = (session.elapsedSeconds % 3600) / 60
        let s = session.elapsedSeconds % 60
        timeLabel.text = String(format: "%02d:%02d:%02d", h, m, s)

        let progress = session.requestedDurationSeconds > 0
            ? Float(session.elapsedSeconds) / Float(session.requestedDurationSeconds) : 1.0
        progressView.setProgress(CGFloat(progress))

        guard let fixedSession = sessionData else { return }

        if let cached = DataStore.shared.cachedSummary(for: fixedSession) {
            apply(summary: cached)
        } else {
            setPlaceholders()
        }
        let previousManaged = DataStore.shared.previousSession(before: fixedSession)

        HealthKitManagerRhythmic.shared.fetchFullSummary(for: fixedSession) { [weak self] summary in
            guard let self else { return }
            if summary.steps > 0 || summary.distanceMeters > 0 {
                self.apply(summary: summary)
                self.applyChangePercents(summary: summary, previous: previousManaged)
            } else if let cached = DataStore.shared.cachedSummary(for: fixedSession) {
                // Bug fix: apply cached data to labels AND show change percents
                self.apply(summary: cached)
                self.applyChangePercents(summary: cached, previous: previousManaged)
            }
        }
    }

    private func apply(summary: GaitSummary) {
        stepsTaken.text       = summary.steps > 0 ? "\(summary.steps)" : "No data"
        distanceCovered.text  = String(format: "%.1f km", summary.distanceMeters / 1000.0)
        speed.text            = String(format: "%.1f km/h", summary.speedKmH)
        stepsLength.text      = String(format: "%.2f m", summary.stepLengthMeters)
        walkingAsymmetry.text = String(format: "%.1f%%", summary.walkingAsymmetryPercent)
        walkingSteadiness.text      = summary.walkingSteadiness
        walkingSteadiness.textColor = summary.walkingSteadiness == "OK" ? .systemGreen : .systemRed
    }

    private func setPlaceholders() {
        for label in [stepsTaken, distanceCovered, speed,
                       stepsLength, walkingAsymmetry, walkingSteadiness,
                       stepLengthPercent, walkingAsymmetryPercent, walkingSteadinessPercent] {
            label?.text = "--"
        }
        walkingSteadiness.textColor = .label
    }

    private func applyChangePercents(summary: GaitSummary, previous: RhythmicSession?) {
        guard let prev = previous else {
            for label in [stepLengthPercent, walkingAsymmetryPercent, walkingSteadinessPercent] {
                label?.text      = ""
                label?.textColor = .secondaryLabel
            }
            return
        }

        applyChange(label:          stepLengthPercent,
                    current:        summary.stepLengthMeters,
                    previous:       prev.stepLengthMeters,
                    higherIsBetter: true)

        applyChange(label:          walkingAsymmetryPercent,
                    current:        summary.walkingAsymmetryPercent,
                    previous:       prev.walkingAsymmetry,
                    higherIsBetter: false)

        applyChange(label:          walkingSteadinessPercent,
                    current:        steadinessScore(summary.walkingSteadiness),
                    previous:       prev.walkingSteadiness,
                    higherIsBetter: true)
    }

    private func applyChange(label: UILabel?,
                              current: Double,
                              previous: Double,
                              higherIsBetter: Bool) {
        guard let label else { return }
        guard previous > 0 else {
            label.text      = ""
            label.textColor = .secondaryLabel
            return
        }
        let changePct = ((current - previous) / previous) * 100.0
        let improved  = higherIsBetter ? changePct >= 0 : changePct <= 0
        label.text      = String(format: "%@ %.1f%%", improved ? "↑" : "↓", abs(changePct))
        label.textColor = improved ? .systemGreen : .systemRed
    }

    private func steadinessScore(_ classification: String) -> Double {
        switch classification {
        case "OK":  return 83.5
        case "Low": return 56.0
        default:    return 22.5
        }
    }

    private func showConfetti() {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0
        view.addSubview(blurEffectView)

        let confettiLayer = CAEmitterLayer()
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        confettiLayer.emitterShape    = .line
        confettiLayer.emitterSize     = CGSize(width: view.bounds.width, height: 2)
        confettiLayer.emitterCells    = [UIColor.systemRed, .systemBlue, .systemGreen,
                                         .systemOrange, .systemPurple, .systemYellow, .systemPink]
            .map { color in
                let cell = CAEmitterCell()
                cell.birthRate = 6; cell.lifetime = 10; cell.velocity = 180
                cell.velocityRange = 60; cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 4; cell.spin = 3; cell.spinRange = 4
                cell.scale = 0.05; cell.scaleRange = 0.03
                cell.color    = color.cgColor
                cell.contents = confettiImage().cgImage
                return cell
            }
        view.layer.addSublayer(confettiLayer)
        view.bringSubviewToFront(goalCompletedTLabel)

        goalCompletedTLabel.isHidden  = false
        goalCompletedTLabel.alpha     = 1.0
        goalCompletedTLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 0.7, delay: 0,
                       usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5,
                       options: .curveEaseOut) {
            self.goalCompletedTLabel.transform = .identity
            blurEffectView.alpha = 0.9
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { confettiLayer.birthRate = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            UIView.animate(withDuration: 1.0, animations: {
                self.goalCompletedTLabel.alpha = 0
                blurEffectView.alpha = 0
            }) { _ in
                self.goalCompletedTLabel.isHidden = true
                blurEffectView.removeFromSuperview()
                confettiLayer.removeFromSuperlayer()
            }
        }
    }

    private func confettiImage() -> UIImage {
        let size = CGSize(width: 32, height: 20)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            if Bool.random() {
                ctx.cgContext.fill(CGRect(origin: .zero, size: size))
            } else {
                let r = min(size.width, size.height) / 2
                ctx.cgContext.addArc(center: CGPoint(x: size.width / 2, y: size.height / 2),
                                     radius: r, startAngle: 0, endAngle: .pi * 2, clockwise: false)
                ctx.cgContext.fillPath()
            }
        }
    }
}
