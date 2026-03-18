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
    private var hasHandledSkippedExercises = false
    private var skippedIndicesToRevisit: [Int] = []
    private var skippedRevisitPointer: Int = 0
    private var pendingSpeechWorkItem: DispatchWorkItem?

    private var sortedProgressBars: [UIProgressView] {
        (progressBars ?? []).sorted { $0.frame.origin.x < $1.frame.origin.x }
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
    
    
    func hasRemainingSkippedExercises() -> Bool {
        return !WorkoutManager.shared.skippedToday.isEmpty
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
        let quitConfirmAlert = UIAlertController(
            title: "Are you sure you want to quit?",
            message: "Your progress will be saved.",
            preferredStyle: .alert
        )
        let resumeAction = UIAlertAction(title: "Resume", style: .cancel, handler: nil)
        let quitAction = UIAlertAction(title: "Quit", style: .destructive) { _ in
            self.showReasonForStoppingAlert()
        }
        
        quitConfirmAlert.addAction(resumeAction)
        quitConfirmAlert.addAction(quitAction)
        
        present(quitConfirmAlert, animated: true)
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
                    
                    self.exercises[i].duration = min(self.exercises[i].duration ?? 40, 30)
                    if let managerIndex = WorkoutManager.shared.exercises.firstIndex(where: { $0.id == exerciseID }) {
                        WorkoutManager.shared.exercises[managerIndex].duration =
                            min(WorkoutManager.shared.exercises[managerIndex].duration ?? 40, 30)
                    }
                } else {
                    self.exercises[i].reps = min(self.exercises[i].reps, 8)
                    if let managerIndex = WorkoutManager.shared.exercises.firstIndex(where: { $0.id == exerciseID }) {
                        WorkoutManager.shared.exercises[managerIndex].reps =
                            min(WorkoutManager.shared.exercises[managerIndex].reps, 8)
                    }
                }
            }
            WorkoutManager.shared.syncSessionPersistence()
            self.navigateToLandingPage()
        }
        
        let laterAction = UIAlertAction(title: "Resume Later", style: .destructive) { _ in
            self.navigateToLandingPage()
        }
        
        reasonAlert.addAction(painAction)
        reasonAlert.addAction(laterAction)
        reasonAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(reasonAlert, animated: true)
    }

    // MARK: - Navigation Helper
    private func navigateToLandingPage() {
        if let landingVC = self.navigationController?.viewControllers.first(where: { $0 is _0minworkoutLandingPageViewController }) {
            self.navigationController?.popToViewController(landingVC, animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
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
            currentIndex += 1
        } else {
            if !WorkoutManager.shared.completedToday.contains(currentID) {
                WorkoutManager.shared.completedToday.append(currentID)
            }
            WorkoutManager.shared.skippedToday.removeAll { $0 == currentID }
            currentIndex += 1
        }

        WorkoutManager.shared.syncSessionPersistence()
        goToRest(nextExerciseIndex: nextIndex)
    }




    private func recordDuration() {
        if let start = exerciseStartTime {
            totalWorkoutSeconds += Date().timeIntervalSince(start)
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
            vc.currentIndex = currentIndex
            vc.nextExerciseIndex = nextExerciseIndex
            vc.totalExercises = exercises.count
            vc.exercises = exercises
            vc.delegate = self
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
                skippedIDs.contains(self.exercises[$0].id)
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

extension _0minworkoutViewController: RestScreenDelegate {
    func recordRestDuration(seconds: TimeInterval) {
        totalWorkoutSeconds += seconds
    }
    func restCompleted() {
        if !isRevisitingSkipped {
            if currentIndex < exercises.count {
                configureExercise()
                return
            }
            checkForSkippedExercises()
            return
        }
        skippedRevisitPointer += 1
        if skippedRevisitPointer < skippedIndicesToRevisit.count {
            currentIndex = skippedIndicesToRevisit[skippedRevisitPointer]
            configureExercise()
        } else {
            isRevisitingSkipped = false
            skippedIndicesToRevisit.removeAll()
            showCompletion()
        }
    }


}
