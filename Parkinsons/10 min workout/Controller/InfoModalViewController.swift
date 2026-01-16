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
    
    var currentIndex: Int = 0
     var exercises: [WorkoutExercise] = []
     
     override func viewDidLoad() {
         super.viewDidLoad()
         configureExercise()
         setupCloseButton()
        
     }
     
     func configureExercise() {
         guard currentIndex < exercises.count else { return }
         let exercise = exercises[currentIndex]
         
         title = exercise.name
         descriptionLabel.text = exercise.description
         benefitsLabel.attributedText = formatAsNumberedList(exercise.benefits)
         stepsToPerformLabel.attributedText = formatAsNumberedList(exercise.stepsToPerform)
     }
     
    func setupCloseButton() {
        let action = UIAction { [weak self] _ in
            self?.navigationController?.dismiss(animated: true)
        }
        let closeButton = UIBarButtonItem(systemItem: .close, primaryAction: action)
        navigationItem.leftBarButtonItem = closeButton
    }
    
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
         let paragraphStyle = NSMutableParagraphStyle()
         paragraphStyle.lineSpacing = 8
         paragraphStyle.paragraphSpacing = 12
         paragraphStyle.headIndent = 28
         
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
