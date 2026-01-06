//
//  workoutAlerts.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

extension UIViewController {
    
    // MARK: - Safety Exit Alert
    func showQuitWorkoutAlert() {
        let alert = UIAlertController(title: "Are you sure you want to quit?", message: "Your progress will be saved.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Resume", style: .cancel))
        alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { _ in
            self.showWhyStoppedAlert()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Clinical Feedback
    func showWhyStoppedAlert() {
        let alert = UIAlertController(title: "What made you stop?", message: "Your feedback will help us curate the next set of exercises for you.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Physical Pain/Fatigue", style: .default) { _ in
            // Logic: Mark this exercise as 'hard' in ExerciseStore
            self.navigateToWorkoutLanding()
        })
        
        alert.addAction(UIAlertAction(title: "Resume Later", style: .default) { _ in
            self.navigateToWorkoutLanding()
        })
        
        present(alert, animated: true)
    }
    
    func showFeedbackAlert() {
        let alert = UIAlertController(title: "How has your workout been so far?", message: "Personalizing your next set...", preferredStyle: .alert)
        
        let levels = ["Easy", "Just Right", "Difficult"]
        for level in levels {
            alert.addAction(UIAlertAction(title: level, style: .default) { _ in
                self.navigateToWorkoutLanding()
            })
        }
        present(alert, animated: true)
    }
    
    func navigateToWorkoutLanding() {
        if let landingVC = self.navigationController?.viewControllers.first(where: { $0 is _0minworkoutLandingPageViewController }) {
            self.navigationController?.popToViewController(landingVC, animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}
