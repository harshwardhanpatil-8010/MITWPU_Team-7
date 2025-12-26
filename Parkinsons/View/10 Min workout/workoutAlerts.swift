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
        let alert = UIAlertController(title: "Stop Exercise?", message: "Your progress is saved.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Resume", style: .cancel))
        alert.addAction(UIAlertAction(title: "Stop", style: .destructive) { _ in
            self.showWhyStoppedAlert()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Clinical Feedback
    func showWhyStoppedAlert() {
        let alert = UIAlertController(title: "What happened?", message: "We'll adjust your next workout.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Physical Pain/Fatigue", style: .default) { _ in
            // Logic: Mark this exercise as 'hard' in ExerciseStore
            self.navigateToWorkoutLanding()
        })
        
        alert.addAction(UIAlertAction(title: "Ran out of time", style: .default) { _ in
            self.navigateToWorkoutLanding()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Intensity Calibration
    func showFeedbackAlert() {
        let alert = UIAlertController(title: "How was it?", message: "Personalizing your next set...", preferredStyle: .alert)
        
        let levels = ["Too Easy", "Perfect", "Too Hard"]
        for level in levels {
            alert.addAction(UIAlertAction(title: level, style: .default) { _ in
                // Logic: Trigger Algorithm Update here
                self.navigateToWorkoutLanding()
            })
        }
        present(alert, animated: true)
    }
    
    // MARK: - Navigation Logic
    func navigateToWorkoutLanding() {
        if let landingVC = self.navigationController?.viewControllers.first(where: { $0 is _0minworkoutLandingPageViewController }) {
            self.navigationController?.popToViewController(landingVC, animated: true)
        } else {
            // Fallback to home
            self.dismiss(animated: true)
        }
    }
}
