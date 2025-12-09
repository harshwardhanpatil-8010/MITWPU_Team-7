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
    
    var currentIndex: Int = 0
    var exercises: [Exercise] = WorkoutManager.shared.getTodayWorkout()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureExercise()
        setupUI()
     //   loadExerciseData()
    }
    func configureExercise() {
        let exercise = exercises[currentIndex]
        titleLabel.text = exercise.name
        descriptionLabel.text = exercise.description
        stepsToPerformLabel.text = exercise.stepsToPerform
        benefitsLabel.text = exercise.benefits
        
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
    }



    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
