//
//  InfoModalViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class InfoModalViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stepsToPerformLabel: UILabel!
    @IBOutlet weak var benefitsLabel: UILabel!
    
    // MARK: - Properties
    var currentIndex: Int = 0
    // Changed to use the new naming convention WorkoutExercise
    var exercises: [WorkoutExercise] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureExercise()
        setupCloseButton()
    }
    
    func configureExercise() {
        // Fix 1: Corrected array access syntax and variable naming
        guard currentIndex < exercises.count else { return }
        let exercise = exercises[currentIndex]
        
        title = exercise.name
        
        // Fix 2: Updated model access.
        // Ensure your WorkoutExercise struct has these properties.
        descriptionLabel.text = exercise.description
        
        // Fix 3: Handling the conversion of Arrays or Strings to Numbered Lists
        benefitsLabel.attributedText = formatAsNumberedList(exercise.benefits)
        stepsToPerformLabel.attributedText = formatAsNumberedList(exercise.stepsToPerform)
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
    
    // MARK: - UI Formatting Logic
    /// This handles both a single long string or an array of instructions
    func formatAsNumberedList(_ input: Any?) -> NSAttributedString {
        var items: [String] = []
        
        if let stringArray = input as? [String] {
            items = stringArray
        } else if let singleString = input as? String {
            let separators = CharacterSet(charactersIn: ".;\n")
            items = singleString
                .components(separatedBy: separators)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        
        let final = NSMutableAttributedString()
        
        // UI Optimization for Parkinson's: Increased line spacing and clear indentation
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.paragraphSpacing = 12
        paragraphStyle.headIndent = 28 // Indent text so numbers stand out
        
        for (index, item) in items.enumerated() {
            let line = "\(index + 1).  \(item)\n"
            let attributedLine = NSAttributedString(
                string: line,
                attributes: [
                    .paragraphStyle: paragraphStyle,
                    .font: UIFont.systemFont(ofSize: 17, weight: .regular)
                ]
            )
            final.append(attributedLine)
        }
        return final
    }
}
