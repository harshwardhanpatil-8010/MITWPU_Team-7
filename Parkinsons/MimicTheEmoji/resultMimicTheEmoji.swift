import UIKit

class resultMimicTheEmoji: UIViewController {

    @IBOutlet weak var timeTakenCount: UILabel!
    @IBOutlet weak var skippedEmojiCount: UILabel!
    @IBOutlet weak var completedEmojiCount: UILabel!
    @IBOutlet weak var resultCardBackground: UIView!
    @IBOutlet weak var finishButton: UIButton!

    var completedCount: Int = 0
    var skippedCount: Int = 0
    var timeTaken: Int = 30
    var playedDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIX: Logic must be inside a function
        // resultMimicTheEmoji.swift
        if let date = playedDate {
            EmojiGameManager.shared.markAsCompleted(date: date) // Saves to memory
        }
        NotificationCenter.default.post(name: .didUpdateGameCompletion, object: nil) // Broadcasts update
        
        setupResultCard()
        displayResults()
    }

    func setupResultCard() {
        resultCardBackground.layer.cornerRadius = 15
        resultCardBackground.layer.shadowColor = UIColor.black.cgColor
        resultCardBackground.layer.shadowOpacity = 0.2
        resultCardBackground.layer.shadowOffset = CGSize(width: 0, height: 4)
        resultCardBackground.layer.shadowRadius = 8
        resultCardBackground.layer.masksToBounds = false
    }

    func displayResults() {
        completedEmojiCount.text = "\(completedCount)"
        skippedEmojiCount.text = "\(skippedCount)"
        timeTakenCount.text = "\(timeTaken)"
    }

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        // BETTER PRACTICE:
        // Instead of presenting a NEW LandingScreen (which creates a loop in memory),
        // dismiss back to the root or the original landing screen.
        if let nav = self.navigationController {
            nav.popToRootViewController(animated: true)
        } else {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
