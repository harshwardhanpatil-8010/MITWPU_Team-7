
import UIKit
import YouTubeiOSPlayerHelper

class _0minworkoutViewController: UIViewController {
    

    @IBOutlet weak var playerView: FullScreenYTPlayerView!
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
        tabBarController?.tabBar.isHidden = true
    }


    // MARK: - Configuration & UI
    func updateTopLabels() {
        let completedCount = WorkoutManager.shared.completedToday.count
        exerciseCompletedLabel.text = "\(completedCount) of \(exercises.count)"
    }


    func configureExercise() {
        guard currentIndex < exercises.count else {
            checkForSkippedExercises()
            return
        }
        
        previousButtonOutlet.isEnabled = (currentIndex > 0)
        previousButtonOutlet.alpha = (currentIndex > 0) ? 1.0 : 0.5
        
        let exercise = exercises[currentIndex]
        exerciseName.text = exercise.name
        
        if exercise.category == .warmup || exercise.category == .cooldown {
            repsLabel.text = "-"
            timerLabel.isHidden = false
            startCountdown(seconds: exercise.reps)
        } else {
            repsLabel.text = "\(exercise.reps)"
            timerLabel.text = "-"
            
            timer?.invalidate()
            timer = nil
        }
        
        
        playerView.load(withVideoId: exercise.videoID ?? "", playerVars: playerView.getParkinsonsFriendlyVars())
        updateProgressBars()
        updateTopLabels()
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

    
    @IBAction func infoButtonTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
           if let vc = sb.instantiateViewController(withIdentifier: "InfoModalViewController") as? InfoModalViewController {
               vc.exercises = exercises
               vc.currentIndex = currentIndex
               
               let nav = UINavigationController(rootViewController: vc)
               nav.modalPresentationStyle = .pageSheet
               present(nav, animated: true)
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
                let cat = self.exercises[i].category
                let reducedReps = (cat == .warmup || cat == .cooldown) ? 20 : 6
                
                self.exercises[i].reps = reducedReps
                WorkoutManager.shared.exercises[i].reps = reducedReps
            }
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
        
        goToRest()
    }

    private func recordDuration() {
        if let start = exerciseStartTime {
            totalWorkoutSeconds += Date().timeIntervalSince(start)
        }
    }

    func goToRest() {
        timer?.invalidate()
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "RestScreenViewController") as? RestScreenViewController {
            vc.currentIndex = currentIndex
            vc.totalExercises = exercises.count
            vc.totalTime = WorkoutManager.shared.restDuration
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
        for (index, bar) in progressBars.enumerated() {
            if index < exercises.count {
                let exerciseID = exercises[index].id
                if WorkoutManager.shared.completedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemBlue
                } else if index == currentIndex {
                    bar.progress = 0.5
                    bar.progressTintColor = .systemBlue
                } else {
                    bar.progress = 0.0
                }
                bar.isHidden = false
            } else {
                bar.isHidden = true
            }
        }
    }

    func checkForSkippedExercises() {
        let skippedIDs = WorkoutManager.shared.skippedToday
        
        if !isRevisitingSkipped && !skippedIDs.isEmpty {
            let alert = UIAlertController(
                title: "Skipped Exercises",
                message: "Would you like to try the exercises you skipped?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Maybe later", style: .cancel) { [weak self] _ in
                self?.showCompletion()
            })
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.isRevisitingSkipped = true
                
                if let firstSkipIndex = self.exercises.firstIndex(where: { skippedIDs.contains($0.id) }) {
                    self.currentIndex = firstSkipIndex
                    
                   
                    if self.navigationController?.topViewController != self {
                        self.navigationController?.popToViewController(self, animated: true)
                    }
                    
                    self.configureExercise()
                } else {
                    self.showCompletion()
                }
            })
            if let topVC = navigationController?.topViewController {
                topVC.present(alert, animated: true)
            } else {
                present(alert, animated: true)
            }
        } else {
            showCompletion()
        }
    }
    
}

extension _0minworkoutViewController: RestScreenDelegate {
    func recordRestDuration(seconds: TimeInterval) {
        totalWorkoutSeconds += seconds
    }

    func restCompleted(nextIndex: Int) {
        let skippedIDs = WorkoutManager.shared.skippedToday
        
        if !isRevisitingSkipped {
            if nextIndex < exercises.count {
                currentIndex = nextIndex
                configureExercise()
            } else {
                checkForSkippedExercises()
            }
        } else {
            let nextSkip = exercises.enumerated().first { (index, exercise) in
                return index > currentIndex && skippedIDs.contains(exercise.id)
            }
            
            if let next = nextSkip {
                currentIndex = next.offset
                configureExercise()
            } else {
                showCompletion()
            }
        }
    }

}



