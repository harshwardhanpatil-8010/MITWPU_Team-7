
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
