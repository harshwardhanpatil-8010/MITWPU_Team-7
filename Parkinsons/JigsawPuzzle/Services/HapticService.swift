
import UIKit

final class HapticService {
    static let shared = HapticService()
    private init() {}
    private let light   = UIImpactFeedbackGenerator(style: .light)
    private let medium  = UIImpactFeedbackGenerator(style: .medium)
    private let rigid   = UIImpactFeedbackGenerator(style: .rigid)
    private let notif   = UINotificationFeedbackGenerator()

    func warmUp()            { light.prepare(); medium.prepare(); notif.prepare() }
    func pieceLift()         { light.impactOccurred(intensity: 0.5) }
    func pieceDrop()         { light.impactOccurred(intensity: 0.7) }
    func correctPlacement()  { medium.impactOccurred(intensity: 1.0) }
    func incorrectPlacement(){ light.impactOccurred(intensity: 0.4) }
    func gameComplete()      { notif.notificationOccurred(.success) }
    func shufflePulse()      { rigid.impactOccurred(intensity: 0.6) }
}
