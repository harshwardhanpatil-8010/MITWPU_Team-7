//
//  10minworkoutCountdownViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class _0minworkoutCountdownViewController: UIViewController {
    @IBOutlet weak var TimerLabel: UILabel!
    var countDown = 4
    override func viewDidLoad() {
        super.viewDidLoad()
        TimerLabel.text = "\(countDown)"
        TimerLabel.alpha = 1
        startCountDown()

        // Do any additional setup after loading the view.
    }
    func startCountDown() {
         guard countDown > 0 else {
             navigateToNextScreen()
             return
         }
        TimerLabel.text = "\(countDown)"
             TimerLabel.alpha = 1
             TimerLabel.transform = .identity
             
             UIView.animate(withDuration: 1.0, animations: {
                 self.TimerLabel.alpha = 0
                 self.TimerLabel.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
             }) { _ in
                 self.countDown -= 1
                 self.startCountDown()  // 
             }
         }
    func navigateToNextScreen() {
        let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "10minworkoutViewController") as! _0minworkoutViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical   // Default push-like (slides from bottom)

        // For push-like slide from right animation:
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromRight
        view.window?.layer.add(transition, forKey: kCATransition)
        present(vc, animated: false)

        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
