//
//  workoutAlerts.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

extension UIViewController {
    
    // MARK: - Quit Workout Alert
    func showQuitWorkoutAlert() {
        let alert = UIAlertController(
            title: "Quit Workout?",
            message: "Are you sure you want to quit the workout?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            alert.dismiss(animated: true) {
                        self.showWhyStoppedAlert()
                    }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
    
    // MARK: - Why Stopped Alert
    func showWhyStoppedAlert() {
        let alert = UIAlertController(
            title: "That's okay - What made you stop?",
            message: "",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Resume Later", style: .default) { _ in
            alert.dismiss(animated: true) {
                self.navigateToWorkoutLanding()
            }
        })

        alert.addAction(UIAlertAction(title: "Too tired", style: .default) { _ in
            alert.dismiss(animated: true) {
                self.navigateToWorkoutLanding()
            }
        })

        alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { _ in
            alert.dismiss(animated: true) {
                self.showFeedbackAlert()
            }
        })

        present(alert, animated: true)
    }
    
    
    // MARK: - Feedback Alert
    func showFeedbackAlert() {
        let alert = UIAlertController(
            title: "How has your workout been so far?",
            message: "Next time, your workout will be personalized based on your feedback.",
            preferredStyle: .alert
        )

        let options = ["Easy", "Perfect", "Hard"]
        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default) { _ in
                alert.dismiss(animated: true) {
                    self.navigateToWorkoutLanding()
                }
            })
        }

        present(alert, animated: true)
    }
    
    
    // MARK: - Navigation Helper
   
    private func navigateToWorkoutLanding() {
       
        if let existingLandingVC = self.navigationController?.viewControllers.first(where: { vc in
            return vc is _0minworkoutLandingPageViewController
        }) {
            self.navigationController?.popToViewController(existingLandingVC, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
            let homeVC = storyboard.instantiateViewController(withIdentifier: "exerciseLandingPage") as! _0minworkoutLandingPageViewController
            self.navigationController?.setViewControllers([homeVC], animated: true)
        }
    }
}
