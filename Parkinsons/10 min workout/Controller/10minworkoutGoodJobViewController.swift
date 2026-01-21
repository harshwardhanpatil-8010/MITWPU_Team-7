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
        skippedExerciseNumber.text = "\(WorkoutManager.shared.skippedToday.count)"
        
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

    
     func saveFeedbackAndExit(feedback: String) {
        WorkoutManager.shared.lastFeedback = feedback
        
        let alert = UIAlertController(
            title: "Workout Complete!",
            message: "Great job! Your feedback has been saved. We will adjust tomorrow's exercises to better fit your needs.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Got it!", style: .default) { _ in
            if let nav = self.navigationController {
                if let landing = nav.viewControllers.first(where: { $0 is _0minworkoutLandingPageViewController }) {
                    nav.popToViewController(landing, animated: true)
                } else {
                    nav.popToRootViewController(animated: true)
                }
            }
        })
        
        present(alert, animated: true)
    }

}
