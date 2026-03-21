//import UIKit
//import AVFoundation
//
///// "Ready to Go" countdown shown before every exercise.
///// The upcoming exercise's video plays silently in the background.
//class ExerciseCountdownViewController: UIViewController {
//
//    // MARK: - Public config
//    var exercises: [WorkoutExercise] = []
//    var startingIndex: Int = 0
//
//    // MARK: - Private state
//    private var countDown = 10
//    private var hasNavigated = false
//    private var isCancelled = false
//    private var countdownTimer: Timer?
//    private var isCountdownRunning = false
//
//    // MARK: - AV
//    private var avPlayer: AVQueuePlayer?
//    private var avPlayerLayer: AVPlayerLayer?
//    private var playerLooper: AVPlayerLooper?
//
//    // MARK: - UI
//    private let videoContainer     = UIView()
//    private let dimOverlay         = UIView()
//    private let readyLabel         = UILabel()
//    private let numberLabel        = UILabel()
//    private let exerciseIndexLabel = UILabel()
//    private let exerciseNameLabel  = UILabel()
//    private let startButton        = UIButton(type: .system)
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        view.backgroundColor = .black
//        buildUI()
//        setupVideo()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        isCancelled = false
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//        tabBarController?.tabBar.isHidden = true
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        avPlayer?.play()
//        if !isCountdownRunning {
//            isCountdownRunning = true
//            tickCountdown()
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        isCancelled = true
//        countdownTimer?.invalidate()
//        countdownTimer = nil
//        avPlayer?.pause()
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        layoutVideoToFillScreen()
//    }
//
//    // MARK: - Video layout
//    // Videos are square (1:1). On a portrait iPhone the screen is taller than it is wide,
//    // so we size the layer to be screen-height × screen-height and center it horizontally,
//    // then clip to the view bounds. This makes the video fill every pixel of the screen.
//    private func layoutVideoToFillScreen() {
//        let screenW = view.bounds.width
//        let screenH = view.bounds.height
//
//        // Use the larger dimension as the side length so it always covers the screen
//        let side = max(screenW, screenH)
//
//        let x = (screenW - side) / 2
//        let y = (screenH - side) / 2
//
//        avPlayerLayer?.frame = CGRect(x: x, y: y, width: side, height: side)
//    }
//
//    // MARK: - UI Construction
//
//    private func applyTextShadow(to label: UILabel) {
//        label.layer.shadowColor   = UIColor.black.cgColor
//        label.layer.shadowOpacity = 0.60
//        label.layer.shadowOffset  = CGSize(width: 0, height: 1)
//        label.layer.shadowRadius  = 5
//        label.layer.masksToBounds = false
//    }
//
//    private func buildUI() {
//        // Full-screen video container — clips the oversized layer
//        videoContainer.frame = view.bounds
//        videoContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        videoContainer.backgroundColor = .black
//        videoContainer.clipsToBounds = true
//        view.addSubview(videoContainer)
//
//        // Light overlay
//        dimOverlay.frame = view.bounds
//        dimOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        dimOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.18)
//        view.addSubview(dimOverlay)
//
//        // Close (×) button
//        let closeButton = UIButton(type: .system)
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        closeButton.setImage(
//            UIImage(systemName: "xmark",
//                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
//            for: .normal
//        )
//        closeButton.tintColor = .white
//        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.28)
//        closeButton.layer.cornerRadius = 20
//        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
//        view.addSubview(closeButton)
//
//        // Central content stack
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis      = .vertical
//        stack.alignment = .center
//        stack.spacing   = 4
//        view.addSubview(stack)
//
//        // "Next Exercise in"
//        readyLabel.text          = "Next Exercise in"
//        readyLabel.font          = .systemFont(ofSize: 17, weight: .semibold)
//        readyLabel.textColor     = .white
//        readyLabel.textAlignment = .center
//        applyTextShadow(to: readyLabel)
//        stack.addArrangedSubview(readyLabel)
//        stack.setCustomSpacing(0, after: readyLabel)
//
//        // Big countdown number
//        numberLabel.font          = .systemFont(ofSize: 108, weight: .bold)
//        numberLabel.textColor     = .white
//        numberLabel.textAlignment = .center
//        numberLabel.text          = "\(countDown)"
//        applyTextShadow(to: numberLabel)
//        stack.addArrangedSubview(numberLabel)
//        stack.setCustomSpacing(2, after: numberLabel)
//
//        // "Exercise N/total"
//        exerciseIndexLabel.font          = .systemFont(ofSize: 15, weight: .regular)
//        exerciseIndexLabel.textColor     = UIColor.white.withAlphaComponent(0.90)
//        exerciseIndexLabel.textAlignment = .center
//        applyTextShadow(to: exerciseIndexLabel)
//        stack.addArrangedSubview(exerciseIndexLabel)
//        stack.setCustomSpacing(6, after: exerciseIndexLabel)
//
//        // Exercise name
//        exerciseNameLabel.font          = .systemFont(ofSize: 19, weight: .bold)
//        exerciseNameLabel.textColor     = .white
//        exerciseNameLabel.textAlignment = .center
//        exerciseNameLabel.numberOfLines = 2
//        applyTextShadow(to: exerciseNameLabel)
//        stack.addArrangedSubview(exerciseNameLabel)
//        stack.setCustomSpacing(28, after: exerciseNameLabel)
//
//        // "Start!" pill button
//        startButton.translatesAutoresizingMaskIntoConstraints = false
//        startButton.setTitle("Start!", for: .normal)
//        startButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
//        startButton.setTitleColor(.black, for: .normal)
//        startButton.backgroundColor = .white
//        startButton.layer.cornerRadius = 30
//        startButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 52)
//        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
//        stack.addArrangedSubview(startButton)
//
//        updateLabels()
//
//        NSLayoutConstraint.activate([
//            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
//            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            closeButton.widthAnchor.constraint(equalToConstant: 40),
//            closeButton.heightAnchor.constraint(equalToConstant: 40),
//
//            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80),
//            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
//            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
//
//            startButton.heightAnchor.constraint(equalToConstant: 60),
//            startButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
//        ])
//    }
//
//    private func updateLabels() {
//        guard startingIndex < exercises.count else { return }
//        let exercise     = exercises[startingIndex]
//        let total        = exercises.count
//        let doneCount    = WorkoutManager.shared.completedToday.count
//                        + WorkoutManager.shared.skippedToday.count
//        let displayIndex = min(doneCount + 1, total)
//
//        exerciseIndexLabel.text = "Exercise \(displayIndex)/\(total)"
//        exerciseNameLabel.text  = exercise.name
//    }
//
//    // MARK: - Video setup
//
//    private func setupVideo() {
//        guard startingIndex < exercises.count,
//              let videoID = exercises[startingIndex].videoID,
//              let url = Bundle.main.url(forResource: videoID, withExtension: "mp4") else { return }
//
//        avPlayer      = AVQueuePlayer()
//        avPlayerLayer = AVPlayerLayer(player: avPlayer)
//        // We do NOT use resizeAspectFill here — we manually size the layer in
//        // layoutVideoToFillScreen() to handle the square→portrait stretch.
//        avPlayerLayer?.videoGravity = .resizeAspectFill
//        avPlayerLayer?.frame        = videoContainer.bounds  // will be corrected in viewDidLayoutSubviews
//        videoContainer.layer.addSublayer(avPlayerLayer!)
//
//        let item = AVPlayerItem(asset: AVURLAsset(url: url))
//        playerLooper = AVPlayerLooper(player: avPlayer!, templateItem: item)
//    }
//
//    // MARK: - Countdown
//
//    private func tickCountdown() {
//        numberLabel.text = "\(countDown)"
//        popNumber()
//
//        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
//            guard let self, !self.isCancelled else { return }
//            self.countDown -= 1
//            if self.countDown > 0 {
//                self.tickCountdown()
//            } else {
//                self.navigateToWorkout()
//            }
//        }
//    }
//
//    private func popNumber() {
//        numberLabel.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
//        UIView.animate(withDuration: 0.45,
//                       delay: 0,
//                       usingSpringWithDamping: 0.45,
//                       initialSpringVelocity: 8,
//                       options: []) {
//            self.numberLabel.transform = .identity
//        }
//    }
//
//    // MARK: - Actions
//
//    @objc private func startTapped() {
//        guard !hasNavigated else { return }
//        countdownTimer?.invalidate()
//        countdownTimer = nil
//        navigateToWorkout()
//    }
//
//    @objc private func closeTapped() {
//        isCancelled = true
//        countdownTimer?.invalidate()
//        countdownTimer = nil
//        if let landingVC = navigationController?.viewControllers
//                .first(where: { $0 is _0minworkoutLandingPageViewController }) {
//            navigationController?.popToViewController(landingVC, animated: true)
//        } else {
//            navigationController?.popToRootViewController(animated: true)
//        }
//    }
//
//    // MARK: - Navigation
//
//    private func navigateToWorkout() {
//        guard !hasNavigated else { return }
//        hasNavigated = true
//
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//        guard let vc = sb.instantiateViewController(withIdentifier: "10minworkoutViewController")
//                as? _0minworkoutViewController else { return }
//        vc.exercises    = exercises
//        vc.currentIndex = startingIndex
//        navigationController?.pushViewController(vc, animated: false)
//    }
//}





import UIKit
import AVFoundation

// MARK: - PlayerFillView
// A UIView whose backing layer IS the AVPlayerLayer.
// overriding layerClass is the only reliable way to keep the layer
// in sync with Auto Layout — UIKit drives bounds changes through
// the view hierarchy, and layoutSubviews is the final word on size.
private final class PlayerFillView: UIView {

    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Videos are square (1:1). Portrait iPhone is taller than wide.
        // We want the video to fill the FULL screen — scale so the shorter
        // dimension (width) maps to the screen width, and the excess height
        // hangs off the top/bottom equally, then clip.
        //
        // Concretely: side = screenHeight, center horizontally.
        // This fills every pixel with video — no black bars anywhere.

        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else { return }

        let side = max(w, h)
        let x    = (w - side) / 2
        let y    = (h - side) / 2

        // Disable implicit CA animations so the frame snaps instantly
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = CGRect(x: x, y: y, width: side, height: side)
        playerLayer.videoGravity = .resizeAspectFill
        CATransaction.commit()
    }
}

