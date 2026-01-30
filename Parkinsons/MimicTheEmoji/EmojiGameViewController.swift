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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // selectedDate can be used to track the day's session if needed
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
            
            // --- ADD THIS LINE BELOW ---
            resultVC.playedDate = self.selectedDate
            // ---------------------------
            
            resultVC.modalPresentationStyle = .fullScreen
            self.present(resultVC, animated: true, completion: nil)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
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

