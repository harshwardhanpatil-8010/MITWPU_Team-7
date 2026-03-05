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
        showConfetti()
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

   
    private func showConfetti() {
        let confettiLayer = CAEmitterLayer()
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 2)

        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen,
            .systemOrange, .systemPurple, .systemYellow, .systemPink
        ]

        confettiLayer.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime = 6
            cell.velocity = 180
            cell.velocityRange = 60
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3
            cell.spinRange = 4
            cell.scale = 0.05
            cell.scaleRange = 0.03
            cell.color = color.cgColor
            cell.contents = defaultConfettiImage().cgImage
            return cell
        }

        view.layer.addSublayer(confettiLayer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confettiLayer.birthRate = 0
        }
    }

    private func defaultConfettiImage() -> UIImage {
        let size = CGSize(width: 32, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let ctx = context.cgContext
            ctx.setFillColor(UIColor.white.cgColor)

            if Bool.random() {
                ctx.fill(CGRect(origin: .zero, size: size))
            } else {
                let radius = min(size.width, size.height) / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                ctx.addArc(
                    center: center,
                    radius: radius,
                    startAngle: 0,
                    endAngle: .pi * 2,
                    clockwise: false
                )
                ctx.fillPath()
            }
        }
    }
    func saveFeedbackAndExit(value: Int) {
        WorkoutManager.shared.saveFeedback(value)
        DailyWorkoutSummaryStore.shared.saveWorkoutSummary()
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
