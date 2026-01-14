import UIKit
import RealityKit

class EmojiGameViewController: UIViewController {

    @IBOutlet weak var cameraContainerView: ARView! // Now an ARView
    @IBOutlet weak var backgroundCard: UIView!
    @IBOutlet weak var emojiLabel: UILabel! // Add these to your Storyboard
    @IBOutlet weak var emojiNameLabel: UILabel!

    let arModel = EmojiARModel()
    var currentLevel = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        arModel.setup(view: cameraContainerView)
        arModel.onMatch = { [weak self] in
            self?.handleSuccess()
        }
        
        nextChallenge()
    }

    func nextChallenge() {
        let challenge = EmojiData.challenges[currentLevel % EmojiData.challenges.count]
        arModel.currentChallenge = challenge
        emojiLabel.text = challenge.emoji
        emojiNameLabel.text = challenge.name
    }

    func handleSuccess() {
        // 1. Trigger the Ring Animation
        if let scene = cameraContainerView.scene.anchors.first as? FaceRing.Scene {
            scene.notifications.ringAnimation.post()
        }
        
        // 2. Move to next emoji after a brief pause
        currentLevel += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.nextChallenge()
        }
    }
    
    func setupUI() {
        backgroundCard.layer.cornerRadius = 24
        backgroundCard.backgroundColor = .white
        cameraContainerView.layer.cornerRadius = 20
        cameraContainerView.clipsToBounds = true
        
        emojiLabel.font = UIFont.systemFont(ofSize: 150)
    }
}
