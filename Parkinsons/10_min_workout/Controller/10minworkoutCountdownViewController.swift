import UIKit

class _0minworkoutCountdownViewController: UIViewController {

    @IBOutlet weak var TimerLabel: UILabel!

    var countDown = 3
    var exercises: [WorkoutExercise] = []
    var startingIndex: Int = 0
    private var hasNavigated = false
    private var isCountdownCancelled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        startCountDown()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        isCountdownCancelled = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isCountdownCancelled = true
        TimerLabel.layer.removeAllAnimations()
    }
    
    func startCountDown() {
        guard !hasNavigated, !isCountdownCancelled else { return }

        if countDown == 0 {
            hasNavigated = true
            TimerLabel.text = "GO!"
            UIView.animate(withDuration: 0.4) {
                self.TimerLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            } completion: { _ in
                guard !self.isCountdownCancelled else { return }
                self.navigateToWorkout()
            }
            return
        }

        TimerLabel.text = "\(countDown)"
        TimerLabel.alpha = 1
        TimerLabel.transform = .identity

        UIView.animate(withDuration: 0.7, animations: {
            self.TimerLabel.alpha = 0
            self.TimerLabel.transform = CGAffineTransform(scaleX: 4, y: 4)
        }) { _ in
            guard !self.isCountdownCancelled else { return }
            self.countDown -= 1
            self.startCountDown()
        }
    }

    private func navigateToWorkout() {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "10minworkoutViewController") as! _0minworkoutViewController
        vc.exercises = exercises
        vc.currentIndex = startingIndex
        navigationController?.pushViewController(vc, animated: true)
    }
}
