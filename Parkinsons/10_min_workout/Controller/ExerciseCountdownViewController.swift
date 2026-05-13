import UIKit
import AVFoundation

private final class PlayerContainerView: UIView {

    private let playerLayer = AVPlayerLayer()

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else { return }

        let side = max(w, h)
        let x    = (w - side) / 2
        let y = (h - side) / 2

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = CGRect(x: x, y: y, width: side, height: side)
        CATransaction.commit()
    }
}
class ExerciseCountdownViewController: UIViewController {

    var exercises: [WorkoutExercise] = []
    var startingIndex: Int = 0
    var isRevisitingSkipped: Bool = false
    var skippedIndicesToRevisit: [Int] = []

    private var countDown = 10
    private var hasNavigated = false
    private var isCancelled = false
    private var countdownTimer: Timer?
    private var isCountdownRunning = false

    private var avPlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?

    private let playerContainer    = PlayerContainerView()
    private let dimOverlay         = UIView()
    private let readyLabel         = UILabel()
    private let numberLabel        = UILabel()
    private let exerciseIndexLabel = UILabel()
    private let exerciseNameLabel  = UILabel()
    private let startButton        = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        buildUI()
        setupVideo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isCancelled = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerContainer.setNeedsLayout()
        playerContainer.layoutIfNeeded()
        avPlayer?.play()
        if !isCountdownRunning {
            isCountdownRunning = true
            tickCountdown()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isCancelled = true
        countdownTimer?.invalidate()
        countdownTimer = nil
        avPlayer?.pause()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func applyTextShadow(to label: UILabel) {
        label.layer.shadowColor   = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.75
        label.layer.shadowOffset  = CGSize(width: 0, height: 1)
        label.layer.shadowRadius  = 8
        label.layer.masksToBounds = false
    }

    private func buildUI() {
        playerContainer.translatesAutoresizingMaskIntoConstraints = false
        playerContainer.backgroundColor = .black
        playerContainer.clipsToBounds   = true
        view.addSubview(playerContainer)

        dimOverlay.translatesAutoresizingMaskIntoConstraints = false
        dimOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        view.addSubview(dimOverlay)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis      = .vertical
        stack.alignment = .center
        stack.spacing   = 4
        view.addSubview(stack)

        readyLabel.text          = "Next Exercise in"
        readyLabel.font          = .systemFont(ofSize: 17, weight: .semibold)
        readyLabel.textColor     = .white
        readyLabel.textAlignment = .center
        applyTextShadow(to: readyLabel)
        stack.addArrangedSubview(readyLabel)
        stack.setCustomSpacing(0, after: readyLabel)

        numberLabel.font          = .systemFont(ofSize: 108, weight: .bold)
        numberLabel.textColor     = .white
        numberLabel.textAlignment = .center
        numberLabel.text          = "\(countDown)"
        applyTextShadow(to: numberLabel)
        stack.addArrangedSubview(numberLabel)
        stack.setCustomSpacing(2, after: numberLabel)

        exerciseIndexLabel.font          = .systemFont(ofSize: 15, weight: .regular)
        exerciseIndexLabel.textColor     = UIColor.white.withAlphaComponent(0.90)
        exerciseIndexLabel.textAlignment = .center
        applyTextShadow(to: exerciseIndexLabel)
        stack.addArrangedSubview(exerciseIndexLabel)
        stack.setCustomSpacing(6, after: exerciseIndexLabel)

        exerciseNameLabel.font          = .systemFont(ofSize: 19, weight: .bold)
        exerciseNameLabel.textColor     = .white
        exerciseNameLabel.textAlignment = .center
        exerciseNameLabel.numberOfLines = 2
        applyTextShadow(to: exerciseNameLabel)
        stack.addArrangedSubview(exerciseNameLabel)
        stack.setCustomSpacing(28, after: exerciseNameLabel)

        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Start", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        startButton.setTitleColor(.black, for: .normal)
        startButton.backgroundColor = .white
        startButton.layer.cornerRadius = 30
        startButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 52)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        stack.addArrangedSubview(startButton)

        updateLabels()

        NSLayoutConstraint.activate([
            playerContainer.topAnchor.constraint(equalTo: view.topAnchor),
            playerContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            dimOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            dimOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }

    private func updateLabels() {
        guard startingIndex < exercises.count else { return }
        let exercise     = exercises[startingIndex]
        let total        = exercises.count
        let doneCount    = WorkoutManager.shared.completedToday.count
                        + WorkoutManager.shared.skippedToday.count
        let displayIndex = min(doneCount + 1, total)
        exerciseIndexLabel.text = "Exercise \(displayIndex)/\(total)"
        exerciseNameLabel.text  = exercise.name
    }

    private func setupVideo() {
        guard startingIndex < exercises.count,
              let videoID = exercises[startingIndex].videoID,
              let url = Bundle.main.url(forResource: videoID, withExtension: "mp4") else { return }

        avPlayer = AVQueuePlayer()
        playerContainer.player = avPlayer

        let item = AVPlayerItem(asset: AVURLAsset(url: url))
        playerLooper = AVPlayerLooper(player: avPlayer!, templateItem: item)
    }

    private func tickCountdown() {
        numberLabel.text = "\(countDown)"
        popNumber()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            guard let self, !self.isCancelled else { return }
            self.countDown -= 1
            if self.countDown > 0 {
                self.tickCountdown()
            } else {
                self.navigateToWorkout()
            }
        }
    }

    private func popNumber() {
        numberLabel.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        UIView.animate(withDuration: 0.45,
                       delay: 0,
                       usingSpringWithDamping: 0.45,
                       initialSpringVelocity: 8,
                       options: []) {
            self.numberLabel.transform = .identity
        }
    }

    @objc private func startTapped() {
        guard !hasNavigated else { return }
        countdownTimer?.invalidate()
        navigateToWorkout()
    }

    @objc private func closeTapped() {
        isCancelled = true
        countdownTimer?.invalidate()
        if let lp = navigationController?.viewControllers.first(where: { $0 is _0minworkoutLandingPageViewController }) {
            navigationController?.popToViewController(lp, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    private func navigateToWorkout() {
        guard !hasNavigated else { return }
        hasNavigated = true
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "10minworkoutViewController")
                as? _0minworkoutViewController else { return }
        vc.exercises    = exercises
        vc.currentIndex = startingIndex
        vc.isRevisitingSkipped = isRevisitingSkipped
        if isRevisitingSkipped {
            vc.skippedIndicesToRevisit = skippedIndicesToRevisit
            vc.hasHandledSkippedExercises = true
        }
        navigationController?.pushViewController(vc, animated: false)
    }
}
