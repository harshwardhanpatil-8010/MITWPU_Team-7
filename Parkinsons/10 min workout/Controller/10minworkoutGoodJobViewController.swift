import UIKit

class _0minworkoutGoodJobViewController: UIViewController {
    @IBOutlet weak var completedExerciseNumberLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var summaryUIView: UIView!
    @IBOutlet weak var skippedExerciseNumber: UILabel!

    var completed = 0
    var totalWorkoutSeconds: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true

        completedExerciseNumberLabel.text = "\(completed)"
        skippedExerciseNumber.text = "\(WorkoutManager.shared.skippedToday.count)"

        let m = Int(totalWorkoutSeconds) / 60
        let s = Int(totalWorkoutSeconds) % 60
        totalTimeLabel.text = String(format: "%02d:%02d", m, s)

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

    @IBAction func easyButtonTapped(_ sender: Any) { finish("Easy") }
    @IBAction func perfectButtonTapped(_ sender: Any) { finish("Moderate") }
    @IBAction func hardButtonTapped(_ sender: Any) { finish("Hard") }

    private func finish(_ feedback: String) {
        WorkoutManager.shared.lastFeedback = feedback

        let alert = UIAlertController(title: "Workout Complete!", message: "Feedback saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default){ _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
