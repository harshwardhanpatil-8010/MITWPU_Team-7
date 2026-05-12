// StillSphereGameViewController.swift
// Parkinsons

import UIKit
import CoreMotion
import SpriteKit

class StillSphereGameViewController: UIViewController {

    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    var sessionDate: Date = Date() // Received from landing screen
    
    private let motionManager = CMMotionManager()
    private var scene: StillSphereScene?
    
    private var currentLevel = 1
    private var sessionStartTime: Date?
    private var totalSteadinessScore: Double = 0
    private var scoreCount = 0

    private var navGradientOverlay: CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemGreen.withAlphaComponent(0.20).cgColor,
            UIColor.systemGreen.withAlphaComponent(0.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1)
        return gradient
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupGame()
        startMotionUpdates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add Gradient
        let gradient = navGradientOverlay
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 180)
        view.layer.insertSublayer(gradient, at: 1) // Above SKView
    }
    
    private func setupNavigationBar() {
        self.title = "StillSphere"
        
        // Back Button
        let backImage = UIImage(systemName: "chevron.left")
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backTappedAction))
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
        
        // Remove ? button during game
        navigationItem.rightBarButtonItem = nil
        
        // Transparent Appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label, .font: UIFont.boldSystemFont(ofSize: 18)]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupGame() {
        guard skView != nil else { return }

        sessionStartTime = Date()
        
        levelLabel.text = "Level \(currentLevel)"
        timerLabel.text = "Time: 0s"
        feedbackLabel.text = "Hold steady..."
        progressView.progress = 0
        
        let gameScene = StillSphereScene(size: skView.bounds.size)
        gameScene.scaleMode = .aspectFill
        
        gameScene.onLevelComplete = { [weak self] steadiness in
            self?.handleLevelCompletion(steadiness: steadiness)
        }
        gameScene.onProgressUpdate = { [weak self] progress in
            self?.progressView.setProgress(Float(progress), animated: true)
        }
        gameScene.onTimeUpdate = { [weak self] seconds in
            self?.timerLabel.text = "Time: \(Int(seconds))s"
        }
        
        skView.presentScene(gameScene)
        self.scene = gameScene
        
        gameScene.setupLevel(currentLevel)
    }

    private func startMotionUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let data = data, error == nil else { return }
                self?.scene?.updateMotion(x: data.acceleration.x, y: data.acceleration.y)
            }
        }
    }

    private func handleLevelCompletion(steadiness: Double) {
        totalSteadinessScore += steadiness
        scoreCount += 1
        
        if currentLevel < 3 {
            currentLevel += 1
            levelLabel.text = "Level \(currentLevel)"
            feedbackLabel.text = "Good job! Level \(currentLevel)..."
            scene?.setupLevel(currentLevel)
        } else {
            finishGame()
        }
    }

    private func finishGame() {
        motionManager.stopAccelerometerUpdates()
        
        let duration = Date().timeIntervalSince(sessionStartTime ?? Date())
        let avgSteadiness = scoreCount > 0 ? totalSteadinessScore / Double(scoreCount) : 0
        
        // Save using the specific session date
        StillSphereManager.shared.saveSessionSummary(
            level: "Complete",
            duration: duration,
            steadiness: avgSteadiness,
            sensitivity: "Normal",
            date: sessionDate
        )
        
        let storyboard = UIStoryboard(name: "StillSphere", bundle: nil)
        if let resultVC = storyboard.instantiateViewController(withIdentifier: "StillSphereResultViewController") as? StillSphereResultViewController {
            resultVC.steadinessScore = avgSteadiness
            resultVC.duration = duration
            navigationController?.pushViewController(resultVC, animated: true)
        }
    }
    
    @objc private func backTappedAction() {
        let alert = UIAlertController(
            title: "Quit Game?",
            message: "Are you sure you want to quit? Your progress will not be saved.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })

        alert.addAction(UIAlertAction(title: "Resume", style: .cancel, handler: nil))

        present(alert, animated: true)
    }

    @IBAction func backTapped(_ sender: Any) {
        backTappedAction()
    }
}

// MARK: - SpriteKit Scene

class StillSphereScene: SKScene {
    var onLevelComplete: ((Double) -> Void)?
    var onProgressUpdate: ((Double) -> Void)?
    var onTimeUpdate: ((Double) -> Void)?
    
