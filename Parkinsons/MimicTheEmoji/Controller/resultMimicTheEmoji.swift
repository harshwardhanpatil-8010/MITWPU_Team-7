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
    private let themeColor = UIColor(hex: "FF9500")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true

        if let date = playedDate {
            EmojiGameManager.shared.markAsCompleted(date: date)
        }
        NotificationCenter.default.post(name: .didUpdateGameCompletion, object: nil)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    private func setupUI() {
        let titleText: String
        switch completedCount {
        case 0...3:
            titleText = "You can do better!"
        case 4...7:
            titleText = "Good Job!"
        case 8...10:
            titleText = "Excellent!"
        default:
            titleText = "Good Job!"
        }

        buildUnifiedResultScreen(
            title: titleText,
            symbolName: "hands.clap.fill",
            emojiText: nil,
            message: "You are improving your facial muscle control, emotional expression, and cognitive motor response.",
            stats: [
                ("Completed", "\(completedCount)"),
                ("Skipped", "\(skippedCount)"),
                ("Time", "\(timeTaken)s")
            ],
            themeColor: themeColor,
            finishAction: #selector(finishActionTapped(_:))
        )

        showUniformConfetti()
    }

    @objc private func finishActionTapped(_ sender: Any) {
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

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        finishActionTapped(sender)
    }
}
