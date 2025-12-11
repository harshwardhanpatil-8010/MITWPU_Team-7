//
//  RestScreenViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit
import YouTubeiOSPlayerHelper

class RestScreenViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var addTimeButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var playerView: FullScreenYTPlayerView!
    @IBOutlet weak var exerciseLabel: UILabel!
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
    var exerciseDurations: [TimeInterval] = []
    weak var delegate: RestScreenDelegate?
    var currentIndex: Int = 0
    var totalExercises: Int = 0
    var videoID = "jyOk-2DmVnU"
    var timer: Timer?
    var totalTime = 60
    var exericses: [Exercise] = []
    var restStartTime: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 35
        backgroundView.clipsToBounds = true
        updateTimerLabel()
        startTimer()
        setupCloseButton()
        restStartTime = Date()
        playerView.layer.cornerRadius = 45
        playerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        playerView.clipsToBounds = true
        loadVideo()
        playerView.isUserInteractionEnabled = false
        bars = [bar1, bar2, bar3, bar4, bar5, bar6, bar7, bar8, bar9, bar10]
        updateProgressBars()
        updateStepLabel()
    }
    @objc func updateStepLabel(_ sender: Any? = nil) {
        exerciseLabel.text = "\(currentIndex + 1) of \(totalExercises)"
    }
    func updateProgressBars() {
        for (index,  bar) in bars.enumerated() {
            if index < currentIndex {
                bar.progressTintColor = .systemBlue
                
            } else if index == currentIndex {
                bar.progressTintColor = UIColor.systemBlue.withAlphaComponent(0.4)
              
            } else {
                bar.progressTintColor = .systemGray3
               
            }
            bar.setProgress(1.0, animated: false)
        }
    }
   
    
    func loadVideo() {
        playerView.load(
            withVideoId: videoID,
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
                "loop": 1,
                "playlist": videoID
            ]
        )
    }
   
    
    // MARK: - Timer Setup
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func updateTimer() {
        if totalTime > 0 {
            totalTime -= 1
            timerLabel.text = "\(totalTime)"
        } else {
            completeRestAndReturn()
        }
    }
    
    func completeRestAndReturn() {
        timer?.invalidate()
        if let start = restStartTime {
            let restDuration = Date().timeIntervalSince(start)
            delegate?.recordRestDuration(seconds: restDuration)
        }
        let next = currentIndex + 1
        navigationController?.popViewController(animated: true)
        delegate?.restCompleted(nextIndex: next)
        DispatchQueue.main.async {
            self.delegate?.restCompleted(nextIndex: next)
        }
    }
    
    func updateTimerLabel() {
        timerLabel.text = "\(totalTime)"
    }
    
    func setupCloseButton() {
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped) // This calls the function below when tapped
        )
        
        navigationItem.leftBarButtonItem = closeButton
    }
    
    
    // MARK: - Button Actions
    @IBAction func addTimeButtonTapped(_ sender: UIButton) {
        totalTime += 20
        updateTimerLabel()
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        completeRestAndReturn()
    }
    
    
    // MARK: - Quit Button Alert
    @objc func closeButtonTapped() {
        showQuitWorkoutAlert()
    }
}
