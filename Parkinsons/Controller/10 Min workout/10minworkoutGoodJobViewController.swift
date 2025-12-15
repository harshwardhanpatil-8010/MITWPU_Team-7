//
//  10minworkoutGoodJobViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class _0minworkoutGoodJobViewController: UIViewController {

    @IBOutlet weak var easyButtonOutlet: UIButton!
    @IBOutlet weak var perfectButtonOutlet: UIButton!
    @IBOutlet weak var hardButtonOutlet: UIButton!
    @IBOutlet weak var completedExerciseNumberLabel: UILabel!
    @IBOutlet weak var skippedExerciseNumberLabel: UILabel!
    @IBOutlet weak var completionDataStackOutlet: UIView!    
    @IBOutlet weak var totalTimeLabel: UILabel!
    var completed: Int = 0
    var skipped: Int = 0
    var totalWorkoutSeconds: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        completionDataStackOutlet.applyCardStyle()
        // Do any additional setup after loading the view.
        totalTimeLabel.text = formatTime(totalWorkoutSeconds)
        
    }
    func updateUI() {
        completedExerciseNumberLabel.text = "\(completed)"
        skippedExerciseNumberLabel.text = "\(skipped)"
    }
    func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    @objc func feedbackComplete() {
        let alert = UIAlertController(
               title: "Workout Personalized",
               message: "Your feedback has been saved. Next time, your exercise will be tailored just for you. ",
               preferredStyle: .alert
           )

        alert.addAction(UIAlertAction(title: "Back to Home", style: .default) { _ in
            let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
              let homeVC = storyboard.instantiateViewController(withIdentifier: "exerciseLandingPage") as! _0minworkoutLandingPageViewController
              self.navigationController?.setViewControllers([homeVC], animated: true)
           })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

           present(alert, animated: true)
    }
    
    @IBAction func easyButtonAction(_ sender: Any) {
        feedbackComplete()
    }
    
    @IBAction func perfectButtonAction(_ sender: Any) {
        feedbackComplete()
    }
    
    @IBAction func hardButtonAction(_ sender: Any) {
        feedbackComplete()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
