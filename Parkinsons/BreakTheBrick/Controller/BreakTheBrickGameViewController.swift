// BreakTheBrickGameViewController.swift
// Parkinsons

import UIKit

class BreakTheBrickGameViewController: UIViewController {

    @IBOutlet weak var gameContainerView: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!

    var sessionDate: Date = Date()

    private var gameView: BreakTheBrickGameView?
    private var currentLevel = 1
    private var sessionStartTime: Date?
    private var isGameSetup = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let day = Calendar.current.component(.day, from: sessionDate)
        currentLevel = max(1, min(day, 31))
        setupUI()
        setupNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isGameSetup {
            isGameSetup = true
            setupGame()
        } else {
            gameView?.frame = gameContainerView.bounds
        }
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
    }

    private func setupNavigationBar() {
        self.title = "Level \(currentLevel)"
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain, target: self,
                                         action: #selector(backTappedAction))
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label,
                                          .font: UIFont.boldSystemFont(ofSize: 18)]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupGame() {
        guard gameContainerView != nil else { return }
        sessionStartTime = Date()
        levelLabel.text = "❤️❤️❤️"
        feedbackLabel.text = ""

        let gv = BreakTheBrickGameView(frame: gameContainerView.bounds)
        gv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gameContainerView.addSubview(gv)
        self.gameView = gv

        gv.onLevelComplete  = { [weak self] in self?.handleLevelCompletion() }
        gv.onLivesUpdate    = { [weak self] lives in
            self?.levelLabel.text = String(repeating: "❤️", count: max(0, lives))
        }
        gv.onFeedbackUpdate = { [weak self] text in self?.feedbackLabel.text = text }

        gv.setupLevel(currentLevel)
        gv.startGame()
    }

    private func handleLevelCompletion() {
        gameView?.stopGame()
        let duration = Date().timeIntervalSince(sessionStartTime ?? Date())
        BreakTheBrickManager.shared.saveSession(date: sessionDate, score: 0,
                                                duration: duration, level: "Level \(currentLevel)")
        let storyboard = UIStoryboard(name: "BreakTheBrick", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "BreakTheBrickResultViewController")
            as? BreakTheBrickResultViewController {
            vc.duration = duration
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func backTappedAction() {
        let alert = UIAlertController(title: "Quit Game?",
                                      message: "Your progress will not be saved.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Resume", style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func backTapped(_ sender: Any) { backTappedAction() }
}

// MARK: - Game View

class BreakTheBrickGameView: UIView {

    var onLevelComplete: (() -> Void)?
    var onFeedbackUpdate: ((String) -> Void)?
    var onLivesUpdate: ((Int) -> Void)?

    private let paddle = UIView()
    private let ball   = UIView()
    private var bricks: [UIView] = []

    private var ballVelocity = CGPoint.zero
    private var breakableBricksTotal = 0
    private var bricksDestroyed = 0
    private var currentLevel = 1
    private var lives = 3
    private var isRunning = false
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0

    private let ballSize: CGFloat     = 14
    private let paddleH: CGFloat      = 12
    private let paddleBottom: CGFloat = 80
    private let brickH: CGFloat       = 24
    private let brickSpacing: CGFloat = 5
    private let brickTopPad: CGFloat  = 200
    private let cols = 7
    private let sidePad: CGFloat      = 8    // 

    // MARK: - Level Layouts
    
    private static let levelLayouts: [[String]] = [

        // 1
        ["BBBBBBB",
         "BBBBBBB",
         ".......",
         ".......",
         "......."],

        // 2
        ["BBBBBBB",
         "BIBBBIB",
         "BBBBBBB",
         ".......",
         "......."],

        // 3
        ["BBBBBBB",
         "IBBBBBI",
         "IIBBBII",
         ".......",
         "......."],

        // 4
        ["BIBIBIB",
         "BBBBBBB",
         ".......",
         ".......",
         "......."],

        // 5
        ["BBBBBBB",
         "BIBIBIB",
         "BBBBBBB",
         ".......",
         "......."],

        // 6
        ["BBBBBBB",
         "IIBBBII",
         "IIB.BII",
         "IBBBBBI",
         "BBBBBBB"],

        // 7
        ["BIBIBIB",
         "BBBBBBB",
         "BIBIBIB",
         ".......",
         "......."],

        // 8
        ["BBBBBBB",
         "I.BBB.I",
         "BBBBBBB",
         ".......",
         "......."],

        // 9
        ["BBBBBBB",
         "BII.IIB",
         "BBBBBBB",
         ".......",
         "......."],

        // 10
        ["BIBIBIB",
         "BBBBBBB",
         "IBBBBBI",
         ".......",
         "......."],

        // 11
        ["BBBBBBB",
         "BIBIBIB",
         "BBBBBBB",
         "BIBIBIB",
         "......."],

        // 12
        ["BBBBBBB",
         "II...II",
         "BBBBBBB",
         "II...II",
         "......."],

        // 13
        ["BIBIBIB",
         "BBBBBBB",
         "BII.IIB",
         "BBBBBBB",
         "......."],

        // 14
        ["BBBBBBB",
         "IBIBIBI",
         "BBBBBBB",
         "IBIBIBI",
         "......."],

        // 15
        ["BBBBBBB",
         "B.....B",
         "BIBIBIB",
         "BBBBBBB",
         "......."],

        // 16
        ["BIBIBIB",
         "BBBBBBB",
         "II.B.II",
         "BBBBBBB",
         "......."],

        // 17
        ["BBBBBBB",
         "BIIBIIB",
         "BBBBBBB",
         "BIIBIIB",
         "......."],

        // 18
        ["BIBIBIB",
         "BBBBBBB",
         "BIBIBIB",
         "BBBBBBB",
         "......."],

        // 19
        ["BBBBBBB",
         "II.B.II",
         "BBBBBBB",
         "II.B.II",
         "......."],

        // 20
        ["BIBIBIB",
         "IBBBBBI",
         "BBBBBBB",
         "IBBBBBI",
         "......."],

        // 21
        ["BBBBBBB",
         "BI...IB",
         "BIBIBIB",
         "BBBBBBB",
         "BIBIBIB"],

        // 22
        ["IBBBBBI",
         "BBBBBBB",
         "BII.IIB",
         "BBBBBBB",
         "IBBBBBI"],

        // 23
        ["BIBIBIB",
         "BBBBBBB",
         "II.B.II",
         "BBBBBBB",
         "BIBIBIB"],

        // 24
        ["BBBBBBB",
         "IBIBIBI",
         "BBBBBBB",
         "IBIBIBI",
         "BBBBBBB"],

        // 25
        ["BIBBBIB",
         "BIIBIIB",
         "BBBBBBB",
         "BIIBIIB",
         "BIBIBIB"],

        // 26
        ["BBBBBBB",
         "II.B.II",
         "IIIIBBB",
         "II.B.II",
         "BBBBBBB"],

        // 27
        ["IBBBBBI",
         "BBBBBBB",
         "BIBIBIB",
         "BBBBBBB",
         "IBBBBBI"],

        // 28
        ["BIBIBIB",
         "BBBBBBB",
         "BI...IB",
         "BBBBBBB",
         "BIBIBIB"],

        // 29
        ["BBBBBBB",
         "IBIBIBI",
         "BBI.IBB",
         "IBIBIBI",
         "BBBBBBB"],

        // 30
        ["BIBIBIB",
         "BIIBIIB",
         "BBBBBBB",
         "BIIBIIB",
         "BIBIBIB"],

        // 31 FINAL BOSS
        ["BBBBBBB",
         "IIBBBII",
         "IIIBIII",
         "IIBBBII",
         "BBBBBBB"]
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 1)
        setupPaddle()
        setupBall()
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func setupPaddle() {
        paddle.backgroundColor = .systemTeal
        paddle.layer.cornerRadius = paddleH / 2
        paddle.layer.shadowColor   = UIColor.systemTeal.cgColor
        paddle.layer.shadowRadius  = 6
        paddle.layer.shadowOpacity = 0.6
        paddle.layer.shadowOffset  = .zero
        addSubview(paddle)
    }

    private func setupBall() {
        ball.layer.cornerRadius = ballSize / 2
        
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [
            UIColor(white: 0.8, alpha: 1.0).cgColor, // Highlight
            UIColor(white: 0.4, alpha: 1.0).cgColor, // Base color
            UIColor(white: 0.1, alpha: 1.0).cgColor  // Shadowed edge
        ]
        gradient.locations = [0.0, 0.6, 1.0]
        gradient.startPoint = CGPoint(x: 0.3, y: 0.3) // Light source from top-left
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0, y: 0, width: ballSize, height: ballSize)
        gradient.cornerRadius = ballSize / 2
        
        ball.layer.addSublayer(gradient)
        
        ball.layer.borderWidth = 0.5
        ball.layer.borderColor = UIColor(white: 0.2, alpha: 0.5).cgColor
        
        addSubview(ball)
    }

    func setupLevel(_ level: Int) {
        currentLevel = max(1, min(level, 31))
        bricksDestroyed = 0
        lives = 3
        onLivesUpdate?(lives)

        bricks.forEach { $0.removeFromSuperview() }
        bricks.removeAll()

        layoutIfNeeded()
        buildBricks()
        resetPositions()
    }

    private func buildBricks() {
        let idx = currentLevel - 1
        let layout = BreakTheBrickGameView.levelLayouts[idx]

        let totalW = bounds.width - (sidePad * 2) - CGFloat(cols - 1) * brickSpacing
        let brickW = totalW / CGFloat(cols)

        let gridTop: CGFloat = 180

        breakableBricksTotal = 0

        for (row, rowStr) in layout.enumerated() {
            let chars = Array(rowStr)
            for col in 0..<cols {
                let ch = col < chars.count ? chars[col] : Character(".")
                guard ch != "." else { continue }

                let x = sidePad + CGFloat(col) * (brickW + brickSpacing)
                let y = gridTop + CGFloat(row) * (brickH + brickSpacing)
                let w = (col == cols - 1) ? (bounds.width - x - sidePad) : brickW

                let brick = UIView(frame: CGRect(x: x, y: y, width: w, height: brickH))
                brick.layer.cornerRadius = 5

                if ch == "I" {
                    brick.backgroundColor = UIColor.systemGray
                    brick.layer.shadowColor = UIColor.systemGray.cgColor
                    brick.tag = 1  // iron — indestructible
                } else {
                    brick.backgroundColor = UIColor.systemOrange
                    brick.layer.shadowColor = UIColor.systemOrange.cgColor
                    brick.tag = 0  // breakable
                    breakableBricksTotal += 1
                }
                brick.layer.shadowRadius  = 3
                brick.layer.shadowOpacity = 0.4
                brick.layer.shadowOffset  = .zero

                insertSubview(brick, at: 0)
                bricks.append(brick)
            }
        }

        // Safety: ensure at least one breakable brick exists
        if breakableBricksTotal == 0, let first = bricks.first {
            first.tag = 0
            first.backgroundColor = .systemOrange
            breakableBricksTotal = 1
        }
    }

    private func resetPositions() {
        let paddleW: CGFloat = max(70, 110 - CGFloat((currentLevel - 1) / 5) * 8)
        let playW = bounds.width - sidePad * 2
        let cx = sidePad + playW / 2
        let py = bounds.height - paddleBottom
        paddle.frame = CGRect(x: cx - paddleW / 2, y: py, width: paddleW, height: paddleH)

        ball.frame = CGRect(x: cx - ballSize / 2, y: py - ballSize - 4,
                            width: ballSize, height: ballSize)

        let speed: CGFloat = min(260 + CGFloat(currentLevel - 1) * 15, 520)
        let angle = CGFloat.pi * 0.25 + CGFloat.random(in: -0.15...0.15)
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

        // Wall bounces — left/right walls align with brick grid edges
        if pos.x <= sidePad { pos.x = sidePad; ballVelocity.x = abs(ballVelocity.x) }
        if pos.x + ballSize >= bounds.width - sidePad { pos.x = bounds.width - sidePad - ballSize; ballVelocity.x = -abs(ballVelocity.x) }
        if pos.y <= 0 { pos.y = 0; ballVelocity.y = abs(ballVelocity.y) }

        // Ball lost
        if pos.y + ballSize >= bounds.height {
            lives -= 1
            onLivesUpdate?(lives)
            if lives > 0 {
                isRunning = false
                displayLink?.invalidate()
                onFeedbackUpdate?("Ball lost! 😬")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.resetPositions()
                    self.startGame()
                    self.onFeedbackUpdate?("")
                }
            } else {
                stopGame()
                onFeedbackUpdate?("Game Over! 😢")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.onLevelComplete?()
                }
            }
            return
        }

        ball.frame.origin = pos

        // Paddle bounce
        if ball.frame.intersects(paddle.frame) && ballVelocity.y > 0 {
            let hit = (ball.frame.midX - paddle.frame.minX) / paddle.frame.width
            let angle = (hit - 0.5) * CGFloat.pi * 0.75
            let speed = hypot(ballVelocity.x, ballVelocity.y)
            ballVelocity = CGPoint(x: speed * sin(angle), y: -speed * abs(cos(angle)))
            ball.frame.origin.y = paddle.frame.minY - ballSize
        }

        // Brick collision — check only visible, non-destroyed bricks
        for brick in bricks where !brick.isHidden && brick.tag != 2 {
            if ball.frame.intersects(brick.frame) {
                bounceBallOff(rect: brick.frame)
                if brick.tag == 0 { destroyBrick(brick) }
                break
            }
        }
    }

    /// Reflects the ball and pushes it fully outside `rect`, identical to how side-wall bounces work.
    private func bounceBallOff(rect: CGRect) {
        let bF = ball.frame
        // Penetration depths on each side
        let fromLeft  = bF.maxX - rect.minX   // ball came from left
        let fromRight = rect.maxX - bF.minX   // ball came from right
        let fromTop   = bF.maxY - rect.minY   // ball came from top
        let fromBot   = rect.maxY - bF.minY   // ball came from bottom

        let minH = min(fromLeft, fromRight)
        let minV = min(fromTop, fromBot)

        if minH < minV {
            // Horizontal hit — push out and flip X
            if fromLeft < fromRight {
                ball.frame.origin.x = rect.minX - ballSize
                ballVelocity.x = -abs(ballVelocity.x)
            } else {
                ball.frame.origin.x = rect.maxX
                ballVelocity.x = abs(ballVelocity.x)
            }
        } else {
            // Vertical hit — push out and flip Y
            if fromTop < fromBot {
                ball.frame.origin.y = rect.minY - ballSize
                ballVelocity.y = -abs(ballVelocity.y)
            } else {
                ball.frame.origin.y = rect.maxY
                ballVelocity.y = abs(ballVelocity.y)
            }
        }
    }

    private func destroyBrick(_ brick: UIView) {
        brick.tag = 2
        bricksDestroyed += 1

        UIView.animate(withDuration: 0.12, animations: {
            brick.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            brick.alpha = 0
        }, completion: { _ in
            brick.isHidden = true
            brick.transform = .identity
        })

        if bricksDestroyed >= breakableBricksTotal {
            stopGame()
            onFeedbackUpdate?("Level clear! 🎉")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.onLevelComplete?()
            }
        }
    }

    @objc private func handlePan(_ gr: UIPanGestureRecognizer) {
        let dx = gr.translation(in: self).x
        gr.setTranslation(.zero, in: self)
        var newX = paddle.frame.origin.x + dx
        newX = max(sidePad, min(bounds.width - sidePad - paddle.frame.width, newX))
        paddle.frame.origin.x = newX
    }
}
