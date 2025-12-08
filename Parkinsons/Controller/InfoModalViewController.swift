//
//  InfoModalViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class InfoModalViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stepsToPerformLabel: UILabel!
    @IBOutlet weak var benefitsLabel: UILabel!
    
  //  var exerciseDetail: ExerciseDetail?   // 👈 Passed from previous screen

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
     //   loadExerciseData()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
    }

//    private func loadExerciseData() {
//        guard let data = exerciseDetail else { return }
//        
//        titleLabel.text = "About \(data.title)"
//        descriptionLabel.text = data.description
//        
//        // Format numbered lists
//        stepsToPerformLabel.text = data.steps.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n\n")
//        benefitsLabel.text = data.benefits.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n\n")
//    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
