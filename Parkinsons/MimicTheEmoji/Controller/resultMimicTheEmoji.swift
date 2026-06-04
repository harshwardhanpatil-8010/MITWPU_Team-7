import UIKit

class resultMimicTheEmoji: UIViewController {

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

        setupResultScreen()
        showUniformConfetti()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func setupResultScreen() {
        let titles = ["Good Job!", "Well Done!"]
        let randomTitle = titles.randomElement() ?? "Good Job!"

        let timeMins = timeTaken / 60
        let timeSecs = timeTaken % 60
        let timeText = timeMins > 0
            ? String(format: "%02d:%02d", timeMins, timeSecs)
            : "\(timeSecs)s"

        buildUnifiedResultScreen(
            title: randomTitle,
            symbolName: nil,
            emojiText: nil,
            message: "Great work! You're training your facial muscles and expression recognition.",
            stats: [
                ("Completed", "\(completedCount)"),
                ("Skipped", "\(skippedCount)"),
                ("Time", timeText)
            ],
            themeColor: UIColor(hex: "FF6B6B"),
            finishAction: #selector(finishButtonTapped(_:))
        )
    }

    @objc func finishButtonTapped(_ sender: Any) {
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
