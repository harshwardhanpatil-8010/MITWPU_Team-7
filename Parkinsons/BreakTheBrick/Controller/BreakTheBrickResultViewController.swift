// BreakTheBrickResultViewController.swift
// Parkinsons

import UIKit

class BreakTheBrickResultViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var scoreValueLabel: UILabel!
    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!

    var finalScore: Int = 0
    var duration: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    private func setupUI() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .systemBackground

        titleLabel.text = "Good Job!"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)

        let messages = [
            "Excellent hand-eye coordination!",
            "Great focus and precision!",
            "Nice reflexes!",
            "You're improving consistently!"
        ]
        messageLabel.text = messages.randomElement()
        messageLabel.textColor = .secondaryLabel

        scoreValueLabel.text = "\(finalScore)"
        scoreValueLabel.textColor = .systemTeal

        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        durationValueLabel.text = String(format: "%02d:%02d", minutes, seconds)

        doneButton.layer.cornerRadius = 12
        doneButton.backgroundColor = .systemTeal
        doneButton.setTitleColor(.white, for: .normal)

        showConfetti()
    }

    private func showConfetti() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)

        let colors: [UIColor] = [.systemYellow, .systemOrange, .systemRed, .white, .systemBlue]
        let cells: [CAEmitterCell] = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 4
            cell.lifetime = 5.0
            cell.velocity = 150
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 2
            cell.spinRange = 3
            cell.scale = 0.1
            cell.scaleRange = 0.05
            cell.color = color.cgColor

            let size = CGSize(width: 10, height: 10)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: CGRect(origin: .zero, size: size))
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            cell.contents = image.cgImage
            return cell
        }

        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)
    }

    @IBAction func doneTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}
