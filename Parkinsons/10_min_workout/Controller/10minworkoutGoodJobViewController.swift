import UIKit
import CoreData

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
        saveFeedbackAndExit(value: 1)
    }
    
    @IBAction func perfectButtonTapped(_ sender: Any) {
        saveFeedbackAndExit(value: 2)
    }
    
    @IBAction func hardButtonTapped(_ sender: Any) {
        saveFeedbackAndExit(value: 3)
    }

    func saveDailyWorkoutSummary() {
        let context = PersistenceController.shared.viewContext
        let summary = DailyWorkoutSummary(context: context)
        
        summary.date = Date()
        summary.completedCount = Int16(WorkoutManager.shared.completedToday.count)
        summary.skippedCount = Int16(WorkoutManager.shared.skippedToday.count)
        PersistenceController.shared.save()
    }
    
    func saveFeedbackAndExit(value: Int) {
        WorkoutManager.shared.saveFeedback(value)

                let alert = UIAlertController(
                    title: "Workout Complete!",
                    message: "Great job! Your feedback has been saved. Tomorrow’s workout will be adjusted to match how you felt today.",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "Got it!", style: .default) { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                })

                present(alert, animated: true)
    }
}
