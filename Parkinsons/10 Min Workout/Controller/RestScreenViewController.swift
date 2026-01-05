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

    @IBOutlet var progressBars: [UIProgressView]!
    
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
        playerView.clipsToBounds = true
        loadVideo()
        playerView.isUserInteractionEnabled = false
        updateProgressBars()
        updateStepLabel()
    }
    @objc func updateStepLabel(_ sender: Any? = nil) {
        exerciseLabel.text = "\(currentIndex + 1) of \(totalExercises)"
    }
    func updateProgressBars() {
        for (index, bar) in progressBars.enumerated() {
            bar.progress = 1.0
            bar.progressTintColor =
                index < currentIndex ? .systemBlue :
                index == currentIndex ? UIColor.systemBlue.withAlphaComponent(0.4) :
                .systemGray3
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
            action: #selector(closeButtonTapped) 
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
