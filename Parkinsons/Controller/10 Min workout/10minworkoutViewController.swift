//
//  10minworkoutViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit
import YouTubeiOSPlayerHelper

protocol RestScreenDelegate: AnyObject {
    func recordRestDuration(seconds: TimeInterval)
    func restCompleted(nextIndex: Int)
}

class _0minworkoutViewController: UIViewController {
    
    @IBOutlet weak var playerView: FullScreenYTPlayerView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var exerciseName: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var bar1: UIProgressView!
    @IBOutlet weak var bar2: UIProgressView!
    @IBOutlet weak var bar3: UIProgressView!
    @IBOutlet weak var bar4: UIProgressView!
    @IBOutlet weak var bar5: UIProgressView!
    @IBOutlet weak var bar6: UIProgressView!
    @IBOutlet weak var bar7: UIProgressView!
    @IBOutlet weak var bar8: UIProgressView!
    @IBOutlet weak var bar9: UIProgressView!
    @IBOutlet weak var bar10: UIProgressView!
    
    
    var bars: [UIProgressView] = []
    var exerciseStartTime: Date?
    var totalWorkoutSeconds: TimeInterval = 0

    var completedExerciseIDs: [UUID] = []
    var skippedExerciseIDs: [UUID] = []
    var timer: Timer?
    var totalTime = 60
    var currentIndex: Int = 0
    var exercises: [Exercise] = WorkoutManager.shared.getTodayWorkout()
    var exerciseDurations: [TimeInterval] = []

    var shouldLoadExercise = true
    var hasLoadedFirstExercise = false
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 35
        backgroundView.clipsToBounds = true
        setupCloseButton()
        playerView.layer.cornerRadius = 0
        playerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        playerView.clipsToBounds = true
        playerView.isUserInteractionEnabled = false
        bars = [bar1, bar2, bar3, bar4, bar5, bar6, bar7, bar8, bar9, bar10]
        updateProgressBars()
       

        }
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasLoadedFirstExercise {
            hasLoadedFirstExercise = true
            configureExercise()
            return
        }
        
    }

    func updateProgressBars() {
        for (index,  bar) in bars.enumerated() {
            if index < currentIndex {
                bar.progressTintColor = .systemBlue
                bar.setProgress(1.0, animated: true)
            } else if index == currentIndex {
                bar.progressTintColor = UIColor.systemBlue.withAlphaComponent(0.4)
                bar.setProgress(1.0, animated: true)
            } else {
                bar.progressTintColor = .systemGray3
                bar.setProgress(1.0, animated: false)
            }
        }
    }
   


    func configureExercise() {
        exerciseStartTime = Date()

        guard !exercises.isEmpty else {
            showCompletion()
            return }
        guard currentIndex >= 0, currentIndex < exercises.count else {
            showCompletion()
            return }

        let exercise = exercises[currentIndex]
        exerciseName.text = exercise.name
        repsLabel.text = "\(exercise.reps)"
        stepLabel.text = "\(currentIndex + 1) of \(exercises.count)"
       
        playerView.load(
            withVideoId: exercise.videoID ?? "",
            playerVars: [
                "controls": 0,
                "modestbranding": 1,
                "playsinline": 1,
                "rel": 0,
                "fs": 0,
                "iv_load_policy": 3,
                "disablekb": 1,
                "showinfo": 0,
                "autoplay": 1,
              
            ]
        )

        starttimer()
        updateProgressBars()
        previousButton.isEnabled = currentIndex > 0
        previousButton.alpha = currentIndex > 0 ? 1.0 : 0.4
    }
    func starttimer() {
        timer?.invalidate()
        totalTime = 60
        timerLabel.text = "\(totalTime)"
           
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
    }
    @objc func updateTimer() {
        if totalTime > 0 {
            totalTime -= 1
            timerLabel.text = "\(totalTime)"
        } else {
            timer?.invalidate()
            timer = nil
          
        }
    }

    func goToRestScreen() {
        if currentIndex < exercises.count - 1 {  // Not last exercise
            let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "RestScreenViewController") as! RestScreenViewController
            
            vc.currentIndex = currentIndex
            vc.totalExercises = exercises.count
            vc.delegate = self

            navigationController?.pushViewController(vc, animated: true)
        } else {
            showCompletion()
        }
    }
    
    func showCompletion() {
        let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GoodJobViewController") as! _0minworkoutGoodJobViewController
        
        vc.completed = WorkoutManager.shared.completedToday.count
        vc.skipped = WorkoutManager.shared.SkippedToday.count
        vc.totalWorkoutSeconds = totalWorkoutSeconds
        navigationController?.pushViewController(vc, animated: true)
    }
 

    func createDashedLayer(color: CGColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.strokeColor = color
        layer.lineWidth = 6
        layer.lineDashPattern = [10, 6] // dash width, gap width
        layer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 40, height: 1)).cgPath
        return layer
    }
    @objc func closeButtonTapped() {
        showQuitWorkoutAlert()
    }
    
    func setupCloseButton() {
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        navigationItem.leftBarButtonItem = closeButton
    }
    
    func  recordExerciseDuration() {
        if let start = exerciseStartTime {
            let duration = Date().timeIntervalSince(start)
            totalWorkoutSeconds += duration
        }
    }
    
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "InfoModalViewController") as! InfoModalViewController
        vc.exercises = exercises
        vc.currentIndex = currentIndex
       let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    @IBAction func previousButtontapped(_ sender: UIButton) {
        goToPreviousExercise()
    }
    
    func goToPreviousExercise() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        updateProgressBars()
        configureExercise()
    }
    
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        recordExerciseDuration()
        guard !exercises.isEmpty else {return}
        let exercise = exercises[currentIndex]
        if !WorkoutManager.shared.completedToday.contains(exercise.id) {
            WorkoutManager.shared.completedToday.append(exercise.id)
        }
       
        
        goToRestScreen()
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        recordExerciseDuration()
        guard !exercises.isEmpty else { return }
        let exercise = exercises[currentIndex]
        if !WorkoutManager.shared.SkippedToday.contains(exercise.id) {
            WorkoutManager.shared.SkippedToday.append(exercise.id)
        }
        goToRestScreen()
    }
}

extension _0minworkoutViewController: RestScreenDelegate {
    func recordRestDuration(seconds: TimeInterval) {
            totalWorkoutSeconds += seconds
        }

    func restCompleted(nextIndex: Int) {
        if nextIndex < exercises.count {
            currentIndex = nextIndex
            configureExercise()
        } else {
            showCompletion()
        }
    }
}
