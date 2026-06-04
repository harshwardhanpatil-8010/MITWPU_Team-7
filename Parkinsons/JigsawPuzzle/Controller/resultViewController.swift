
import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var FinishButton: UIButton!

    var timeTaken: Int = 0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        updateTimeLabel()
        saveCompletion()
        showConfetti()
    }

    private func updateTimeLabel() {
        guard let label = timeTakenLabel else { return }

        if timeTaken < 60 {
            label.text = "Time taken: \(timeTaken)s"
        } else if timeTaken < 3600 {
            let minutes = timeTaken / 60
            let seconds = timeTaken % 60
            label.text = String(format: "Time taken: %d:%02d", minutes, seconds)
        } else {
            let hours   = timeTaken / 3600
            let minutes = (timeTaken % 3600) / 60
            let seconds = timeTaken % 60
            label.text = String(format: "Time taken: %d:%02d:%02d", hours, minutes, seconds)
        }
    }

    private func saveCompletion() {
        let today = Calendar.current.startOfDay(for: Date())
        PuzzleGameManager.shared.markCompleted(date: today)
        PuzzleGameManager.shared.saveCompletion(date: today, time: timeTaken)
    }


    @IBAction func finishButtonTapped(_ sender: Any) {
        navigateBackToLevelSelection()
    }

    @IBAction func FinishButtonAction(_ sender: UIButton) {
        navigateBackToLevelSelection()
    }


    private func navigateBackToLevelSelection() {
        if let nav = navigationController {
            if let target = nav.viewControllers.first(where: { $0 is LevelSelectionPuzzleViewController }) {
                nav.popToViewController(target, animated: true)
            } else {
                nav.popToRootViewController(animated: true)
            }
            return
        }

        dismiss(animated: true)
    }


    private func showConfetti() {
        let confettiLayer = CAEmitterLayer()
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 2)

        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen,
            .systemOrange, .systemBrown, .systemYellow, .systemPink
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
}
