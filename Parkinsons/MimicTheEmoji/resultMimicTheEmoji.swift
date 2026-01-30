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
        // 1. Check if we are inside a Navigation Controller
        if let nav = self.navigationController {
            
            // Try to find the Emoji Landing Screen in the history
            if let landingVC = nav.viewControllers.first(where: { $0 is EmojiLandingScreen }) {
                nav.popToViewController(landingVC, animated: true)
            } else {
                // If it's not in history, just go back one screen
                nav.popViewController(animated: true)
            }
            
        } else {
            // 2. If we aren't in a Nav Controller, we must have been "Presented"
            // This closes the current screen and returns to the one underneath
            self.dismiss(animated: true, completion: nil)
        }
    }
}
