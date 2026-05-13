import UIKit

class WhackAMoleSuccessViewController: UIViewController {

    var score: Int = 0
    var hitBomb: Bool = false
    var selectedDate: Date!

    private let themeColor = UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        setupUI()
        showConfetti()
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
        let trophyLabel = UILabel()
        trophyLabel.text = hitBomb ? "💥" : "🏆"
        trophyLabel.font = .systemFont(ofSize: 80)
        trophyLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = hitBomb ? "Boom!" : "Great Job!"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = hitBomb
            ? "You hit a bomb but still scored:"
            : "Challenge completed!"
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center

        let scoreLabel = UILabel()
        scoreLabel.text = "Score: \(score)"
        scoreLabel.font = .systemFont(ofSize: 28, weight: .heavy)
        scoreLabel.textColor = themeColor
        scoreLabel.textAlignment = .center

        let molesLabel = UILabel()
        molesLabel.text = "\(score / 10) moles whacked"
        molesLabel.font = .systemFont(ofSize: 17, weight: .regular)
        molesLabel.textColor = .secondaryLabel
        molesLabel.textAlignment = .center

        let durationLabel = UILabel()
        let dur = WhackAMoleGameManager.shared.gameDuration(for: selectedDate)
        let diff = WhackAMoleGameManager.shared.difficultyLabel(for: selectedDate)
        durationLabel.text = "Difficulty: \(diff) (\(dur)s)"
        durationLabel.font = .systemFont(ofSize: 15, weight: .medium)
        durationLabel.textColor = .tertiaryLabel
        durationLabel.textAlignment = .center

        var config = UIButton.Configuration.filled()
        config.title = "Finish"
        config.baseBackgroundColor = themeColor
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 60, bottom: 14, trailing: 60)

        let finishButton = UIButton(type: .system)
        finishButton.configuration = config
        finishButton.addTarget(self, action: #selector(finishTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            trophyLabel, titleLabel, subtitleLabel, scoreLabel, molesLabel, durationLabel, finishButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.setCustomSpacing(24, after: durationLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
    }

    @objc private func finishTapped() {
        if let landing = navigationController?.viewControllers.first(where: { $0 is WhackAMoleLandingViewController }) {
            navigationController?.popToViewController(landing, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    // MARK: - Confetti

    private func showConfetti() {
        let confettiLayer = CAEmitterLayer()
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 2)

        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemYellow, .systemPink]

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
            cell.contents = confettiImage().cgImage
            return cell
        }

        view.layer.addSublayer(confettiLayer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confettiLayer.birthRate = 0
        }
    }

    private func confettiImage() -> UIImage {
        let size = CGSize(width: 32, height: 20)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            if Bool.random() {
                ctx.cgContext.fill(CGRect(origin: .zero, size: size))
            } else {
                let r = min(size.width, size.height) / 2
                ctx.cgContext.addArc(center: CGPoint(x: size.width/2, y: size.height/2),
                                     radius: r, startAngle: 0, endAngle: .pi*2, clockwise: false)
                ctx.cgContext.fillPath()
            }
        }
    }
}
