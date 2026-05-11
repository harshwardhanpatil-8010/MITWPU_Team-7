import UIKit
import AVFoundation

class _0minworkoutViewController: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var exerciseName: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet var progressBars: [UIProgressView]!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var exerciseCompletedLabel: UILabel!
    @IBOutlet weak var previousButtonOutlet: UIButton!
    @IBOutlet weak var skipButtonOutlet: UIButton!

    weak var engine: WorkoutProgressionEngine?
    weak var delegate: WorkoutDelegate?
    
    private var isProcessing = false
    private var timer: Timer?
    private var targetDate: Date?
    private var timeLeft: Int = 0
    private var exerciseStartTime: Date?
    
    private var avPlayer: AVQueuePlayer?
    private var avPlayerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    private var pendingSpeechWorkItem: DispatchWorkItem?

    private var sortedProgressBars: [UIProgressView] {
        (progressBars ?? []).sorted { $0.frame.origin.x < $1.frame.origin.x }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 35
        backgroundView.clipsToBounds = true
        playerView.isUserInteractionEnabled = false
        
        configureExercise()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isProcessing = false
        updateProgressBars()
        updateTopLabels()
        updatePreviousButton()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avPlayerLayer?.frame = playerView.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pendingSpeechWorkItem?.cancel()
        timer?.invalidate()
        timer = nil
        avPlayer?.pause()
        avPlayer?.removeAllItems()
        SpeechManager.shared.stop()
    }
    
    private func updatePreviousButton() {
        let canGoBack = engine?.canGoPrevious ?? false
        previousButtonOutlet.isEnabled = canGoBack
        previousButtonOutlet.alpha     = canGoBack ? 1.0 : 0.4
    }

    func updateTopLabels() {
        guard let engine = engine else { return }
        let total = engine.allExercises.count
        let displayIndex = min(engine.currentIndexInGlobalArray + 1, total)
        exerciseCompletedLabel.text = "\(displayIndex) of \(total)"
    }

    private func setupAVPlayer() {
        if avPlayer == nil {
            avPlayer = AVQueuePlayer()
            avPlayerLayer = AVPlayerLayer(player: avPlayer)
            avPlayerLayer?.videoGravity = .resizeAspectFill
            guard let avPlayerLayer = avPlayerLayer else { return }
            playerView.layer.addSublayer(avPlayerLayer)
        }
        playerLooper = nil
        avPlayer?.pause()
        avPlayer?.removeAllItems()
    }

    func configureExercise() {
        guard let engine = engine, let exercise = engine.currentExercise else { return }
        setupAVPlayer()
        exerciseName.text = exercise.name

        pendingSpeechWorkItem?.cancel()
        SpeechManager.shared.stop()

        if let videoName = exercise.videoID,
           let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            playerLooper = AVPlayerLooper(player: avPlayer!, templateItem: item)
            avPlayer?.play()
        }

        if exercise.category == .warmup || exercise.category == .cooldown {
            repsLabel.text = "-"
            timerLabel.isHidden = false
            startCountdown(seconds: exercise.timerSeconds)
        } else {
            repsLabel.text = "\(exercise.reps)"
            timerLabel.text = "-"
            timer?.invalidate()
            timer = nil
        }

        if let instruction = exercise.voiceInstruction?.trimmingCharacters(in: .whitespacesAndNewlines),
           !instruction.isEmpty {
            let exerciseID = exercise.id
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self,
                      let currentEx = self.engine?.currentExercise,
                      currentEx.id == exerciseID else { return }
                SpeechManager.shared.speak(instruction)
            }
            pendingSpeechWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
        }

        updateProgressBars()
        updateTopLabels()
        updatePreviousButton()
        updateSkipButton()
        exerciseStartTime = Date()
    }
    
    private func updateSkipButton() {
        guard let engine = engine, let exercise = engine.currentExercise else { return }
        let isDone = WorkoutManager.shared.completedToday.contains(exercise.id)
        skipButtonOutlet?.isEnabled = !isDone
        skipButtonOutlet?.alpha = isDone ? 0.4 : 1.0
    }

    func startCountdown(seconds: Int) {
        timer?.invalidate()
        targetDate = Date().addingTimeInterval(TimeInterval(seconds))
        timeLeft = seconds
        timerLabel.text = "\(timeLeft)"
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tickCountdown()
        }
    }

    private func tickCountdown() {
        guard let target = targetDate else { return }
        let remaining = Int(ceil(target.timeIntervalSinceNow))
        
        if remaining <= 0 {
            timer?.invalidate()
            timer = nil
            timerLabel.text = "0"
            return
        }
        
        if remaining != self.timeLeft {
            self.timeLeft = remaining
            self.timerLabel.text = "\(self.timeLeft)"
        }
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        handleCompletion(skipped: false)
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        handleCompletion(skipped: true)
    }

    @IBAction func previousButtonTapped(_ sender: UIButton) {
        guard !isProcessing else { return }
        isProcessing = true
        UISelectionFeedbackGenerator().selectionChanged()
        delegate?.workoutDidRequestPrevious()
    }

    private func handleCompletion(skipped: Bool) {
        guard !isProcessing else { return }
        isProcessing = true
        
        timer?.invalidate()
        avPlayer?.pause()
        
        var duration: TimeInterval = 0
        if let start = exerciseStartTime {
            duration = Date().timeIntervalSince(start)
        }
        
        delegate?.workoutDidFinish(skipped: skipped, duration: duration)
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Are you sure you want to quit?",
            message: "Your progress will be saved.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Resume", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { [weak self] _ in
            self?.showReasonForStoppingAlert()
        })
        present(alert, animated: true)
    }

    private func showReasonForStoppingAlert() {
        let reasonAlert = UIAlertController(
            title: "What made you stop?",
            message: "Your feedback will help us alter the exercise set for you.",
            preferredStyle: .actionSheet
        )
        let painAction = UIAlertAction(title: "Physical Pain / Fatigue", style: .default) { [weak self] _ in
            self?.delegate?.workoutDidRequestQuitEarly()
        }
        reasonAlert.addAction(painAction)
        reasonAlert.addAction(UIAlertAction(title: "Resume Later", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        reasonAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(reasonAlert, animated: true)
    }

    func updateProgressBars() {
        guard progressBars != nil, let engine = engine else { return }
        for (index, bar) in sortedProgressBars.enumerated() {
            if index < engine.allExercises.count {
                let exerciseID = engine.allExercises[index].id
                
                if WorkoutManager.shared.completedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemBlue
                } else if WorkoutManager.shared.skippedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemGray4
                } else if index == engine.currentIndexInGlobalArray {
                    bar.progress = 0.5
                    bar.progressTintColor = .systemBlue
                } else {
                    bar.progress = 0.0
                    bar.progressTintColor = .systemBlue
                }
                bar.trackTintColor = .systemGray5
                bar.isHidden = false
            } else {
                bar.isHidden = true
            }
        }
    }
}
