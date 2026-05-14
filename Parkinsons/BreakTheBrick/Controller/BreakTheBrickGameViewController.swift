// BreakTheBrickGameViewController.swift
// Parkinsons

import UIKit

class BreakTheBrickGameViewController: UIViewController {

    @IBOutlet weak var gameContainerView: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    var sessionDate: Date = Date()

    private var gameView: BreakTheBrickGameView?
    private var currentLevel = 1
    private var sessionStartTime: Date?
    private var totalScore = 0

    private var navGradientOverlay: CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemTeal.withAlphaComponent(0.20).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.0).cgColor
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameView?.stopGame()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let gradient = navGradientOverlay
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 180)
        view.layer.insertSublayer(gradient, at: 1)
    }

    private func setupNavigationBar() {
        self.title = "Break The Brick"

        let backImage = UIImage(systemName: "chevron.left")
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backTappedAction))
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton

        navigationItem.rightBarButtonItem = nil

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label, .font: UIFont.boldSystemFont(ofSize: 18)]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupGame() {
        guard gameContainerView != nil else { return }

        sessionStartTime = Date()
        totalScore = 0

        levelLabel.text = "Level \(currentLevel)"
        scoreLabel.text = "Score: 0"
        feedbackLabel.text = "Break the bricks!"
        progressView.progress = 0

        // Create and embed the UIKit game view
        let gv = BreakTheBrickGameView(frame: gameContainerView.bounds)
        gv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gameContainerView.addSubview(gv)
        self.gameView = gv

        gv.onLevelComplete = { [weak self] score in
            self?.handleLevelCompletion(score: score)
        }
        gv.onProgressUpdate = { [weak self] progress in
            self?.progressView.setProgress(Float(progress), animated: true)
        }
        gv.onScoreUpdate = { [weak self] score in
            self?.scoreLabel.text = "Score: \(score)"
            self?.totalScore = score
        }
        gv.onFeedbackUpdate = { [weak self] text in
            self?.feedbackLabel.text = text
        }

        gv.setupLevel(currentLevel)
        gv.startGame()
    }

    private func handleLevelCompletion(score: Int) {
        totalScore = score
        if currentLevel < 3 {
            currentLevel += 1
            levelLabel.text = "Level \(currentLevel)"
            feedbackLabel.text = "Great! Level \(currentLevel)..."
            progressView.progress = 0
            gameView?.setupLevel(currentLevel)
            gameView?.startGame()
        } else {
            finishGame()
        }
    }

    private func finishGame() {
        gameView?.stopGame()

        let duration = Date().timeIntervalSince(sessionStartTime ?? Date())

        BreakTheBrickManager.shared.saveSession(
            date: sessionDate,
            score: totalScore,
            duration: duration,
            level: "Level \(currentLevel)"
        )

        let storyboard = UIStoryboard(name: "BreakTheBrick", bundle: nil)
        if let resultVC = storyboard.instantiateViewController(withIdentifier: "BreakTheBrickResultViewController") as? BreakTheBrickResultViewController {
            resultVC.finalScore = totalScore
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

// MARK: - UIKit Game View

class BreakTheBrickGameView: UIView {

    var onLevelComplete: ((Int) -> Void)?
    var onProgressUpdate: ((Double) -> Void)?
    var onScoreUpdate: ((Int) -> Void)?
    var onFeedbackUpdate: ((String) -> Void)?

    // Game elements
    private let paddle = UIView()
    private let ball   = UIView()
    private var bricks: [UIView] = []

    // Game state
    private var ballVelocity = CGPoint.zero
    private var score = 0
    private var bricksTotal = 0
    private var bricksDestroyed = 0
    private var currentLevel = 1
    private var isRunning = false
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0

    private let ballSize: CGFloat    = 16
    private let paddleW: CGFloat     = 90
    private let paddleH: CGFloat     = 12
    private let paddleBottom: CGFloat = 40
    private let brickRows    = 5
    private let brickCols    = 7
    private let brickH: CGFloat      = 26
    private let brickSpacing: CGFloat = 5
    private let brickTopPad: CGFloat  = 20

    private let rowColors: [UIColor] = [
        UIColor(red: 0.98, green: 0.27, blue: 0.32, alpha: 1),
        UIColor(red: 0.99, green: 0.70, blue: 0.10, alpha: 1),
        UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1),
        UIColor(red: 0.20, green: 0.67, blue: 0.98, alpha: 1),
        UIColor(red: 0.72, green: 0.39, blue: 0.97, alpha: 1)
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 1)
        setupPaddle()
        setupBall()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupPaddle() {
        paddle.backgroundColor = UIColor.systemTeal
        paddle.layer.cornerRadius = paddleH / 2
        paddle.layer.shadowColor   = UIColor.systemTeal.cgColor
        paddle.layer.shadowRadius  = 6
        paddle.layer.shadowOpacity = 0.6
        paddle.layer.shadowOffset  = .zero
        addSubview(paddle)
    }

    private func setupBall() {
        ball.backgroundColor = .white
        ball.layer.cornerRadius = ballSize / 2
        ball.layer.shadowColor   = UIColor.white.cgColor
        ball.layer.shadowRadius  = 4
        ball.layer.shadowOpacity = 0.8
        ball.layer.shadowOffset  = .zero
        addSubview(ball)
    }

    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    func setupLevel(_ level: Int) {
        currentLevel = level
        score = 0
        bricksDestroyed = 0

        // Remove old bricks
        bricks.forEach { $0.removeFromSuperview() }
        bricks.removeAll()

        layoutIfNeeded()
        buildBricks()
        resetPositions()
    }

    private func buildBricks() {
        let sidePad: CGFloat = 8
        let totalSpacingH = brickSpacing * CGFloat(brickCols + 1)
        let brickW = (bounds.width - sidePad * 2 - totalSpacingH) / CGFloat(brickCols)

        for row in 0..<brickRows {
            for col in 0..<brickCols {
                let x = sidePad + brickSpacing + CGFloat(col) * (brickW + brickSpacing)
                let y = brickTopPad + CGFloat(row) * (brickH + brickSpacing)
                let brick = UIView(frame: CGRect(x: x, y: y, width: brickW, height: brickH))
                brick.backgroundColor = rowColors[row % rowColors.count]
                brick.layer.cornerRadius = 5
                brick.layer.shadowColor  = rowColors[row % rowColors.count].cgColor
                brick.layer.shadowRadius = 3
                brick.layer.shadowOpacity = 0.4
                brick.layer.shadowOffset  = .zero
                insertSubview(brick, at: 0)
                bricks.append(brick)
            }
        }
        bricksTotal = bricks.count
    }

    private func resetPositions() {
        let cx = bounds.midX
        let py = bounds.height - paddleBottom
        paddle.frame = CGRect(x: cx - paddleW / 2, y: py, width: paddleW, height: paddleH)

        let bx = cx - ballSize / 2
        let by = py - ballSize - 4
        ball.frame = CGRect(x: bx, y: by, width: ballSize, height: ballSize)

        // Speed increases per level
        let speed: CGFloat = 280 + CGFloat(currentLevel - 1) * 30
        let angle = CGFloat.pi * 0.25 + CGFloat.random(in: -0.2...0.2)
        ballVelocity = CGPoint(x: speed * cos(angle), y: -speed)
    }

    func startGame() {
        isRunning = true
        displayLink?.invalidate()
        lastTimestamp = 0
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop(_:)))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stopGame() {
        isRunning = false
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func gameLoop(_ link: CADisplayLink) {
        guard isRunning else { return }
        let now = link.timestamp
        if lastTimestamp == 0 { lastTimestamp = now }
        let dt = min(now - lastTimestamp, 1.0 / 30.0)
        lastTimestamp = now
        update(dt: CGFloat(dt))
    }

    private func update(dt: CGFloat) {
        var pos = ball.frame.origin
        pos.x += ballVelocity.x * dt
        pos.y += ballVelocity.y * dt

        // Wall collisions
        if pos.x <= 0 { pos.x = 0; ballVelocity.x = abs(ballVelocity.x) }
        if pos.x + ballSize >= bounds.width { pos.x = bounds.width - ballSize; ballVelocity.x = -abs(ballVelocity.x) }
        if pos.y <= 0 { pos.y = 0; ballVelocity.y = abs(ballVelocity.y) }

        // Bottom — ball lost
        if pos.y + ballSize >= bounds.height {
            stopGame()
            onFeedbackUpdate?("Ball lost! 😬")
            // Restart level after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.resetPositions()
                self.startGame()
                self.onFeedbackUpdate?("Break the bricks!")
            }
            return
        }

        ball.frame.origin = pos

        // Paddle collision
        if ball.frame.intersects(paddle.frame) && ballVelocity.y > 0 {
            let hit = (ball.frame.midX - paddle.frame.minX) / paddle.frame.width
            let angle = (hit - 0.5) * CGFloat.pi * 0.75
            let speed = hypot(ballVelocity.x, ballVelocity.y)
            ballVelocity = CGPoint(x: speed * sin(angle), y: -speed * abs(cos(angle)))
            ball.frame.origin.y = paddle.frame.minY - ballSize
        }

        // Brick collision
        for brick in bricks where !brick.isHidden {
            if ball.frame.intersects(brick.frame) {
                hitBrick(brick)
                resolveCollision(with: brick.frame)
                break
            }
        }
    }

    private func hitBrick(_ brick: UIView) {
        bricksDestroyed += 1
        score += 10 * currentLevel
        onScoreUpdate?(score)

        let progress = Double(bricksDestroyed) / Double(max(1, bricksTotal))
        onProgressUpdate?(progress)

        UIView.animate(withDuration: 0.12, animations: {
            brick.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            brick.alpha = 0
        }, completion: { _ in
            brick.isHidden = true
            brick.transform = .identity
        })

        if bricksDestroyed >= bricksTotal {
            stopGame()
            onFeedbackUpdate?("Level clear! 🎉")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.onLevelComplete?(self?.score ?? 0)
            }
        }
    }

    private func resolveCollision(with rect: CGRect) {
        let bF = ball.frame
        let overlapL = bF.maxX - rect.minX
        let overlapR = rect.maxX - bF.minX
        let overlapT = bF.maxY - rect.minY
        let overlapB = rect.maxY - bF.minY
        if min(overlapL, overlapR) < min(overlapT, overlapB) {
            ballVelocity.x = -ballVelocity.x
        } else {
            ballVelocity.y = -ballVelocity.y
        }
    }

    @objc private func handlePan(_ gr: UIPanGestureRecognizer) {
        let dx = gr.translation(in: self).x
        gr.setTranslation(.zero, in: self)
        var newX = paddle.frame.origin.x + dx
        newX = max(0, min(bounds.width - paddleW, newX))
        paddle.frame.origin.x = newX
    }
}
