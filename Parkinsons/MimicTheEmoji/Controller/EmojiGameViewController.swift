import UIKit
import RealityKit

class EmojiGameViewController: UIViewController {
    public var selectedDate: Date?

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var cameraContainerView: ARView!
    @IBOutlet weak var backgroundCard: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var emojiNameLabel: UILabel!

    let arModel = EmojiARModel()
    
    var shuffledChallenges: [EmojiChallenge] = []
    var currentLevel = 0
    
    var score = 0
    var timer: Timer?
    
   
    var timeElapsed = 0
    var skippedCount = 0
    var isAnimatingSuccess = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCustomBackButton()
        arModel.setup(view: cameraContainerView)
        arModel.onMatch = { [weak self] in
            self?.handleSuccess()
        }
        
        startGame()
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    func setupCustomBackButton() {
        self.navigationItem.hidesBackButton = true
        
        let closeAction = UIAction { [weak self] _ in
            self?.showQuitAlert()
        }
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
        closeButton.primaryAction = closeAction
        
        self.navigationItem.leftBarButtonItem = closeButton
    }

    func showQuitAlert() {
        let alert = UIAlertController(
            title: "Quit Game?",
            message: "Are you sure you want to quit? Your progress will not be saved.",
            preferredStyle: .alert
        )
        
        let quitAction = UIAlertAction(title: "Quit", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(quitAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    func startGame() {
        score = 0
        skippedCount = 0
        currentLevel = 0
        timeElapsed = 0
        
        shuffledChallenges = EmojiData.challenges.shuffled()
        
        updateScoreLabel()
        startTimer()
        nextChallenge()
    }

    func startTimer() {
        timer?.invalidate()
        updateTimerLabel()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func tick() {
        timeElapsed += 1
        updateTimerLabel()
    }
    func goToResults() {
        if let resultVC = storyboard?.instantiateViewController(withIdentifier: "resultMimicTheEmoji") as? resultMimicTheEmoji {
            resultVC.completedCount = self.score
            resultVC.skippedCount = self.skippedCount
            resultVC.timeTaken = self.timeElapsed
            resultVC.playedDate = self.selectedDate
            
            if let nav = self.navigationController {
                nav.pushViewController(resultVC, animated: true)
            } else {
                resultVC.modalPresentationStyle = .fullScreen
                self.present(resultVC, animated: true)
            }
        }
    }
    
    func updateTimerLabel() {
        timeLeftLabel.text = "Time: \(timeElapsed)s"
    }

    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }

    func nextChallenge() {
        let totalPlayed = score + skippedCount
        
        if totalPlayed >= 10 {
            timer?.invalidate()
            goToResults()
            return
        }
        
        if currentLevel < shuffledChallenges.count {
            let challenge = shuffledChallenges[currentLevel]
            arModel.currentChallenge = challenge
            emojiLabel.text = challenge.emoji
            emojiNameLabel.text = challenge.name
        }
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        guard !isAnimatingSuccess else { return }
        skippedCount += 1
        currentLevel += 1
        nextChallenge()
    }

    func handleSuccess() {
        guard !isAnimatingSuccess else { return }
        isAnimatingSuccess = true
        
        score += 1
        updateScoreLabel()

        if let scene = cameraContainerView.scene.anchors.first as? FaceRing.Scene {
            scene.notifications.ringAnimation.post()
        }
        
        currentLevel += 1
        
        showSuccessAnimation { [weak self] in
            self?.isAnimatingSuccess = false
            self?.nextChallenge()
        }
    }

    func showSuccessAnimation(completion: @escaping () -> Void) {
        skipButton.isEnabled = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .bold)
        let checkmarkImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        let checkmarkView = UIImageView(image: checkmarkImage)
        checkmarkView.tintColor = .systemGreen
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.alpha = 0
        checkmarkView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        view.addSubview(checkmarkView)
        
        NSLayoutConstraint.activate([
            checkmarkView.centerXAnchor.constraint(equalTo: emojiLabel.centerXAnchor),
            checkmarkView.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor)
        ])
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            checkmarkView.alpha = 1
            checkmarkView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.15, animations: {
                checkmarkView.transform = .identity
            }) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    UIView.animate(withDuration: 0.2, animations: {
                        checkmarkView.alpha = 0
                        checkmarkView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    }) { [weak self] _ in
                        checkmarkView.removeFromSuperview()
                        self?.skipButton.isEnabled = true
                        completion()
                    }
                }
            }
        }
    }
    
    func setupUI() {
        backgroundCard.layer.cornerRadius = 24
        backgroundCard.backgroundColor = .white
        cameraContainerView.layer.cornerRadius = 20
        cameraContainerView.clipsToBounds = true
        emojiLabel.font = UIFont.systemFont(ofSize: 150)
        
        skipButton.addTarget(self, action: #selector(skipButtonTapped(_:)), for: .touchUpInside)
    }
}

