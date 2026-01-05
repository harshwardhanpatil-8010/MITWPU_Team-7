//
//  10minworkoutGoodJobViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//
//
//import UIKit
//
//class _0minworkoutGoodJobViewController: UIViewController {
//
//    @IBOutlet weak var easyButtonOutlet: UIButton!
//    @IBOutlet weak var perfectButtonOutlet: UIButton!
//    @IBOutlet weak var hardButtonOutlet: UIButton!
//    @IBOutlet weak var completedExerciseNumberLabel: UILabel!
//    @IBOutlet weak var skippedExerciseNumberLabel: UILabel!
//    @IBOutlet weak var completionDataStackOutlet: UIView!    
//    @IBOutlet weak var totalTimeLabel: UILabel!
//    var completed: Int = 0
//    var skipped: Int = 0
//    var totalWorkoutSeconds: TimeInterval = 0
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        updateUI()
//        completionDataStackOutlet.applyCardStyle()
//        // Do any additional setup after loading the view.
//        totalTimeLabel.text = formatTime(totalWorkoutSeconds)
//        
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationItem.hidesBackButton = true
//        navigationItem.rightBarButtonItem = nil
//    }
//    func updateUI() {
//        completedExerciseNumberLabel.text = "\(completed)"
//        skippedExerciseNumberLabel.text = "\(skipped)"
//    }
//    func formatTime(_ seconds: TimeInterval) -> String {
//        let mins = Int(seconds) / 60
//        let secs = Int(seconds) % 60
//        return String(format: "%02d:%02d", mins, secs)
//    }
//
//    @objc func feedbackComplete() {
//        let alert = UIAlertController(
//               title: "Workout Personalized",
//               message: "Your feedback has been saved. Next time, your exercise will be tailored just for you. ",
//               preferredStyle: .alert
//           )
//
//        alert.addAction(UIAlertAction(title: "Back to Home", style: .default) { _ in
//            let storyboard = UIStoryboard(name: "Home", bundle: nil)
//              let homeVC = storyboard.instantiateViewController(withIdentifier: "HomePage") as! HomeViewController
//              self.navigationController?.setViewControllers([homeVC], animated: true)
//           })
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//           present(alert, animated: true)
//    }
//    
//    @IBAction func easyButtonAction(_ sender: Any) {
//        feedbackComplete()
//    }
//    
//    @IBAction func perfectButtonAction(_ sender: Any) {
//        feedbackComplete()
//    }
//    
//    @IBAction func hardButtonAction(_ sender: Any) {
//        feedbackComplete()
//    }
//    
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}


//import UIKit
//
//class _0minworkoutGoodJobViewController: UIViewController {
//    @IBOutlet weak var completedExerciseNumberLabel: UILabel!
//    @IBOutlet weak var totalTimeLabel: UILabel!
//    @IBOutlet weak var summaryUIView: UIView!
//    
//    @IBOutlet weak var skippedExerciseNumber: UILabel!
//    
//    var completed: Int = 0
//    var totalWorkoutSeconds: TimeInterval = 0
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationItem.hidesBackButton = true
//        completedExerciseNumberLabel.text = "\(completed)"
//        totalTimeLabel.text = String(format: "%02d:%02d", Int(totalWorkoutSeconds)/60, Int(totalWorkoutSeconds)%60)
//        summaryUIView.applyCardStyle()
//    }
//
//    
//    @IBAction func easyButtonTapped(_ sender: Any) {
//    }
//    
//    @IBAction func perfectButtonTapped(_ sender: Any) {
//    }
//    
//    
//    @IBAction func hardButtonTapped(_ sender: Any) {
//    }
//    
//}
import UIKit

class _0minworkoutGoodJobViewController: UIViewController {
    @IBOutlet weak var completedExerciseNumberLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var summaryUIView: UIView!
    @IBOutlet weak var skippedExerciseNumber: UILabel!
    
    var completed: Int = 0
    var totalWorkoutSeconds: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        completedExerciseNumberLabel.text = "\(completed)"
        skippedExerciseNumber.text = "\(WorkoutManager.shared.SkippedToday.count)"

        let minutes = Int(totalWorkoutSeconds) / 60
        let seconds = Int(totalWorkoutSeconds) % 60
        totalTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        summaryUIView.applyCardStyle()
    }

    // MARK: - Feedback Actions
    
    @IBAction func easyButtonTapped(_ sender: Any) {
        saveFeedbackAndExit(feedback: "Easy")
    }
    
    @IBAction func perfectButtonTapped(_ sender: Any) {
        saveFeedbackAndExit(feedback: "Moderate")
    }
    
    @IBAction func hardButtonTapped(_ sender: Any) {
        saveFeedbackAndExit(feedback: "Hard")
    }
    
    // MARK: - Helper Methods
    
    private func saveFeedbackAndExit(feedback: String) {
        WorkoutManager.shared.lastFeedback = feedback
        
        WorkoutManager.shared.completedToday.removeAll()
        WorkoutManager.shared.SkippedToday.removeAll()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        if let nav = self.navigationController {
            nav.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
