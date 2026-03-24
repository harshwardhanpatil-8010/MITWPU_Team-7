
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

    var exercises: [WorkoutExercise] = []
    var currentIndex: Int = 0
    var timer: Timer?
    var timeLeft: Int = 0
    var totalWorkoutSeconds: TimeInterval = 0
    var exerciseStartTime: Date?
    var isRevisitingSkipped = false
    private var avPlayer: AVQueuePlayer?
    private var avPlayerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    var hasHandledSkippedExercises = false
    var skippedIndicesToRevisit: [Int] = []
    private var skippedRevisitPointer: Int = 0
    private var pendingSpeechWorkItem: DispatchWorkItem?

    private var sortedProgressBars: [UIProgressView] {
        (progressBars ?? []).sorted { $0.frame.origin.x < $1.frame.origin.x }
    }

    private var unresolvedSkippedIDs: [UUID] {
        let validExerciseIDs = Set(exercises.map(\.id))
        let completedIDs = Set(WorkoutManager.shared.completedToday)
        return WorkoutManager.shared.skippedToday.filter { skippedID in
            validExerciseIDs.contains(skippedID) && !completedIDs.contains(skippedID)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 35
        backgroundView.clipsToBounds = true
        playerView.isUserInteractionEnabled = false
        
        if exercises.isEmpty {
            exercises = WorkoutManager.shared.getTodayWorkout()
        }
        configureExercise()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        avPlayer?.pause()
        SpeechManager.shared.stop()
    }
    
    private func updatePreviousButton() {
        let isFirst = currentIndex == 0
        previousButtonOutlet.isEnabled = !isFirst
        previousButtonOutlet.alpha     = isFirst ? 0.4 : 1.0
    }

    func updateTopLabels() {
        let completedCount = WorkoutManager.shared.completedToday.count
        exerciseCompletedLabel.text = "\(completedCount) of \(exercises.count)"
    }

    private func setupAVPlayer() {
        if avPlayer != nil { return }
        avPlayer = AVQueuePlayer()
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = .resizeAspectFill
        guard let avPlayerLayer else { return }
        playerView.layer.addSublayer(avPlayerLayer)
    }

    func configureExercise() {
        if !isRevisitingSkipped {
            if let nextPendingIndex = nextMainRunIndex(startingAt: currentIndex) {
                currentIndex = nextPendingIndex
            } else {
                currentIndex = exercises.count
            }
        }

        guard currentIndex < exercises.count else {
            checkForSkippedExercises()
            return
        }
        setupAVPlayer()
        let exercise = exercises[currentIndex]
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
                guard
                    let self,
                    self.currentIndex < self.exercises.count,
                    self.exercises[self.currentIndex].id == exerciseID
                else { return }
                SpeechManager.shared.speak(instruction)
            }
            pendingSpeechWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
        }

        updateProgressBars()
        updateTopLabels()
        updatePreviousButton()
        exerciseStartTime = Date()
    }

    func startCountdown(seconds: Int) {
        timer?.invalidate()
        timeLeft = seconds
        timerLabel.text = "\(timeLeft)"
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeLeft > 0 {
                self.timeLeft -= 1
                self.timerLabel.text = "\(self.timeLeft)"
            } else {
                self.timer?.invalidate()
                self.timerLabel.text = "0"
            }
        }
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        handleCompletion(skipped: false)
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        handleCompletion(skipped: true)
    }

    @IBAction func previousButtonTapped(_ sender: UIButton) {
        if currentIndex > 0 {
            currentIndex -= 1
            let transition = CATransition()
            transition.duration = 0.4
            transition.type = .push
            transition.subtype = .fromLeft
            view.window?.layer.add(transition, forKey: kCATransition)
            configureExercise()
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Are you sure you want to quit?",
            message: "Your progress will be saved.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Resume", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { _ in
            self.showReasonForStoppingAlert()
        })
        present(alert, animated: true)
    }

    private func showReasonForStoppingAlert() {
        let reasonAlert = UIAlertController(
            title: "What made you stop?",
            message: "Your feedback will help us alter the exercise set for you.",
            preferredStyle: .actionSheet
        )
        let painAction = UIAlertAction(title: "Physical Pain / Fatigue", style: .default) { _ in
            for i in self.currentIndex..<self.exercises.count {
                let exerciseID = self.exercises[i].id
                let cat = self.exercises[i].category
                if cat == .warmup || cat == .cooldown {

                    self.exercises[i].duration = 50
                    if let mi = WorkoutManager.shared.exercises.firstIndex(where: { $0.id == exerciseID }) {
                        WorkoutManager.shared.exercises[mi].duration = 50
                    }
                } else {
                    self.exercises[i].reps = 6
                    if let mi = WorkoutManager.shared.exercises.firstIndex(where: { $0.id == exerciseID }) {
                        WorkoutManager.shared.exercises[mi].reps = 6
                    }
                }
            }
            WorkoutManager.shared.syncSessionPersistence()
            self.navigateToLandingPage()
        }
        reasonAlert.addAction(painAction)
        reasonAlert.addAction(UIAlertAction(title: "Resume Later", style: .destructive) { _ in
            self.navigateToLandingPage()
        })
        reasonAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(reasonAlert, animated: true)
    }

    private func navigateToLandingPage() {
        if let lp = navigationController?.viewControllers.first(where: { $0 is _0minworkoutLandingPageViewController }) {
            navigationController?.popToViewController(lp, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    private func handleCompletion(skipped: Bool) {
        recordDuration()
        let currentID = exercises[currentIndex].id
        let nextIndex = nextExerciseIndex(afterCompletingAt: currentIndex)

        if skipped {
            if !WorkoutManager.shared.skippedToday.contains(currentID) {
                WorkoutManager.shared.skippedToday.append(currentID)
            }
        } else {
            if !WorkoutManager.shared.completedToday.contains(currentID) {
                WorkoutManager.shared.completedToday.append(currentID)
            }
            WorkoutManager.shared.skippedToday.removeAll { $0 == currentID }
        }
        
        if let next = nextIndex {
            currentIndex = next
        } else {
            currentIndex = exercises.count
        }
        
        WorkoutManager.shared.syncSessionPersistence()
        goToRest(nextExerciseIndex: nextIndex)
    }

    private func recordDuration() {
        if let start = exerciseStartTime {
            totalWorkoutSeconds += Date().timeIntervalSince(start)
        }
    }

    private func nextMainRunIndex(startingAt startIndex: Int) -> Int? {
        guard startIndex < exercises.count else { return nil }

        let completedIDs = Set(WorkoutManager.shared.completedToday)
        let skippedIDs = Set(WorkoutManager.shared.skippedToday)
        return exercises.indices[startIndex...].first { index in
            !completedIDs.contains(exercises[index].id) && !skippedIDs.contains(exercises[index].id)
        }
    }

    private func nextExerciseIndex(afterCompletingAt completedIndex: Int) -> Int? {
        if isRevisitingSkipped {
            guard let currentSkippedPointer = skippedIndicesToRevisit.firstIndex(of: completedIndex) else {
                return nil
            }

            let nextPointer = currentSkippedPointer + 1
            guard nextPointer < skippedIndicesToRevisit.count else {
                return nil
            }
            return skippedIndicesToRevisit[nextPointer]
        }


        let nextIndex = completedIndex + 1
        return nextIndex < exercises.count ? nextIndex : nil

    }

    func goToRest(nextExerciseIndex: Int?) {
        timer?.invalidate()
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "RestScreenViewController") as? RestScreenViewController {

            vc.currentIndex   = currentIndex   
            vc.totalExercises = exercises.count
            vc.exercises      = exercises
            vc.delegate       = self
            vc.isRevisitingSkipped = self.isRevisitingSkipped
            vc.skippedIndicesToRevisit = self.skippedIndicesToRevisit

            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func showCompletion() {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "GoodJobViewController") as? _0minworkoutGoodJobViewController {
            vc.completed = WorkoutManager.shared.completedToday.count
            vc.totalWorkoutSeconds = totalWorkoutSeconds
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func updateProgressBars() {
        guard progressBars != nil else { return }
        for (index, bar) in sortedProgressBars.enumerated() {
            if index < exercises.count {
                let exerciseID = exercises[index].id
                if WorkoutManager.shared.completedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemBlue
                } else if WorkoutManager.shared.skippedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemGray4
                } else if index == currentIndex {
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

    func checkForSkippedExercises() {

        let unresolvedSkipped = unresolvedSkippedIDs
        let staleSkipped = Set(WorkoutManager.shared.skippedToday).subtracting(unresolvedSkipped)
        if !staleSkipped.isEmpty {
            WorkoutManager.shared.skippedToday.removeAll { staleSkipped.contains($0) }
            WorkoutManager.shared.syncSessionPersistence()
        }

        if hasHandledSkippedExercises {
            showCompletion()
            return
        }


        let skippedIDs = WorkoutManager.shared.skippedToday
        guard !skippedIDs.isEmpty else {

            showCompletion()
            return
        }

        let alert = UIAlertController(
            title: "Skipped Exercises",
            message: "Would you like to try the exercises you skipped?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Maybe later", style: .cancel) { [weak self] _ in
            self?.hasHandledSkippedExercises = true
            self?.showCompletion()
        })

        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.hasHandledSkippedExercises = true
            self.isRevisitingSkipped = true

            self.skippedIndicesToRevisit = self.exercises.indices.filter {
                unresolvedSkipped.contains(self.exercises[$0].id)
            }
            self.skippedRevisitPointer = 0

            if let first = self.skippedIndicesToRevisit.first {
                self.currentIndex = first
                self.configureExercise()
            } else {
                self.showCompletion()
            }
        })

        present(alert, animated: true)
    }
}

// MARK: - RestScreenDelegate

extension _0minworkoutViewController: RestScreenDelegate {

    func recordRestDuration(seconds: TimeInterval) {
        totalWorkoutSeconds += seconds
    }

    /// Rest finished and there IS a next exercise — just sync our pointer.
    /// The rest screen already pushed the countdown VC.
    func restCompleted(exercises: [WorkoutExercise], nextIndex: Int) {
        self.exercises    = exercises
        self.currentIndex = nextIndex
    }

    /// Rest finished but there are NO more exercises left.
    /// The rest screen already popped itself; now we decide what comes next.
    func restCompletedWorkoutDone() {
        if isRevisitingSkipped {
            isRevisitingSkipped = false
            skippedIndicesToRevisit.removeAll()
            showCompletion()
        } else {
            checkForSkippedExercises()
        }
    }
}
