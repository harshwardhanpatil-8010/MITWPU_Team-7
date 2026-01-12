//
//  SessionSummaryViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class SessionSummaryViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var walkingUIView: UIView!
    @IBOutlet weak var GaitUIView: UIView!
    
    @IBOutlet weak var timeContainer: UIView!
    
    @IBOutlet weak var stepsTaken: UILabel!
    @IBOutlet weak var distanceCovered: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var stepsLength: UILabel!
    @IBOutlet weak var walkingAsymmetry: UILabel!
    @IBOutlet weak var walkingSteadiness: UILabel!
    
    @IBOutlet weak var stepLengthPercent: UILabel!
    @IBOutlet weak var walkingAsymmetryPercent: UILabel!
    @IBOutlet weak var walkingSteadinessPercent: UILabel!
    
    
    var sessionData: RhythmicSession?
    private var progressView: CircularProgressView!
    
    private func setupProgressView() {
        progressView = CircularProgressView(frame: timeContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timeContainer.addSubview(progressView)
    }


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        walkingUIView.applyCardStyle()
        GaitUIView.applyCardStyle()
        loadData()
        progressView.progressColor = UIColor(hex: "90AF81")
        progressView.lineWidth = 15
        progressView.trackColor = UIColor(hex: "90AF81", alpha: 0.3)
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // Do any additional setup after loading the view.
    }
    
    
    
    
    func loadData() {
        if let session = sessionData {
            let elapsedSeconds = session.elapsedSeconds
            let requestedSeconds = session.requestedDurationSeconds
                    
            let hours = elapsedSeconds / 3600
            let minutes = (elapsedSeconds % 3600) / 60
            let seconds = elapsedSeconds % 60
                    
            timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                    
            var progress: Float = 0.0
            if requestedSeconds > 0 {
                progress = Float(elapsedSeconds) / Float(requestedSeconds)
            }
            else if elapsedSeconds > 0 {
                progress = 1.0
            }
            progressView.setProgress(CGFloat(progress))
        }
        else {
            timeLabel.text = "00:00:00"
            progressView.setProgress(0.0)
        }
        
        stepsTaken.text = WalkingSessionDemo.steps.description
        distanceCovered.text = WalkingSessionDemo.distanceKMeters.description
        speed.text = "3 Km/h"
        stepsLength.text = gaitDemoInfo.stepLengthMeters.description
        walkingAsymmetry.text = gaitDemoInfo.walkingAsymmetryPercent.description
        walkingSteadiness.text = gaitDemoInfo.walkingSteadiness.description
        stepLengthPercent.text = "12 %"
        walkingAsymmetryPercent.text = "0.5 %"
        walkingSteadinessPercent.text = "5 %"
    }
    
//    @IBAction func doneButtonTapped(_ sender: Any) {
//        dismiss(animated: true)
//    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        // 1. Ensure the session is saved to the DataStore
        if let session = sessionData {
            DataStore.shared.add(session)
        }

        // 2. Return to Home
        // If it's a modal (presented), use dismiss. If it's in a navigation stack, use pop.
//        if let nav = self.navigationController {
//            nav.popToRootViewController(animated: true)
//        } else {
//            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//        }
        dismiss(animated: true)
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
