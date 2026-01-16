import UIKit
import RealityKit

class EmojiGameViewController: UIViewController {

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var cameraContainerView: ARView!
    @IBOutlet weak var backgroundCard: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var emojiNameLabel: UILabel!

    let arModel = EmojiARModel()
    
    // NEW: Store a shuffled version of the challenges
    var shuffledChallenges: [EmojiChallenge] = []
    var currentLevel = 0
    
    var score = 0
    var timer: Timer?
    var remainingTime = 30
    var skippedCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        arModel.setup(view: cameraContainerView)
        arModel.onMatch = { [weak self] in
            self?.handleSuccess()
        }
        
        startGame()
    }

    func startGame() {
        score = 0
        skippedCount = 0
        currentLevel = 0
        
        // 1. Shuffle the challenges from EmojiData
        shuffledChallenges = EmojiData.challenges.shuffled()
        
        updateScoreLabel()
        startTimer()
        nextChallenge()
    }

    func startTimer() {
        timer?.invalidate()
        remainingTime = 30
        updateTimerLabel()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func tick() {
        if remainingTime > 0 {
            remainingTime -= 1
            updateTimerLabel()
        } else {
            timer?.invalidate()
            goToResults()
        }
    }
    
    func goToResults() {
        if let resultVC = storyboard?.instantiateViewController(withIdentifier: "resultMimicTheEmoji") as? resultMimicTheEmoji {
            resultVC.completedCount = self.score
            resultVC.skippedCount = self.skippedCount
            resultVC.timeTaken = 30
            resultVC.modalPresentationStyle = .fullScreen
            self.present(resultVC, animated: true, completion: nil)
        }
    }

    func updateTimerLabel() {
        timeLeftLabel.text = "Time Left: \(remainingTime)"
    }

    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }

    func nextChallenge() {
        // 2. Safety check: If we run out of challenges, reshuffle and restart index
        if currentLevel >= shuffledChallenges.count {
            shuffledChallenges = EmojiData.challenges.shuffled()
            currentLevel = 0
        }
        
        let challenge = shuffledChallenges[currentLevel]
        arModel.currentChallenge = challenge
        emojiLabel.text = challenge.emoji
        emojiNameLabel.text = challenge.name
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        skippedCount += 1
        currentLevel += 1
        nextChallenge()
    }

    func handleSuccess() {
        score += 1
        updateScoreLabel()

        if let scene = cameraContainerView.scene.anchors.first as? FaceRing.Scene {
            scene.notifications.ringAnimation.post()
        }
        
        currentLevel += 1
        // Pause briefly so the user sees the success animation before the emoji changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.nextChallenge()
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
