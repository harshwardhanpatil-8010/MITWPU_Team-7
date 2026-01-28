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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupResultCard()
        displayResults()
    }
    
    func setupResultCard() {
        // 1. Set Corner Radius
        resultCardBackground.layer.cornerRadius = 15
        
        // 2. Set Shadow Properties
        resultCardBackground.layer.shadowColor = UIColor.black.cgColor
        resultCardBackground.layer.shadowOpacity = 0.2
        resultCardBackground.layer.shadowOffset = CGSize(width: 0, height: 4)
        resultCardBackground.layer.shadowRadius = 8
        
        // 3. Important: Ensure masksToBounds is false
        // If this is true, the shadow will be cut off.
        resultCardBackground.layer.masksToBounds = false
    }
    func displayResults() {
            completedEmojiCount.text = "\(completedCount)"
            skippedEmojiCount.text = "\(skippedCount)"
            timeTakenCount.text = "\(timeTaken)"
        }
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "MimicTheEmoji", bundle: nil) // Ensure name matches your .storyboard file
        guard let landingVC = storyboard.instantiateViewController(withIdentifier: "EmojiLandingScreen") as? EmojiLandingScreen else { return }
        
        landingVC.modalPresentationStyle = .fullScreen
        self.present(landingVC, animated: true, completion: nil)
    }
}
