
import UIKit

class _0minworkoutCountdownViewController: UIViewController {
    @IBOutlet weak var TimerLabel: UILabel!
    var countDown = 3
    var exercises: [WorkoutExercise] = []
    var startingIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
        startCountDown()
    }

    func startCountDown() {
        if countDown == 0 {
            TimerLabel.text = "GO!"
            TimerLabel.textColor = .black
            UIView.animate(withDuration: 0.5, animations: {
                self.TimerLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { _ in
                self.navigateToWorkout()
            }
            return
        }

        TimerLabel.text = "\(countDown)"
        TimerLabel.transform = .identity
        UIView.animate(withDuration: 0.8, animations: {
            self.TimerLabel.alpha = 0
            self.TimerLabel.transform = CGAffineTransform(scaleX: 4.0, y: 4.0)
        }) { _ in
            self.countDown -= 1
            self.TimerLabel.alpha = 1
            self.startCountDown()
        }
    }

    private func navigateToWorkout() {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "10minworkoutViewController") as! _0minworkoutViewController
        vc.exercises = self.exercises
        vc.currentIndex = startingIndex
        navigationController?.pushViewController(vc, animated: true)
    }

    func setupCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeTapped))
    }

    @objc func closeTapped() { showQuitWorkoutAlert() }
}
