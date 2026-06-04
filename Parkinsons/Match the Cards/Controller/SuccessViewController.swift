import UIKit

class SuccessViewController: UIViewController {

    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!

    var timeTaken: Int!
    private let themeColor = UIColor(hex: "BF5AF2")

    override func viewDidLoad() {
        super.viewDidLoad()
        saveCompletion()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = nil
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func setupUI() {
        let durationText: String
        if let timeTaken = timeTaken {
            if timeTaken < 60 {
                durationText = "\(timeTaken)s"
            } else {
                let minutes = timeTaken / 60
                let seconds = timeTaken % 60
                durationText = String(format: "%02d:%02d", minutes, seconds)
            }
        } else {
            durationText = "0s"
        }

        buildUnifiedResultScreen(
            title: celebrationResultTitle(),
            symbolName: "hands.clap.fill",
            emojiText: nil,
            message: "You are improving your memory recall, concentration, and cognitive association.",
            stats: [
                ("Time", durationText),
                ("Cards", "Completed")
            ],
            themeColor: themeColor,
            finishAction: #selector(finishActionTapped(_:))
        )

        showUniformConfetti()
    }

    private func saveCompletion() {
        let today = Calendar.current.startOfDay(for: Date())
        DailyGameManager.shared.saveCompletion(date: today, time: timeTaken)
    }

    @objc private func finishActionTapped(_ sender: Any) {
         if let existingLandingVC = self.navigationController?.viewControllers.first(where: { vc in
             return vc is LevelSelectionViewController || vc is LevelSelectionPuzzleViewController
         }) {
             self.navigationController?.popToViewController(existingLandingVC, animated: true)
         } else {
             let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
             let homeVC = storyboard.instantiateViewController(withIdentifier: "matchTheCardsLandingPage") as! LevelSelectionViewController
             self.navigationController?.setViewControllers([homeVC], animated: true)
         }
    }

    @IBAction func FinishButtonAction(_ sender: UIButton) {
        finishActionTapped(sender)
    }
}
