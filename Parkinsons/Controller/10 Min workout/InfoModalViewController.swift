//
//  InfoModalViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class InfoModalViewController: UIViewController {
    
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
        title = exercise.name
        descriptionLabel.text = exercise.description
        benefitsLabel.attributedText = makeNumberedList(exercise.benefits ?? "")
       stepsToPerformLabel.attributedText = makeNumberedList(exercise.stepsToPerform ?? "")
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
    func makeNumberedList(_ text: String) -> NSAttributedString {
        let separators = CharacterSet(charactersIn: ".;\n,")
        
        let parts = text
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let final  = NSMutableAttributedString()
        for (index, part) in parts.enumerated() {
            let numberString = "\(index + 1). "
            let fullString = numberString + part + "\n"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = 0
            paragraphStyle.headIndent = 20
            
            let attributed = NSAttributedString(
                string: fullString,
                attributes: [
                    .paragraphStyle: paragraphStyle
                ]
            )
            final.append(attributed)
        }
        return final
    }


    
    
}