// MARK: - ExerciseCountdownViewController

class ExerciseCountdownViewController: UIViewController {

    // MARK: - Public config
    var exercises: [WorkoutExercise] = []
    var startingIndex: Int = 0

    // MARK: - Private state
    private var countDown = 10
    private var hasNavigated = false
    private var isCancelled = false
    private var countdownTimer: Timer?
    private var isCountdownRunning = false

    // MARK: - AV
    private var avPlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?

    // MARK: - UI
    private let playerFillView     = PlayerFillView()
    private let dimOverlay         = UIView()
    private let readyLabel         = UILabel()
    private let numberLabel        = UILabel()
    private let exerciseIndexLabel = UILabel()
    private let exerciseNameLabel  = UILabel()
    private let startButton        = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
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
        // Force a layout pass now that the view has its final on-screen bounds
        playerFillView.setNeedsLayout()
        playerFillView.layoutIfNeeded()
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

    // MARK: - UI Construction

    private func applyTextShadow(to label: UILabel) {
        label.layer.shadowColor   = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.65
        label.layer.shadowOffset  = CGSize(width: 0, height: 1)
        label.layer.shadowRadius  = 6
        label.layer.masksToBounds = false
    }

    private func buildUI() {
        // PlayerFillView — pinned to ALL edges (under notch, home bar, everything)
        playerFillView.translatesAutoresizingMaskIntoConstraints = false
        playerFillView.backgroundColor = .black
        playerFillView.clipsToBounds   = true   // crops the oversized square layer
        view.addSubview(playerFillView)

        // Dim overlay
        dimOverlay.translatesAutoresizingMaskIntoConstraints = false
        dimOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.20)
        view.addSubview(dimOverlay)

