
import UIKit
import AudioToolbox

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
    
    private func playBeat(isGo: Bool) {
        if isGo {
            AudioServicesPlaySystemSound(1057)
        } else {
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    func startCountDown() {
        guard !hasNavigated, !isCountdownCancelled else { return }

        if countDown < 0 {
            hasNavigated = true
            navigateToWorkout()
            return
        }

        TimerLabel.alpha = 1
        TimerLabel.transform = .identity
        TimerLabel.text = countDown == 0 ? "GO!" : "\(countDown)"
        playBeat(isGo: countDown == 0)

        UIView.animate(withDuration: 0.85, animations: {
            self.TimerLabel.alpha = 0
            self.TimerLabel.transform = CGAffineTransform(scaleX: 4, y: 4)
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