    private var sphere: SKShapeNode!
    private var targetArea: SKShapeNode!
    
    private var filterAlpha: Double = 0.07 
    private var filteredX: Double = 0
    private var filteredY: Double = 0
    
    private var levelDuration: TimeInterval = 15.0
    private var levelTimer: TimeInterval = 0
    private var totalTime: TimeInterval = 0
    
    private var currentLevel = 1
    private var steadinessSamples: [Double] = []

    func setupLevel(_ level: Int) {
        currentLevel = level
        removeAllChildren()
        
        backgroundColor = UIColor(red: 0.92, green: 0.96, blue: 1.0, alpha: 1.0)
        
        levelTimer = 0
        steadinessSamples = []
        
        let targetSize: CGFloat = level == 1 ? 135 : (level == 2 ? 115 : 95)
        targetArea = SKShapeNode(circleOfRadius: targetSize / 2)
        
        // Define safe zone margins to keep the ring fully on screen
        // Margin must be at least radius + extra for the glow and UI spacing
        let horizontalMargin: CGFloat = (targetSize / 2) + 40
        let verticalMargin: CGFloat = (targetSize / 2) + 150 // Extra top/bottom for labels/progress
        
        if level == 1 {
            targetArea.position = CGPoint(x: size.width / 2, y: size.height / 2)
        } else {
            // Truly random position within safe bounds
            let maxX = size.width - horizontalMargin
            let minX = horizontalMargin
            let maxY = size.height - verticalMargin
            let minY = verticalMargin
            
            let randomX = CGFloat.random(in: minX...maxX)
            let randomY = CGFloat.random(in: minY...maxY)
            targetArea.position = CGPoint(x: randomX, y: randomY)
        }
        
        targetArea.strokeColor = .white
        targetArea.lineWidth = 5
        targetArea.fillColor = .systemGreen.withAlphaComponent(0.3)
        targetArea.glowWidth = 20
        addChild(targetArea)
        
        sphere = SKShapeNode(circleOfRadius: 24)
        if level == 1 {
            sphere.position = CGPoint(x: size.width / 2, y: size.height / 2 - 200)
        } else {
            // Start sphere in center if target is random
            sphere.position = CGPoint(x: size.width / 2, y: size.height / 2)
        }
        
        sphere.fillColor = .white
        sphere.strokeColor = .systemGray4
        sphere.lineWidth = 1.5
        sphere.glowWidth = 10
        addChild(sphere)
    }

    override func update(_ currentTime: TimeInterval) {
        totalTime += 1.0/60.0
        onTimeUpdate?(totalTime)
    }

    func updateMotion(x: Double, y: Double) {
        filteredX = (x * filterAlpha) + (filteredX * (1.0 - filterAlpha))
        filteredY = (y * filterAlpha) + (filteredY * (1.0 - filterAlpha))
        
        let sensitivityX: CGFloat = size.width * 0.6
        let sensitivityY: CGFloat = size.height * 0.6
        
        let targetX = size.width / 2 + CGFloat(filteredX) * sensitivityX
        let targetY = size.height / 2 + CGFloat(filteredY) * sensitivityY
        
        let clampedX = max(35, min(size.width - 35, targetX))
        let clampedY = max(35, min(size.height - 35, targetY))
        
        let moveAction = SKAction.move(to: CGPoint(x: clampedX, y: clampedY), duration: 0.25)
        sphere.run(moveAction)
        
        checkSteadiness()
    }
    
    private func checkSteadiness() {
        let dist = hypot(sphere.position.x - targetArea.position.x, sphere.position.y - targetArea.position.y)
        let inTarget = dist < (targetArea.frame.width / 2)
        
        if inTarget {
            levelTimer += 1.0/60.0
            let sample = max(0, 1.0 - (dist / (targetArea.frame.width / 2)))
            steadinessSamples.append(sample)
        }
        
        let progress = levelTimer / levelDuration
        onProgressUpdate?(progress)
        
        if progress >= 1.0 {
            let avg = steadinessSamples.reduce(0, +) / Double(max(1, steadinessSamples.count))
            onLevelComplete?(avg * 100)
        }
    }
}
