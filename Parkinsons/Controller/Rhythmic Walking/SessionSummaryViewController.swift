//
//  SessionSummaryViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class SessionSummaryViewController: UIViewController {

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
    
    private var progressView: CircularProgressView!
    
    private func setupProgressView() {
        progressView = CircularProgressView(frame: timeContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timeContainer.addSubview(progressView)
    }
    
    func loadData() {
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

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        walkingUIView.applyCardStyle()
        GaitUIView.applyCardStyle()
        loadData()
        progressView.progressColor = UIColor(hex: "90AF81")
        progressView.trackColor = .systemGray5
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
