//
//  RestScreenViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//
//
//import UIKit
//import YouTubeiOSPlayerHelper
//
//class RestScreenViewController: UIViewController {
//    
//    @IBOutlet weak var timerLabel: UILabel!
//    @IBOutlet weak var addTimeButton: UIButton!
//    @IBOutlet weak var backgroundView: UIView!
//    @IBOutlet weak var playerView: FullScreenYTPlayerView!
//    @IBOutlet weak var exerciseLabel: UILabel!
//
//    @IBOutlet var progressBars: [UIProgressView]!
//    
//    var exerciseDurations: [TimeInterval] = []
//    weak var delegate: RestScreenDelegate?
//    var currentIndex: Int = 0
//    var totalExercises: Int = 0
//    var videoID = "jyOk-2DmVnU"
//    var timer: Timer?
//    var totalTime = 60
//    var exericses: [Exercise] = []
//    var restStartTime: Date?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        backgroundView.layer.cornerRadius = 35
//        backgroundView.clipsToBounds = true
//        updateTimerLabel()
//        startTimer()
//        setupCloseButton()
//        restStartTime = Date()
//        playerView.clipsToBounds = true
//        loadVideo()
//        playerView.isUserInteractionEnabled = false
//        updateProgressBars()
//        updateStepLabel()
//    }
//    @objc func updateStepLabel(_ sender: Any? = nil) {
//        exerciseLabel.text = "\(currentIndex + 1) of \(totalExercises)"
//    }
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
//    func loadVideo() {
//        playerView.load(
//            withVideoId: videoID,
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
//                "loop": 1,
//                "playlist": videoID
//            ]
//        )
//    }
//   
//    
//    // MARK: - Timer Setup
//    func startTimer() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(
//            timeInterval: 1.0,
//            target: self,
//            selector: #selector(updateTimer),
//            userInfo: nil,
//            repeats: true
//        )
//    }
//    
//    @objc func updateTimer() {
//        if totalTime > 0 {
//            totalTime -= 1
//            timerLabel.text = "\(totalTime)"
//        } else {
//            completeRestAndReturn()
//        }
//    }
//    
//    func completeRestAndReturn() {
//        timer?.invalidate()
//        if let start = restStartTime {
//            let restDuration = Date().timeIntervalSince(start)
//            delegate?.recordRestDuration(seconds: restDuration)
//        }
//        let next = currentIndex + 1
//        navigationController?.popViewController(animated: true)
//        delegate?.restCompleted(nextIndex: next)
//        DispatchQueue.main.async {
//            self.delegate?.restCompleted(nextIndex: next)
//        }
//    }
//    
//    func updateTimerLabel() {
//        timerLabel.text = "\(totalTime)"
//    }
//    
//    func setupCloseButton() {
//        let closeButton = UIBarButtonItem(
//            image: UIImage(systemName: "xmark"),
//            style: .plain,
//            target: self,
//            action: #selector(closeButtonTapped) 
//        )
//        
//        navigationItem.leftBarButtonItem = closeButton
//    }
//    
//    
//    // MARK: - Button Actions
//    @IBAction func addTimeButtonTapped(_ sender: UIButton) {
//        totalTime += 20
//        updateTimerLabel()
//    }
//    
//    @IBAction func skipButtonTapped(_ sender: Any) {
//        completeRestAndReturn()
//    }
//    
//    
//    // MARK: - Quit Button Alert
//    @objc func closeButtonTapped() {
//        showQuitWorkoutAlert()
//    }
//}

import UIKit
import YouTubeiOSPlayerHelper

protocol RestScreenDelegate: AnyObject {
    func recordRestDuration(seconds: TimeInterval)
    func restCompleted(nextIndex: Int)
}

class RestScreenViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var timerLabel: UILabel!

    @IBOutlet weak var breatheView: UIView!
    @IBOutlet weak var exerciseLabel: UILabel!
    
    // IMPORTANT: Adding this back fixes the crash!
    @IBOutlet var progressBars: [UIProgressView]!
    @IBOutlet weak var backgroundView: UIView!
    
    // MARK: - Properties
    weak var delegate: RestScreenDelegate?
    var currentIndex: Int = 0
    var totalExercises: Int = 0
    var totalTime = 60
    var restStartTime: Date?
    private var isCompleting = false

    

    private func setupBreathGuide() {
        // Hide the playerView if it's still there
        
        breatheView.layer.cornerRadius = 75
        breatheView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        
        // Animate the "Pulse"
        UIView.animate(withDuration: 4.0, delay: 0, options: [.repeat, .autoreverse], animations: { [self] in
            breatheView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            breatheView.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.4)
        }, completion: nil)
        
        // Add a label inside
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 35
        backgroundView.clipsToBounds = true
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 0.2
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 1)
        backgroundView.layer.shadowRadius = 3
        backgroundView.layer.masksToBounds = false

        setupUI()
        
        setupBreathGuide()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            self?.tick(t)
        }
    }

    private func setupUI() {
        // 1. Update the label to show exactly how many are DONE (excluding skips)
        let completedCount = WorkoutManager.shared.completedToday.count
        exerciseLabel.text = "\(completedCount) of \(totalExercises)"
        
        restStartTime = Date()
        updateProgressBars()
    }

    private func updateProgressBars() {
        guard progressBars != nil else { return }
        
        // Sort the progress bars by their X-coordinate to ensure they
        // update from left-to-right regardless of connection order.
        let sortedBars = progressBars.sorted { $0.frame.origin.x < $1.frame.origin.x }
        
        let allExercises = WorkoutManager.shared.exercises
        
        for (index, bar) in sortedBars.enumerated() {
            if index < allExercises.count {
                let exerciseID = allExercises[index].id
                
                // Priority 1: Was it completed?
                if WorkoutManager.shared.completedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemBlue
                }
                // Priority 2: Was it skipped?
                else if WorkoutManager.shared.SkippedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemGray4
                }
                // Priority 3: Is this the exercise we are currently resting AFTER?
                // In your flow, if you just finished exercise 0, currentIndex is 0.
                else if index == currentIndex {
                    bar.progress = 1.0
                    bar.progressTintColor = UIColor.systemBlue.withAlphaComponent(0.3)
                }
                // Priority 4: Future exercises
                else {
                    bar.progress = 0.0
                    bar.trackTintColor = .systemGray5
                }
            }
        }
    }

    private func tick(_ t: Timer) {
        if totalTime > 0 {
            totalTime -= 1
            timerLabel.text = "\(totalTime)"
        } else {
            t.invalidate()
            finishRest()
        }
    }
    

    @IBAction func skipButtonTapped(_ sender: Any) {
        finishRest()
    }

//    private func finishRest() {
//        guard !isCompleting else { return }
//        isCompleting = true
//        
//        if let start = restStartTime {
//            delegate?.recordRestDuration(seconds: Date().timeIntervalSince(start))
//        }
//        
//        navigationController?.popViewController(animated: true)
//        delegate?.restCompleted(nextIndex: currentIndex + 1)
//    }
    private func finishRest() {
        guard !isCompleting else { return }
        isCompleting = true
        
        // 1. Tell the delegate to update the index
        delegate?.restCompleted(nextIndex: currentIndex + 1)
        
        // 2. Create a custom transition
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = .push
        transition.subtype = .fromRight // This forces the right-to-left movement
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 3. Add the transition to the navigation controller's layer
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        // 4. Pop the controller - the custom transition will override the default left-to-right slide
        navigationController?.popViewController(animated: false)
    }
    @IBAction func addTimeButtonTapped(_ sender: UIButton) {
        totalTime += 20
        updateTimerLabel()
    }
    func updateTimerLabel() {
            timerLabel.text = "\(totalTime)"
       }
}