        // Close (×) button
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(
            UIImage(systemName: "xmark",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
            for: .normal
        )
        closeButton.tintColor       = .white
        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.28)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        // Content stack
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
        startButton.setTitle("Start!", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        startButton.setTitleColor(.black, for: .normal)
        startButton.backgroundColor = .white
        startButton.layer.cornerRadius = 30
        startButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 52)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        stack.addArrangedSubview(startButton)

        updateLabels()

        NSLayoutConstraint.activate([
            // Fill entire screen — ignore safe area so video goes edge to edge
            playerFillView.topAnchor.constraint(equalTo: view.topAnchor),
            playerFillView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerFillView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerFillView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            dimOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            dimOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),

            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
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

    // MARK: - Video setup

    private func setupVideo() {
        guard startingIndex < exercises.count,
              let videoID = exercises[startingIndex].videoID,
              let url = Bundle.main.url(forResource: videoID, withExtension: "mp4") else { return }

        avPlayer = AVQueuePlayer()
        playerFillView.player = avPlayer

        let item = AVPlayerItem(asset: AVURLAsset(url: url))
        playerLooper = AVPlayerLooper(player: avPlayer!, templateItem: item)
    }

    // MARK: - Countdown

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

    // MARK: - Actions

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

    // MARK: - Navigation

    private func navigateToWorkout() {
        guard !hasNavigated else { return }
        hasNavigated = true
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "10minworkoutViewController")
                as? _0minworkoutViewController else { return }
        vc.exercises    = exercises
        vc.currentIndex = startingIndex
        navigationController?.pushViewController(vc, animated: false)
    }
}
