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
    var totalTime = 60
    var timer: Timer?
    var totalWorkoutSeconds: TimeInterval = 0
    var exerciseStartTime: Date?
    var isRevisitingSkipped = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        configureExercise()
        backgroundView.layer.cornerRadius = 35
            backgroundView.clipsToBounds = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgressBars()
        updateTopLabels()
    }

    func updateTopLabels() {
        let completedCount = WorkoutManager.shared.completedToday.count
        exerciseCompletedLabel.text = "\(completedCount) of \(exercises.count)"
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
        showQuitWorkoutAlert()
    }

    func configureExercise() {
        guard currentIndex < exercises.count else {
            showCompletion()
            return
        }
        previousButtonOutlet.isEnabled = (currentIndex > 0)
        previousButtonOutlet.alpha = (currentIndex > 0) ? 1.0 : 0.5
        
        let exercise = exercises[currentIndex]
        exerciseName.text = exercise.name
        repsLabel.text = "\(exercise.reps)"
        
        playerView.load(withVideoId: exercise.videoID ?? "", playerVars: playerView.getParkinsonsFriendlyVars())
        
        startTimer()
        updateProgressBars()
        exerciseStartTime = Date()
    }

    func startTimer() {
        timer?.invalidate()
        totalTime = 60
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimerStep()
        }
    }

    private func updateTimerStep() {
        if totalTime > 0 {
            totalTime -= 1
            timerLabel.text = "\(totalTime)"
            timerLabel.textColor = .label
        } else {
            timer?.invalidate()
        }
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        handleCompletion(skipped: false)
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        let currentExercise = exercises[currentIndex]
        
        WorkoutManager.shared.SkippedToday.append(currentExercise.id)
        
        let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let restVC = storyboard.instantiateViewController(withIdentifier: "RestScreenViewController") as? RestScreenViewController {
            restVC.currentIndex = self.currentIndex
            restVC.totalExercises = self.exercises.count
            restVC.delegate = self
            self.navigationController?.pushViewController(restVC, animated: true)
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
        
        // CHECK: Is this the last possible exercise?
        let isLastNormalExercise = !isRevisitingSkipped && (currentIndex == exercises.count - 1)
        let isLastSkippedExercise = isRevisitingSkipped && WorkoutManager.shared.SkippedToday.isEmpty
        
        if isLastNormalExercise || isLastSkippedExercise {
            // Go straight to completion instead of pushing a Rest screen that will just pop back
            showCompletion()
        } else {
            goToRest()
        }
    }

    private func recordDuration() {
        if let start = exerciseStartTime {
            totalWorkoutSeconds += Date().timeIntervalSince(start)
        }
    }

    func goToRest() {
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
        
        // We iterate through all progress bars
        for (index, bar) in progressBars.enumerated() {
            
            // 1. Check if this bar corresponds to an actual exercise in our current list
            if index < exercises.count {
                let exerciseID = exercises[index].id
                
                // 2. If it's already completed, fill it 100% (Blue)
                if WorkoutManager.shared.completedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemBlue
                    bar.trackTintColor = .systemGray5
                }
                // 3. If it is the one the user is currently doing, fill it 50%
                else if index == currentIndex {
                    bar.progress = 0.5
                    bar.progressTintColor = .systemBlue
                    bar.trackTintColor = .systemGray5
                }
                // 4. If it's pending (not yet reached in this sequence)
                else {
                    bar.progress = 0.0
                    bar.trackTintColor = .systemGray5
                }
                bar.isHidden = false
            } else {
                // Hide extra bars if the current list is shorter than the number of bars
                bar.isHidden = true
            }
        }
    }
    

    @IBAction func previousButtonTapped(_ sender: UIButton) {
        if currentIndex > 0 {
            currentIndex -= 1

            let transition = CATransition()
            transition.duration = 0.4
            transition.type = .push
            transition.subtype = .fromLeft
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            view.window?.layer.add(transition, forKey: kCATransition)
            configureExercise()
            
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }

    func checkForSkippedExercises() {
        let skippedIDs = WorkoutManager.shared.SkippedToday
        if !isRevisitingSkipped && !skippedIDs.isEmpty {
            
            let alert = UIAlertController(
                title: "You skipped some exercises.",
                message: "Would you like to try them now?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Maybe later", style: .cancel) { [weak self] _ in
                self?.showCompletion()
            })
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                guard let self = self else { return }
                
                self.isRevisitingSkipped = true
                
                // FIND THE FIRST SKIPPED INDEX IN THE ORIGINAL LIST
                if let firstSkipIndex = self.exercises.firstIndex(where: { skippedIDs.contains($0.id) }) {
                    self.currentIndex = firstSkipIndex
                    
                    // Remove from global skip list as we are about to do it
                    WorkoutManager.shared.SkippedToday.removeAll { $0 == self.exercises[firstSkipIndex].id }
                    
                    self.navigationController?.popViewController(animated: true)
                    self.updateProgressBars()
                    self.configureExercise()
                }
            })
            
            present(alert, animated: true)
            
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
        if !isRevisitingSkipped {
            // ROUND 1: Linear progression
            if nextIndex < exercises.count {
                currentIndex = nextIndex
                configureExercise()
            } else {
                // End of round 1, ask to revisit
                checkForSkippedExercises()
            }
        } else {
            // ROUND 2 (Revisiting): Logic to find the NEXT skipped item
            let skippedIDs = WorkoutManager.shared.SkippedToday
            
            // Find the next exercise in the original array that is still in the skipped list
            if let nextSkipIndex = exercises.firstIndex(where: { skippedIDs.contains($0.id) }) {
                currentIndex = nextSkipIndex
                
                // OPTIONAL: If you want each skip to only be seen ONCE in the revisit round:
                // WorkoutManager.shared.SkippedToday.removeAll { $0 == exercises[currentIndex].id }
                
                configureExercise()
            } else {
                // No more skipped exercises remain in the queue
                showCompletion()
            }
        }
    }
}
