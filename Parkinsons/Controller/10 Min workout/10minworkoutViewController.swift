//
//  10minworkoutViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 24/11/25.
//

//import UIKit
//import YouTubeiOSPlayerHelper
//
//protocol RestScreenDelegate: AnyObject {
//    func recordRestDuration(seconds: TimeInterval)
//    func restCompleted(nextIndex: Int)
//}
//
//class _0minworkoutViewController: UIViewController {
//    
//    @IBOutlet weak var playerView: FullScreenYTPlayerView!
//    @IBOutlet weak var stepLabel: UILabel!
//    @IBOutlet weak var exerciseName: UILabel!
//    @IBOutlet weak var timerLabel: UILabel!
//    @IBOutlet weak var repsLabel: UILabel!
//    @IBOutlet weak var skipButton: UIButton!
//    @IBOutlet weak var backgroundView: UIView!
//    @IBOutlet weak var previousButton: UIButton!
//
//    @IBOutlet var progressBars: [UIProgressView]!
//    
//    
//    var exerciseStartTime: Date?
//    var totalWorkoutSeconds: TimeInterval = 0
//
//    var completedExerciseIDs: [UUID] = []
//    var skippedExerciseIDs: [UUID] = []
//    var timer: Timer?
//    var totalTime = 60
//    var currentIndex: Int = 0
//    var exercises: [Exercise] = WorkoutManager.shared.getTodayWorkout()
//    var exerciseDurations: [TimeInterval] = []
//
//    var shouldLoadExercise = true
//    var hasLoadedFirstExercise = false
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        backgroundView.layer.cornerRadius = 35
//        backgroundView.clipsToBounds = true
//        setupCloseButton()
//        playerView.clipsToBounds = true
//        playerView.isUserInteractionEnabled = false
//     
//        updateProgressBars()
//       
//
//        }
//   
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if !hasLoadedFirstExercise {
//            hasLoadedFirstExercise = true
//            configureExercise()
//            return
//        }
//        
//    }
//
//    func updateProgressBars() {
//        for (index, bar) in progressBars.enumerated() {
//            bar.progress = 1.0
//            bar.progressTintColor =
//                index < currentIndex ? .systemBlue :
//                index == currentIndex ? UIColor.systemBlue.withAlphaComponent(0.4) :
//                .systemGray3
//        }
//    }
//
//   
//
//
//    func configureExercise() {
//        exerciseStartTime = Date()
//
//        guard !exercises.isEmpty else {
//            showCompletion()
//            return }
//        guard currentIndex >= 0, currentIndex < exercises.count else {
//            showCompletion()
//            return }
//
//        let exercise = exercises[currentIndex]
//        exerciseName.text = exercise.name
//        repsLabel.text = "\(exercise.reps)"
//        stepLabel.text = "\(currentIndex + 1) of \(exercises.count)"
//       
//        playerView.load(
//            withVideoId: exercise.videoID ?? "",
//            playerVars: [
//                "controls": 0,
//                "modestbranding": 1,
//                "playsinline": 1,
//                "rel": 0,
//                "fs": 0,
//                "iv_load_policy": 3,
//                "disablekb": 1,
//                "showinfo": 0,
//                "autoplay": 1,
//              
//            ]
//        )
//
//        starttimer()
//        updateProgressBars()
//        previousButton.isEnabled = currentIndex > 0
//        previousButton.alpha = currentIndex > 0 ? 1.0 : 0.4
//    }
//    func starttimer() {
//        timer?.invalidate()
//        totalTime = 60
//        timerLabel.text = "\(totalTime)"
//           
//        timer = Timer.scheduledTimer(timeInterval: 1.0,
//                                     target: self,
//                                     selector: #selector(updateTimer),
//                                     userInfo: nil,
//                                     repeats: true)
//    }
//    @objc func updateTimer() {
//        if totalTime > 0 {
//            totalTime -= 1
//            timerLabel.text = "\(totalTime)"
//        } else {
//            timer?.invalidate()
//            timer = nil
//          
//        }
//    }
//
//    func goToRestScreen() {
//        if currentIndex < exercises.count - 1 {  // Not last exercise
//            let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//            let vc = sb.instantiateViewController(withIdentifier: "RestScreenViewController") as! RestScreenViewController
//            
//            vc.currentIndex = currentIndex
//            vc.totalExercises = exercises.count
//            vc.delegate = self
//
//            navigationController?.pushViewController(vc, animated: true)
//        } else {
//            showCompletion()
//        }
//    }
//    
//    func showCompletion() {
//        let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "GoodJobViewController") as! _0minworkoutGoodJobViewController
//        
//        vc.completed = WorkoutManager.shared.completedToday.count
//        vc.skipped = WorkoutManager.shared.SkippedToday.count
//        vc.totalWorkoutSeconds = totalWorkoutSeconds
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    @objc func closeButtonTapped() {
//        showQuitWorkoutAlert()
//    }
//    
//    func setupCloseButton() {
//        let closeButton = UIBarButtonItem(
//            image: UIImage(systemName: "xmark"),
//            style: .plain,
//            target: self,
//            action: #selector(closeButtonTapped)
//        )
//        navigationItem.leftBarButtonItem = closeButton
//    }
//    
//    func  recordExerciseDuration() {
//        if let start = exerciseStartTime {
//            let duration = Date().timeIntervalSince(start)
//            totalWorkoutSeconds += duration
//        }
//    }
//    
//    
//    @IBAction func infoButtonTapped(_ sender: UIButton) {
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//            let vc = sb.instantiateViewController(withIdentifier: "InfoModalViewController") as! InfoModalViewController
//        vc.exercises = exercises
//        vc.currentIndex = currentIndex
//       let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .formSheet
//        present(nav, animated: true)
//    }
//    
//    @IBAction func previousButtontapped(_ sender: UIButton) {
//        goToPreviousExercise()
//    }
//    
//    func goToPreviousExercise() {
//        guard currentIndex > 0 else { return }
//        currentIndex -= 1
//        updateProgressBars()
//        configureExercise()
//    }
//    
//    
//    @IBAction func doneButtonTapped(_ sender: UIButton) {
//        recordExerciseDuration()
//        guard !exercises.isEmpty else {return}
//        let exercise = exercises[currentIndex]
//        if !WorkoutManager.shared.completedToday.contains(exercise.id) {
//            WorkoutManager.shared.completedToday.append(exercise.id)
//        }
//        goToRestScreen()
//    }
//    
//    @IBAction func skipButtonTapped(_ sender: UIButton) {
//        recordExerciseDuration()
//        guard !exercises.isEmpty else { return }
//        let exercise = exercises[currentIndex]
//        if !WorkoutManager.shared.SkippedToday.contains(exercise.id) {
//            WorkoutManager.shared.SkippedToday.append(exercise.id)
//        }
//        goToRestScreen()
//    }
//}
//
//extension _0minworkoutViewController: RestScreenDelegate {
//    func recordRestDuration(seconds: TimeInterval) {
//            totalWorkoutSeconds += seconds
//        }
//
//    func restCompleted(nextIndex: Int) {
//        if nextIndex < exercises.count {
//            currentIndex = nextIndex
//            configureExercise()
//        } else {
//            showCompletion()
//        }
//    }
//}
//import UIKit
//import YouTubeiOSPlayerHelper
//
//class _0minworkoutViewController: UIViewController {
//    
//    @IBOutlet weak var playerView: FullScreenYTPlayerView!
//    @IBOutlet weak var exerciseName: UILabel!
//    @IBOutlet weak var timerLabel: UILabel!
//    @IBOutlet weak var repsLabel: UILabel!
//    @IBOutlet var progressBars: [UIProgressView]!
//    @IBOutlet weak var backgroundView: UIView!
//    @IBOutlet weak var exerciseCompletedLabel: UILabel!
//    @IBOutlet weak var previousButtonOutlet: UIButton!
//    
//    var exercises: [Exercise] = []
//    var currentIndex: Int = 0
//    var totalTime = 60
//    var timer: Timer?
//    var totalWorkoutSeconds: TimeInterval = 0
//    var exerciseStartTime: Date?
//    var isRevisitingSkipped = false
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNavigation()
//        configureExercise()
//        backgroundView.layer.cornerRadius = 35
//            backgroundView.clipsToBounds = true
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        updateProgressBars()
//        updateTopLabels()
//    }
//
//    func updateTopLabels() {
//        let completedCount = WorkoutManager.shared.completedToday.count
//        exerciseCompletedLabel.text = "\(completedCount) of \(exercises.count)"
//    }
//
//    private func setupNavigation() {
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            image: UIImage(systemName: "xmark"),
//            style: .plain,
//            target: self,
//            action: #selector(closeTapped)
//        )
//    }
//
//    @objc func closeTapped() {
//        showQuitWorkoutAlert()
//    }
//
//    func configureExercise() {
//        guard currentIndex < exercises.count else {
//            showCompletion()
//            return
//        }
//        previousButtonOutlet.isEnabled = (currentIndex > 0)
//        previousButtonOutlet.alpha = (currentIndex > 0) ? 1.0 : 0.5
//        
//        let exercise = exercises[currentIndex]
//        exerciseName.text = exercise.name
//        repsLabel.text = "\(exercise.reps)"
//        
//        playerView.load(withVideoId: exercise.videoID ?? "", playerVars: playerView.getParkinsonsFriendlyVars())
//        
//        startTimer()
//        updateProgressBars()
//        exerciseStartTime = Date()
//    }
//
//    func startTimer() {
//        timer?.invalidate()
//        totalTime = 60
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//            self?.updateTimerStep()
//        }
//    }
//
//    private func updateTimerStep() {
//        if totalTime > 0 {
//            totalTime -= 1
//            timerLabel.text = "\(totalTime)"
//            timerLabel.textColor = .label
//        } else {
//            timer?.invalidate()
//        }
//    }
//
//    @IBAction func doneButtonTapped(_ sender: UIButton) {
//        handleCompletion(skipped: false)
//    }
//
//    @IBAction func skipButtonTapped(_ sender: UIButton) {
//        let currentExercise = exercises[currentIndex]
//        
//        WorkoutManager.shared.SkippedToday.append(currentExercise.id)
//        
//        let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
//        if let restVC = storyboard.instantiateViewController(withIdentifier: "RestScreenViewController") as? RestScreenViewController {
//            restVC.currentIndex = self.currentIndex
//            restVC.totalExercises = self.exercises.count
//            restVC.delegate = self
//            self.navigationController?.pushViewController(restVC, animated: true)
//        }
//    }
//
//    private func handleCompletion(skipped: Bool) {
//        recordDuration()
//        let currentID = exercises[currentIndex].id
//        
//        if skipped {
//            if !WorkoutManager.shared.SkippedToday.contains(currentID) {
//                WorkoutManager.shared.SkippedToday.append(currentID)
//            }
//        } else {
//            if !WorkoutManager.shared.completedToday.contains(currentID) {
//                WorkoutManager.shared.completedToday.append(currentID)
//            }
//            // ONLY remove from skipped if it was previously skipped and now completed
//            WorkoutManager.shared.SkippedToday.removeAll { $0 == currentID }
//        }
//        
//        // Check if this is the end of the list
//        if currentIndex == exercises.count - 1 {
//            // We reached the end of the original list.
//            // Go to Rest first, then the RestScreen will trigger the alert via the delegate.
//            goToRest()
//        } else {
//            goToRest()
//        }
//    }
//
//    private func recordDuration() {
//        if let start = exerciseStartTime {
//            totalWorkoutSeconds += Date().timeIntervalSince(start)
//        }
//    }
//
//    func goToRest() {
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//        if let vc = sb.instantiateViewController(withIdentifier: "RestScreenViewController") as? RestScreenViewController {
//            vc.currentIndex = currentIndex
//            vc.totalExercises = exercises.count
//            vc.delegate = self
//            navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//    func showCompletion() {
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//        if let vc = sb.instantiateViewController(withIdentifier: "GoodJobViewController") as? _0minworkoutGoodJobViewController {
//            vc.completed = WorkoutManager.shared.completedToday.count
//            vc.totalWorkoutSeconds = totalWorkoutSeconds
//            navigationController?.setViewControllers([vc], animated: true)
//        }
//    }
//    func updateProgressBars() {
//        guard progressBars != nil else { return }
//        
//        // We iterate through all progress bars
//        for (index, bar) in progressBars.enumerated() {
//            
//            // 1. Check if this bar corresponds to an actual exercise in our current list
//            if index < exercises.count {
//                let exerciseID = exercises[index].id
//                
//                // 2. If it's already completed, fill it 100% (Blue)
//                if WorkoutManager.shared.completedToday.contains(exerciseID) {
//                    bar.progress = 1.0
//                    bar.progressTintColor = .systemBlue
//                    bar.trackTintColor = .systemGray5
//                }
//                // 3. If it is the one the user is currently doing, fill it 50%
//                else if index == currentIndex {
//                    bar.progress = 0.5
//                    bar.progressTintColor = .systemBlue
//                    bar.trackTintColor = .systemGray5
//                }
//                // 4. If it's pending (not yet reached in this sequence)
//                else {
//                    bar.progress = 0.0
//                    bar.trackTintColor = .systemGray5
//                }
//                bar.isHidden = false
//            } else {
//                // Hide extra bars if the current list is shorter than the number of bars
//                bar.isHidden = true
//            }
//        }
//    }
//    
//
//    @IBAction func previousButtonTapped(_ sender: UIButton) {
//        if currentIndex > 0 {
//            currentIndex -= 1
//
//            let transition = CATransition()
//            transition.duration = 0.4
//            transition.type = .push
//            transition.subtype = .fromLeft
//            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            
//            view.window?.layer.add(transition, forKey: kCATransition)
//            configureExercise()
//            
//            UISelectionFeedbackGenerator().selectionChanged()
//        }
//    }
//
//    func checkForSkippedExercises() {
//        let skippedIDs = WorkoutManager.shared.SkippedToday
//        
//        if !isRevisitingSkipped && !skippedIDs.isEmpty {
//            isRevisitingSkipped = true
//            
//            let alert = UIAlertController(
//                title: "You skipped some exercises.",
//                message: "Would you like to try them now?",
//                preferredStyle: .alert
//            )
//            
//            alert.addAction(UIAlertAction(title: "Maybe later", style: .cancel) { [weak self] _ in
//                self?.showCompletion()
//            })
//            
//            alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
//                guard let self = self else { return }
//                
//                if let firstSkipIndex = self.exercises.firstIndex(where: { skippedIDs.contains($0.id) }) {
//                    self.currentIndex = firstSkipIndex
//                    
//                    self.navigationController?.popViewController(animated: true)
//                    
//                    self.updateProgressBars()
//                    self.configureExercise()
//                }
//            })
//            self.navigationController?.present(alert, animated: true)
//            
//        } else {
//            showCompletion()
//        }
//    }
//}
//
//extension _0minworkoutViewController: RestScreenDelegate {
//    func recordRestDuration(seconds: TimeInterval) {
//        totalWorkoutSeconds += seconds
//    }
//
//
//    func restCompleted(nextIndex: Int) {
//        if !isRevisitingSkipped {
//            // NORMAL FLOW
//            if nextIndex < exercises.count {
//                currentIndex = nextIndex
//                configureExercise()
//            } else {
//                checkForSkippedExercises()
//            }
//        } else {
//            // REVISITING FLOW:
//            // We look through the exercises starting AFTER the current index
//            // to see if there are any more skipped IDs.
//            
//            let skippedIDs = WorkoutManager.shared.SkippedToday
//            
//            // Search for the next skipped exercise in the array after our current position
//            let remainingExercises = exercises.enumerated().filter { (index, element) in
//                index > currentIndex && skippedIDs.contains(element.id)
//            }
//            
//            if let nextSkip = remainingExercises.first {
//                currentIndex = nextSkip.offset
//                configureExercise()
//            } else {
//                // No more skips found ahead in the list
//                showCompletion()
//            }
//        }
//    }
//}














//import UIKit
//import YouTubeiOSPlayerHelper
//
//class _0minworkoutViewController: UIViewController {
//    
//    @IBOutlet weak var playerView: FullScreenYTPlayerView!
//    @IBOutlet weak var exerciseName: UILabel!
//    @IBOutlet weak var timerLabel: UILabel!
//    @IBOutlet weak var repsLabel: UILabel!
//    @IBOutlet var progressBars: [UIProgressView]!
//    @IBOutlet weak var backgroundView: UIView!
//    @IBOutlet weak var exerciseCompletedLabel: UILabel!
//    @IBOutlet weak var previousButtonOutlet: UIButton!
//    
//    var exercises: [WorkoutExercise] = []
//    var currentIndex: Int = 0
//    var timer: Timer?
//    var timeLeft: Int = 0
//    var totalWorkoutSeconds: TimeInterval = 0
//    var exerciseStartTime: Date?
//    var isRevisitingSkipped = false
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNavigation()
//        backgroundView.layer.cornerRadius = 35
//        backgroundView.clipsToBounds = true
//        
//        // Load exercises based on initial check
////        checkMedicationStatus()
//        startWorkout()
//    }
//
////    private func checkMedicationStatus() {
////        if !WorkoutManager.shared.allMedsTaken {
////            showMedicationAlert()
////        } else {
////            startWorkout()
////        }
////    }
//
//    private func startWorkout() {
//        WorkoutManager.shared.generateDailyWorkout()
//        configureExercise()
//    }
//
////    private func showMedicationAlert() {
////        let alert = UIAlertController(title: "Medication Check", message: "Meds not logged. Ready to push limits?", preferredStyle: .alert)
////        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in self.startWorkout() })
////        alert.addAction(UIAlertAction(title: "No", style: .destructive) { _ in
////            self.startWorkout() // Manager automatically handles Seated/Moderate if allMedsTaken is false
////        })
////        present(alert, animated: true)
////    }
//
//    func configureExercise() {
//        guard currentIndex < exercises.count else {
//            showCompletion()
//            return
//        }
//        
//        let exercise = exercises[currentIndex]
//        exerciseName.text = exercise.name
//        
//        // UI Logic: Timer vs Reps
//        if exercise.category == .warmup || exercise.category == .cooldown {
//            repsLabel.text = "\(exercise.reps)s"
//            startCountdown(seconds: exercise.reps)
//        } else {
//            repsLabel.text = "\(exercise.reps)"
//            timerLabel.text = ""
//            timer?.invalidate()
//        }
//        
//        playerView.load(withVideoId: exercise.videoID ?? "", playerVars: playerView.getParkinsonsFriendlyVars())
//        updateProgressBars()
//        exerciseStartTime = Date()
//    }
//
//    func startCountdown(seconds: Int) {
//        timer?.invalidate()
//        timeLeft = seconds
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            if self.timeLeft > 0 {
//                self.timeLeft -= 1
//                self.timerLabel.text = "\(self.timeLeft)"
//            } else {
//                self.timer?.invalidate()
//            }
//        }
//    }
//
//    @objc func closeTapped() {
//        let actionSheet = UIAlertController(title: "Quit Workout", message: "Select reason:", preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Physical Pain / Fatigue", style: .default) { _ in
//            // ALGORITHM: Reduce remaining reps/time
//            for i in self.currentIndex..<self.exercises.count {
//                let cat = self.exercises[i].category
//                self.exercises[i].reps = (cat == .warmup || cat == .cooldown) ? 30 : 8
//            }
//            self.configureExercise()
//        })
//        actionSheet.addAction(UIAlertAction(title: "Resume Later", style: .destructive) { _ in
//            self.dismiss(animated: true)
//        })
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(actionSheet, animated: true)
//    }
//    private func handleCompletion(skipped: Bool) {
//        recordDuration()
//        let currentID = exercises[currentIndex].id
//        
//        if skipped {
//            if !WorkoutManager.shared.SkippedToday.contains(currentID) {
//                WorkoutManager.shared.SkippedToday.append(currentID)
//            }
//        } else {
//            if !WorkoutManager.shared.completedToday.contains(currentID) {
//                WorkoutManager.shared.completedToday.append(currentID)
//            }
//            WorkoutManager.shared.SkippedToday.removeAll { $0 == currentID }
//        }
//        
//        if currentIndex == exercises.count - 1 {
//            goToRest()
//        } else {
//            goToRest()
//        }
//    }
//
//    private func recordDuration() {
//        if let start = exerciseStartTime {
//            totalWorkoutSeconds += Date().timeIntervalSince(start)
//        }
//    }
//
//    func goToRest() {
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//        if let vc = sb.instantiateViewController(withIdentifier: "RestScreenViewController") as? RestScreenViewController {
//            vc.currentIndex = currentIndex
//            vc.totalExercises = exercises.count
//            vc.delegate = self
//            navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//    func showCompletion() {
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//        if let vc = sb.instantiateViewController(withIdentifier: "GoodJobViewController") as? _0minworkoutGoodJobViewController {
//            vc.completed = WorkoutManager.shared.completedToday.count
//            vc.totalWorkoutSeconds = totalWorkoutSeconds
//            navigationController?.setViewControllers([vc], animated: true)
//        }
//    }
//    func updateProgressBars() {
//        guard progressBars != nil else { return }
//        for (index, bar) in progressBars.enumerated() {
//            if index < exercises.count {
//                let exerciseID = exercises[index].id
//                
//                if WorkoutManager.shared.completedToday.contains(exerciseID) {
//                    bar.progress = 1.0
//                    bar.progressTintColor = .systemBlue
//                    bar.trackTintColor = .systemGray5
//                }
//                
//                else if index == currentIndex {
//                    bar.progress = 0.5
//                    bar.progressTintColor = .systemBlue
//                    bar.trackTintColor = .systemGray5
//                }
//                
//                else {
//                    bar.progress = 0.0
//                    bar.trackTintColor = .systemGray5
//                }
//                bar.isHidden = false
//            } else {
//                
//                bar.isHidden = true
//            }
//        }
//    }
//    
//
//    @IBAction func previousButtonTapped(_ sender: UIButton) {
//        if currentIndex > 0 {
//            currentIndex -= 1
//
//            let transition = CATransition()
//            transition.duration = 0.4
//            transition.type = .push
//            transition.subtype = .fromLeft
//            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            
//            view.window?.layer.add(transition, forKey: kCATransition)
//            configureExercise()
//            
//            UISelectionFeedbackGenerator().selectionChanged()
//        }
//    }
//
//    func checkForSkippedExercises() {
//        let skippedIDs = WorkoutManager.shared.SkippedToday
//        
//        if !isRevisitingSkipped && !skippedIDs.isEmpty {
//            isRevisitingSkipped = true
//            
//            let alert = UIAlertController(
//                title: "You skipped some exercises.",
//                message: "Would you like to try them now?",
//                preferredStyle: .alert
//            )
//            
//            alert.addAction(UIAlertAction(title: "Maybe later", style: .cancel) { [weak self] _ in
//                self?.showCompletion()
//            })
//            
//            alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
//                guard let self = self else { return }
//                
//                if let firstSkipIndex = self.exercises.firstIndex(where: { skippedIDs.contains($0.id) }) {
//                    self.currentIndex = firstSkipIndex
//                    
//                    self.navigationController?.popViewController(animated: true)
//                    
//                    self.updateProgressBars()
//                    self.configureExercise()
//                }
//            })
//            self.navigationController?.present(alert, animated: true)
//            
//        } else {
//            showCompletion()
//        }
//    }
//    private func setupNavigation() {
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            image: UIImage(systemName: "xmark"),
//            style: .plain,
//            target: self,
//            action: #selector(closeTapped)
//        )
//    }
//}
//
//extension _0minworkoutViewController: RestScreenDelegate {
//    func recordRestDuration(seconds: TimeInterval) {
//        totalWorkoutSeconds += seconds
//    }
//
//
//    func restCompleted(nextIndex: Int) {
//        if !isRevisitingSkipped {
//            // NORMAL FLOW
//            if nextIndex < exercises.count {
//                currentIndex = nextIndex
//                configureExercise()
//            } else {
//                checkForSkippedExercises()
//            }
//        } else {
//            let skippedIDs = WorkoutManager.shared.SkippedToday
//            
//            // Search for the next skipped exercise in the array after our current position
//            let remainingExercises = exercises.enumerated().filter { (index, element) in
//                index > currentIndex && skippedIDs.contains(element.id)
//            }
//            if let nextSkip = remainingExercises.first {
//                currentIndex = nextSkip.offset
//                configureExercise()
//            }
//            else {
//                showCompletion()
//            }
//        }
//    }
//}
//





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
        setupNavigation()
        
        backgroundView.layer.cornerRadius = 35
        backgroundView.clipsToBounds = true
        
        // Ensure we have exercises from the Manager
        if exercises.isEmpty {
            exercises = WorkoutManager.shared.getTodayWorkout()
        }
        
        configureExercise()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgressBars()
        updateTopLabels()
    }

    // MARK: - Configuration & UI
    func updateTopLabels() {
        let completedCount = WorkoutManager.shared.completedToday.count
        exerciseCompletedLabel.text = "\(completedCount) of \(exercises.count)"
    }

    func configureExercise() {
        guard currentIndex < exercises.count else {
            showCompletion()
            return
        }
        
        // Handle Previous Button State
        previousButtonOutlet.isEnabled = (currentIndex > 0)
        previousButtonOutlet.alpha = (currentIndex > 0) ? 1.0 : 0.5
        
        let exercise = exercises[currentIndex]
        exerciseName.text = exercise.name
        
        // UI Logic: Timer vs Reps
        if exercise.category == .warmup || exercise.category == .cooldown {
            repsLabel.text = "\(exercise.reps)"
            timerLabel.isHidden = false
            startCountdown(seconds: exercise.reps)
        } else {
            repsLabel.text = "\(exercise.reps)"
            timerLabel.text = "GO!"
            timerLabel.isHidden = false // Keep visible to show "GO"
            timer?.invalidate()
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

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
    }

    @objc func closeTapped() {
        let quitConfirmAlert = UIAlertController(
            title: "Are you sure you want to quit?",
            message: "Your progress will be saved.",
            preferredStyle: .alert // Alert style looks better for "Are you sure" questions
        )
       
        let resumeAction = UIAlertAction(title: "Resume", style: .cancel, handler: nil)
        
        let quitAction = UIAlertAction(title: "Quit", style: .destructive) { _ in
            self.showReasonForStoppingAlert()
        }
        
        quitConfirmAlert.addAction(resumeAction)
        quitConfirmAlert.addAction(quitAction)
        
        present(quitConfirmAlert, animated: true)
    }

//    private func showReasonForStoppingAlert() {
//        let reasonAlert = UIAlertController(
//            title: "What made you stop?",
//            message: "Your feedback will help us alter the exercise set for you.",
//            preferredStyle: .actionSheet
//        )
//        let painAction = UIAlertAction(title: "Physical Pain / Fatigue", style: .default) { _ in
//
//            for i in self.currentIndex..<self.exercises.count {
//                let cat = self.exercises[i].category
//                let reducedReps = (cat == .warmup || cat == .cooldown) ? 20 : 6
//                
//                self.exercises[i].reps = reducedReps
//                WorkoutManager.shared.exercises[i].reps = reducedReps
//            }
//            
////            self.showCompletion()
//            self.navigationController?.popToRootViewController(animated: true)
//        }
//       
//        let laterAction = UIAlertAction(title: "Resume Later", style: .destructive) { _ in
//            
//            self.navigationController?.popViewController(animated: true)
//        }
//        
//        reasonAlert.addAction(painAction)
//        reasonAlert.addAction(laterAction)
//        reasonAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        present(reasonAlert, animated: true)
//    }
    
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
            if !WorkoutManager.shared.SkippedToday.contains(currentID) {
                WorkoutManager.shared.SkippedToday.append(currentID)
            }
        } else {
            if !WorkoutManager.shared.completedToday.contains(currentID) {
                WorkoutManager.shared.completedToday.append(currentID)
            }
            WorkoutManager.shared.SkippedToday.removeAll { $0 == currentID }
        }
        
        goToRest()
    }

    private func recordDuration() {
        if let start = exerciseStartTime {
            totalWorkoutSeconds += Date().timeIntervalSince(start)
        }
    }

    func goToRest() {
        timer?.invalidate() // Stop timer before leaving
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "RestScreenViewController") as? RestScreenViewController {
            vc.currentIndex = currentIndex
            vc.totalExercises = exercises.count
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func showCompletion() {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "GoodJobViewController") as? _0minworkoutGoodJobViewController {
            vc.completed = WorkoutManager.shared.completedToday.count
            vc.totalWorkoutSeconds = totalWorkoutSeconds
            navigationController?.setViewControllers([vc], animated: true)
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
        let skippedIDs = WorkoutManager.shared.SkippedToday
        if !isRevisitingSkipped && !skippedIDs.isEmpty {
            isRevisitingSkipped = true
            let alert = UIAlertController(title: "Skipped Exercises", message: "Would you like to try the exercises you skipped?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Maybe later", style: .cancel) { [weak self] _ in self?.showCompletion() })
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                guard let self = self else { return }
                if let firstSkipIndex = self.exercises.firstIndex(where: { skippedIDs.contains($0.id) }) {
                    self.currentIndex = firstSkipIndex
                    self.configureExercise()
                }
            })
            present(alert, animated: true)
        } else {
            showCompletion()
        }
    }
}

// MARK: - RestScreenDelegate
extension _0minworkoutViewController: RestScreenDelegate {
    func recordRestDuration(seconds: TimeInterval) {
        totalWorkoutSeconds += seconds
    }

    func restCompleted(nextIndex: Int) {
        if !isRevisitingSkipped {
            if nextIndex < exercises.count {
                currentIndex = nextIndex
                configureExercise()
            } else {
                checkForSkippedExercises()
            }
        } else {
            let skippedIDs = WorkoutManager.shared.SkippedToday
            let remaining = exercises.enumerated().filter { $0.offset > currentIndex && skippedIDs.contains($0.element.id) }
            
            if let nextSkip = remaining.first {
                currentIndex = nextSkip.offset
                configureExercise()
            } else {
                showCompletion()
            }
        }
    }
}
