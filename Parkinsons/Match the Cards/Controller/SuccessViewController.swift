
import UIKit

class SuccessViewController: UIViewController {

    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!

    var timeTaken: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTimeLabel()
        saveCompletion()
        showConfetti()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = nil
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func updateTimeLabel() {
        guard let timeTaken else { return }

        if timeTaken < 60 {
            timeTakenLabel.text = "Time taken: \(timeTaken)s"
        } else {
            let minutes = timeTaken / 60
            let seconds = timeTaken % 60
            timeTakenLabel.text = "Time taken: \(minutes)min \(seconds)s"
        }
    }

    private func saveCompletion() {
        let today = Calendar.current.startOfDay(for: Date())
        DailyGameManager.shared.saveCompletion(date: today, time: timeTaken)
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

    @IBAction func FinishButtonAction(_ sender: UIButton) {
         if let existingLandingVC = self.navigationController?.viewControllers.first(where: { vc in
             return vc is LevelSelectionViewController})
            {
             self.navigationController?.popToViewController(existingLandingVC, animated: true)
         } else {
             let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
             let homeVC = storyboard.instantiateViewController(withIdentifier: "matchTheCardsLandingPage") as! LevelSelectionViewController
       
             self.navigationController?.setViewControllers([homeVC], animated: true)
         }
    }
}
