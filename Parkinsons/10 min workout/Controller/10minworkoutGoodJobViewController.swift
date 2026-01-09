
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func easyButtonTapped(_ sender: Any) {
        saveFeedbackAndExit(feedback: "Easy")
    }
    
    @IBAction func perfectButtonTapped(_ sender: Any) {
        saveFeedbackAndExit(feedback: "Moderate")
    }
    
    @IBAction func hardButtonTapped(_ sender: Any) {
        saveFeedbackAndExit(feedback: "Hard")
    }

    
    @objc func saveFeedbackAndExit(feedback: String) {
            WorkoutManager.shared.lastFeedback = feedback

            let alert = UIAlertController(
                title: "Workout Complete!",
                message: "Great job! Your feedback has been saved.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Got it!", style: .default) { _ in
                guard let nav = self.navigationController else { return }

                for vc in nav.viewControllers {
                    if vc is _0minworkoutLandingPageViewController {
                        nav.popToViewController(vc, animated: true)
                        return
                    }
                }
            })

            present(alert, animated: true)
        }
}
