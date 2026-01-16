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
    var currentLevel = 0
    
    // Timer and Score state
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
        updateScoreLabel()
        startTimer()
        nextChallenge()
    }

    func startTimer() {
        timer?.invalidate() // Stop any existing timer
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
            // Optional: Handle Game Over logic here
        }
    }
    func goToResults() {
            // Option A: If using Storyboards (Recommended)
            // Make sure the "Identifier" for your result VC in Storyboard is "resultMimicTheEmoji"
            if let resultVC = storyboard?.instantiateViewController(withIdentifier: "resultMimicTheEmoji") as? resultMimicTheEmoji {
                
                // Pass the data
                resultVC.completedCount = self.score
                resultVC.skippedCount = self.skippedCount
                resultVC.timeTaken = 30
                
                // Navigate
                resultVC.modalPresentationStyle = .fullScreen // Optional: makes it full screen
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
        let challenge = EmojiData.challenges[currentLevel % EmojiData.challenges.count]
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
        // Increase score
        score += 1
        updateScoreLabel()

        // Trigger the Ring Animation
        if let scene = cameraContainerView.scene.anchors.first as? FaceRing.Scene {
            scene.notifications.ringAnimation.post()
        }
        
        // Move to next emoji after a brief pause
        currentLevel += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.nextChallenge()
        }
    }
    
    func setupUI() {
        backgroundCard.layer.cornerRadius = 24
        backgroundCard.backgroundColor = .white
        cameraContainerView.layer.cornerRadius = 20
        cameraContainerView.clipsToBounds = true
        
        emojiLabel.font = UIFont.systemFont(ofSize: 150)
        
        // Ensure the button is connected to the action if not using Storyboard
        skipButton.addTarget(self, action: #selector(skipButtonTapped(_:)), for: .touchUpInside)
    }
}
