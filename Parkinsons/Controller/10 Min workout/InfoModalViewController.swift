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
    var exercises: [Exercise] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureExercise()
        setupCloseButton()
    }
    func configureExercise() {
        let exercise = exercises[currentIndex]
        titleLabel.text = exercise.name
        descriptionLabel.text = exercise.description
        benefitsLabel.text = makeNumberedList(exercise.benefits ?? "")
       stepsToPerformLabel.text = makeNumberedList(exercise.stepsToPerform ?? "")
    }
    
    func setupCloseButton() {
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        navigationItem.rightBarButtonItem = closeButton
    }
    @objc func closeButtonTapped() {
        dismiss(animated: true)
    }
    func makeNumberedList(_ text: String) -> String {
        let separators = CharacterSet(charactersIn: ".;\n,")
        
        let parts = text
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        return parts.enumerated()
            .map { "\($0 + 1). \($1)" }
            .joined(separator: "\n")
    }


    
    
}
