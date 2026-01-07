
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
    
    private func saveFeedbackAndExit(feedback: String) {
        WorkoutManager.shared.lastFeedback = feedback
        WorkoutManager.shared.completedToday.removeAll()
        WorkoutManager.shared.SkippedToday.removeAll()

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        let alert = UIAlertController(
            title: "Workout Complete!",
            message: "Great job! Your feedback has been saved. We will adjust tomorrow's exercises to better fit your needs.",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "Got it!", style: .default) { [weak self] _ in
            guard let self = self else { return }

            let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
            guard let finishVC = storyboard.instantiateViewController(
                withIdentifier: "exerciseLandingPage") as? _0minworkoutLandingPageViewController else {
                return
            }

            // CASE 1: Inside Navigation Stack
            if let nav = self.navigationController {
                nav.setViewControllers([finishVC], animated: true)
            }
            // CASE 2: Presented Modally
            else if let window = self.view.window {
                let nav = UINavigationController(rootViewController: finishVC)
                window.rootViewController = nav
                UIView.transition(
                    with: window,
                    duration: 0.3,
                    options: .transitionCrossDissolve,
                    animations: nil
                )
            }
        }

        alert.addAction(okAction)
        present(alert, animated: true)
    }

}
