import UIKit

class WhackAMoleSuccessViewController: UIViewController {

    var score: Int = 0
    var hitBomb: Bool = false
    var selectedDate: Date!
    var timeElapsed: Int = 0

    private let themeColor = UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func setupUI() {
        navigationItem.hidesBackButton = true
        
        let diff = WhackAMoleGameManager.shared.difficultyLabel(for: selectedDate)
        
        let messageText: String
        if hitBomb {
            messageText = "You hit a bomb! 💥\n\nDon't worry, better luck next time!"
        } else {
            messageText = "Difficulty: \(diff)\n\nYou are improving your reaction time and hand-eye coordination."
        }

        buildUnifiedResultScreen(
            title: hitBomb ? "Boom!" : "Good Job!",
            symbolName: nil,
            emojiText: hitBomb ? "💣" : nil,
            message: messageText,
            stats: [
                ("Score", "\(score)"),
                ("Whacked", "\(score / 10)"),
                ("Time", "\(timeElapsed)s")
            ],
            themeColor: themeColor,
            finishAction: #selector(finishTapped)
        )

        hitBomb ? showSmokeEffect() : showUniformConfetti()
    }

    @objc private func finishTapped() {
        if let landing = navigationController?.viewControllers.first(where: { $0 is WhackAMoleLandingViewController }) {
            navigationController?.popToViewController(landing, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    private func showSmokeEffect() {
        let smokeLayer = CAEmitterLayer()
        smokeLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 120)
        smokeLayer.emitterShape = .point
        smokeLayer.emitterSize = CGSize(width: 40, height: 20)

        let cell = CAEmitterCell()
        cell.birthRate = 18
        cell.lifetime = 1.6
        cell.velocity = 70
        cell.velocityRange = 45
        cell.emissionRange = .pi * 2
        cell.spin = 1
        cell.spinRange = 2
        cell.scale = 0.18
        cell.scaleRange = 0.08
        cell.alphaSpeed = -0.55
        cell.color = UIColor.systemGray2.withAlphaComponent(0.8).cgColor
        cell.contents = smokeImage().cgImage

        smokeLayer.emitterCells = [cell]
        view.layer.addSublayer(smokeLayer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            smokeLayer.birthRate = 0
        }
    }

    private func smokeImage() -> UIImage {
        let size = CGSize(width: 40, height: 40)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
}
