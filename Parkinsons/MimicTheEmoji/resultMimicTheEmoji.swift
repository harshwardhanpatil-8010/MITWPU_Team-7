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
        
        
        if let date = playedDate {
            EmojiGameManager.shared.markAsCompleted(date: date) // Saves to memory
        }
        NotificationCenter.default.post(name: .didUpdateGameCompletion, object: nil) // Broadcasts update
        
        setupResultCard()
        displayResults()
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
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

