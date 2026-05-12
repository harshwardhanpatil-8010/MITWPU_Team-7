//
//  resultViewController.swift
//
//  Fixed:
//  • "Finish" button reliably pops back to LevelSelectionPuzzleViewController
//    whether presented modally or pushed onto a nav stack.
//  • Label formatting handles hours too (edge-case for very long games).
//  • Class and storyboard identifier both named "ResultViewController" — make
//    sure your storyboard's Custom Class AND Storyboard ID are set to these.
//

import UIKit

class resultViewController: UIViewController {

    @IBOutlet weak var timeTakenLabel: UILabel!

    var timeTaken: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide the back button so users must tap Finish
        navigationItem.hidesBackButton = true
        updateTimeLabel()
    }

    // MARK: - Time label

    private func updateTimeLabel() {
        guard let label = timeTakenLabel else { return }

        if timeTaken < 60 {
            label.text = "Time taken: \(timeTaken)s"
        } else if timeTaken < 3600 {
            let minutes = timeTaken / 60
            let seconds = timeTaken % 60
            label.text = String(format: "Time taken: %d:%02d", minutes, seconds)
        } else {
            let hours   = timeTaken / 3600
            let minutes = (timeTaken % 3600) / 60
            let seconds = timeTaken % 60
            label.text = String(format: "Time taken: %d:%02d:%02d", hours, minutes, seconds)
        }
    }

    // MARK: - Actions

    @IBAction func finishButtonTapped(_ sender: Any) {
        navigateBackToLevelSelection()
    }

    // MARK: - Navigation

    private func navigateBackToLevelSelection() {
        // Case 1: pushed onto a nav stack — pop back to the level selection screen
        if let nav = navigationController {
            if let target = nav.viewControllers.first(where: { $0 is LevelSelectionPuzzleViewController }) {
                nav.popToViewController(target, animated: true)
            } else {
                nav.popToRootViewController(animated: true)
            }
            return
        }

        // Case 2: presented modally
        dismiss(animated: true)
    }
}
