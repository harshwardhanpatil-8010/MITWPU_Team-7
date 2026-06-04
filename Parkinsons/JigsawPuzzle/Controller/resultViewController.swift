
import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var FinishButton: UIButton!

    var timeTaken: Int = 0
    private let themeColor = UIColor.systemBrown

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        saveCompletion()
        setupUI()
    }

    private func setupUI() {
        let durationText: String
        if timeTaken < 60 {
            durationText = "\(timeTaken)s"
        } else {
            let minutes = timeTaken / 60
            let seconds = timeTaken % 60
            durationText = String(format: "%02d:%02d", minutes, seconds)
        }

        buildUnifiedResultScreen(
            title: celebrationResultTitle(),
            symbolName: "hands.clap.fill",
            emojiText: nil,
            message: "You are improving your cognitive planning and spatial reasoning.",
            stats: [
                ("Time", durationText),
                ("Puzzle", "Completed")
            ],
            themeColor: themeColor,
            finishAction: #selector(finishButtonTapped(_:))
        )

        showUniformConfetti()
    }

    private func saveCompletion() {
        let today = Calendar.current.startOfDay(for: Date())
        PuzzleGameManager.shared.markCompleted(date: today)
        PuzzleGameManager.shared.saveCompletion(date: today, time: timeTaken)
    }

    @objc private func finishButtonTapped(_ sender: Any) {
        navigateBackToLevelSelection()
    }

    @IBAction func FinishButtonAction(_ sender: UIButton) {
        navigateBackToLevelSelection()
    }

    private func navigateBackToLevelSelection() {
        if let nav = navigationController {
            if let target = nav.viewControllers.first(where: { $0 is LevelSelectionPuzzleViewController }) {
                nav.popToViewController(target, animated: true)
            } else {
                nav.popToRootViewController(animated: true)
            }
            return
        }

        dismiss(animated: true)
    }
}
