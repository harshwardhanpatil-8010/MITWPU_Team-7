//
//  10minworkoutCountdownViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class _0minworkoutCountdownViewController: UIViewController {
    @IBOutlet weak var TimerLabel: UILabel!
    var countDown = 3
    var exercises: [Exercise] = []
    var startingIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        TimerLabel.text = "\(countDown)"
        TimerLabel.alpha = 1
        startCountDown()
        setupCloseButton()
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
                 self.startCountDown()
             }
         }
    func navigateToNextScreen() {
            let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "10minworkoutViewController") as! _0minworkoutViewController
  
        vc.exercises = WorkoutManager.shared.getTodayWorkout()
        vc.currentIndex = startingIndex
        navigationController?.pushViewController(vc, animated: true)
        }
    
    func setupCloseButton() {
            // Use the system image for a consistent "close" icon
         
            let closeButton = UIBarButtonItem(
                image: UIImage(systemName: "xmark"),
                style: .plain,
                target: self,
                action: #selector(closeButtonTapped) // This calls the function below when tapped
            )
            
            navigationItem.leftBarButtonItem = closeButton
        }
    
    @objc func closeButtonTapped() {
        let alert = UIAlertController(
               title: "Quit Workout?",
               message: "Are you sure you want to quit the workout?",
               preferredStyle: .alert
           )

           alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
               self.dismiss(animated: true) // or pop
           })

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           present(alert, animated: true)
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
