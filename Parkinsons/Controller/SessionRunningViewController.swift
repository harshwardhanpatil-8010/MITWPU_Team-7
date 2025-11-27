//
//  SessionRunningViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class SessionRunningViewController: UIViewController {

    
    @IBOutlet weak var circularContainer: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    private var progressView: CircularProgressView!
    private let timerModel = TimerModel(totalSeconds: 40 * 60) // STATIC RN, HAVE TO USE PREPARE FUNC TO GET SET TIME DATA FROM SETGOALVC
    
    
    private func setupProgressView() {
        progressView = CircularProgressView(frame: circularContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        circularContainer.addSubview(progressView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        timerModel.delegate = self
        timerModel.start()
        
        updatePauseButtonUI()
        // Do any additional setup after loading the view.
    }
    

        @IBAction func pauseTapped(_ sender: Any) {
            if timerModel.isPaused {
                timerModel.resume()
            } else {
                timerModel.pause()
            }
            updatePauseButtonUI()
        }
        
        private func updatePauseButtonUI() {
            pauseButton.setTitle(timerModel.isPaused ? "Resume" : "Pause", for: .normal)
        }
    }

    extension SessionRunningViewController: TimerModelDelegate {
        
        func timerDidUpdate(timeLeft: Int, progress: CGFloat) {
            let minutes = timeLeft / 60
            let seconds = timeLeft % 60
            timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
            
            progressView.setProgress(progress)
        }
        
        func timerDidFinish() {
            timeLabel.text = "00:00"
            progressView.setProgress(0)
            pauseButton.isEnabled = false
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
