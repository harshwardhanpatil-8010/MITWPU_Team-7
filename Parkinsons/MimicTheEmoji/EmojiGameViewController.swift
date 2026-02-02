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
        setupCustomBackButton()
        // selectedDate can be used to track the day's session if needed
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
        // 1. Hide the default chevron back button
        self.navigationItem.hidesBackButton = true
        
        // 2. Define the action closure (No @objc needed)
        let closeAction = UIAction { [weak self] _ in
            self?.showQuitAlert()
        }
        
        // 3. Create the "X" button using the correct system item initializer
        // .close is the standard "X" icon for modern iOS
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
        closeButton.primaryAction = closeAction
        
        // 4. Assign it to the left side
        self.navigationItem.leftBarButtonItem = closeButton
    }

    func showQuitAlert() {
        let alert = UIAlertController(
            title: "Quit Game?",
            message: "Are you sure you want to quit? Your progress will not be saved.",
            preferredStyle: .alert
        )
        
        let quitAction = UIAlertAction(title: "Quit", style: .destructive) { [weak self] _ in
            // Navigates back because we used nav.pushViewController earlier
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
            
            // Use the Navigation Controller to PUSH the view
            if let nav = self.navigationController {
                nav.pushViewController(resultVC, animated: true)
            } else {
                // If there is no Nav Controller, fallback to present (for debugging)
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

