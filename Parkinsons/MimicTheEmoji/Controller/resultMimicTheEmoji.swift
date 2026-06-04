import UIKit

class resultMimicTheEmoji: UIViewController {

    @IBOutlet weak var timeTakenCount: UILabel!
    @IBOutlet weak var skippedEmojiCount: UILabel!
    @IBOutlet weak var completedEmojiCount: UILabel!
    @IBOutlet weak var resultCardBackground: UIView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var resultTitleLabel: UILabel!

    var completedCount: Int = 0
    var skippedCount: Int = 0
    var timeTaken: Int = 30
    var playedDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true

        if let date = playedDate {
            EmojiGameManager.shared.markAsCompleted(date: date)
        }
        NotificationCenter.default.post(name: .didUpdateGameCompletion, object: nil)
        showConfetti()
        setupResultCard()
        setupResultLayout()
        displayResults()
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    func setupResultCard() {
        resultCardBackground.backgroundColor = .systemBackground
        resultCardBackground.layer.cornerRadius = 18
        resultCardBackground.layer.shadowColor = UIColor.black.cgColor
        resultCardBackground.layer.shadowOpacity = 0.09
        resultCardBackground.layer.shadowOffset = CGSize(width: 0, height: 2)
        resultCardBackground.layer.shadowRadius = 4
        resultCardBackground.layer.masksToBounds = false
    }

    private func setupResultLayout() {
        setLabelsBlack(in: view)
        resultTitleLabel.textAlignment = .center
        resultTitleLabel.font = .systemFont(ofSize: 43, weight: .bold)

        let clappingHands = UIImage(
            systemName: "hands.clap.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 100, weight: .semibold)
        )
        if let resultImageView = view.subviews.compactMap({ $0 as? UIImageView }).first {
            resultImageView.image = clappingHands
            resultImageView.tintColor = UIColor(red: 0.94, green: 0.71, blue: 0.45, alpha: 1)
            resultImageView.contentMode = .scaleAspectFit

            let imageConstraints = view.constraints.filter {
                $0.firstItem === resultImageView || $0.secondItem === resultImageView
            } + resultImageView.constraints
            NSLayoutConstraint.deactivate(imageConstraints)

            NSLayoutConstraint.activate([
                resultImageView.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 30),
                resultImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                resultImageView.widthAnchor.constraint(equalToConstant: 200),
                resultImageView.heightAnchor.constraint(equalToConstant: 142)
            ])
        }

        let finishConstraints = view.constraints.filter {
            $0.firstItem === finishButton || $0.secondItem === finishButton
        }
        NSLayoutConstraint.deactivate(finishConstraints)

        NSLayoutConstraint.activate([
            finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35),
            finishButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 180),
            finishButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }

    private func setLabelsBlack(in view: UIView) {
        view.subviews.forEach { subview in
            if let label = subview as? UILabel {
                label.textColor = .black
            }

            setLabelsBlack(in: subview)
        }
    }

    func displayResults() {
        completedEmojiCount.text = "\(completedCount)"
        skippedEmojiCount.text = "\(skippedCount)"
        timeTakenCount.text = "\(timeTaken)"

        resultTitleLabel.text = celebrationResultTitle()
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

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        if let nav = self.navigationController {

            if let landingVC = nav.viewControllers.first(where: { $0 is EmojiLandingScreen }) {
                nav.popToViewController(landingVC, animated: true)
            } else {
                nav.popViewController(animated: true)
            }

        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
