import Foundation
import RealityKit
import ARKit

class EmojiARModel: NSObject, ARSessionDelegate {
    var arView: ARView?
    var currentChallenge: EmojiChallenge?
    var onMatch: (() -> Void)?
    
    private var isMatchingLocked = false

    func setup(view: ARView) {
        self.arView = view
        
        guard let session = view.session as ARSession? else {
            print("Error: The view is not a proper ARView")
            return
        }
        
        session.delegate = self
        let config = ARFaceTrackingConfiguration()
        session.run(config)
        
        if let faceScene = try? FaceRing.loadScene() {
            view.scene.anchors.append(faceScene)
        }
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor,
              let challenge = currentChallenge,
              !isMatchingLocked else { return }
        
        if challenge.check(faceAnchor) {
            isMatchingLocked = true
            onMatch?()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isMatchingLocked = false
            }
        }
    }
}

// Manual Bridge for the FaceRing project
enum FaceRing {
    static func loadScene() throws -> Entity & HasAnchoring {
        return try Entity.loadAnchor(named: "Scene", in: Bundle.main)
    }
    class Scene: Entity, HasAnchoring {
        var notifications: NotificationTriggerHelper { NotificationTriggerHelper() }
    }
}

struct NotificationTriggerHelper {
    var ringAnimation: AnimationTrigger { AnimationTrigger() }
}

struct AnimationTrigger {
    func post() { }
}
