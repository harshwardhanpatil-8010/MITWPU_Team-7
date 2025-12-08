//
//  10minworkoutViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit
import YouTubeiOSPlayerHelper

protocol RestScreenDelegate: AnyObject {
    func restCompleted(nextIndex: Int)
}

class _0minworkoutViewController: UIViewController {
    
    @IBOutlet weak var playerView: FullScreenYTPlayerView!
    @IBOutlet weak var progressStackView: UIStackView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var exerciseName: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    var timer: Timer?
    var totalTime = 60
    var currentIndex: Int = 0
    var exercises: [Exercise] = []
    var progressBars: [UIView] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 35
        backgroundView.clipsToBounds = true
      
        let allExercises = WorkoutManager.shared.currentModule?.exercises ?? []

  exercises = WorkoutAlgorithmBuilder.generateDailyWorkout(from: allExercises) as! [Exercise]

        setupCloseButton()
        setupProgressBars()
      //  configureExercise()
        playerView.isUserInteractionEnabled = false
        configureExercise()
        //updateProgress(step: 1)
       // progressBar(step: 1)
        }

        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         
         */
    func updateProgress(step: Int) {
        
        stepLabel.text = "1 of 10"
    }
    
    func updateProgress() {
        for (index, bar) in progressBars.enumerated() {
               bar.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

               let dashedLayer = createDashedLayer(
                   color: index < currentIndex
                       ? UIColor.systemGreen.cgColor
                       : UIColor.lightGray.cgColor
               )
               bar.layer.addSublayer(dashedLayer)
               if index == currentIndex - 1 {
                   animateDash(layer: dashedLayer)
               }
        }
    }
    func animateDash(layer: CAShapeLayer) {
        let animation = CABasicAnimation(keyPath: "strokeColor")
        animation.fromValue = UIColor.lightGray.cgColor
        animation.toValue = UIColor.systemGreen.cgColor
        animation.duration = 0.4
        layer.add(animation, forKey: "colorChange")
    }
    func configureExercise() {
        guard currentIndex < exercises.count else { return }
           let exercise = exercises[currentIndex]

           // UI updates
           exerciseName.text = exercise.name
           repsLabel.text = "\(exercise.reps)"
           stepLabel.text = "\(currentIndex + 1) of \(exercises.count)"
           updateProgress()

           // 🟢 Load exercise-specific video
           playerView.load(
            withVideoId: exercise.videoID ?? "",
               playerVars: [
                   "controls": 0,
                   "modestbranding": 1,
                   "playsinline": 1,
                   "rel": 0,
                   "fs": 0,
                   "iv_load_policy": 3,
                   "disablekb": 1,
                   "showinfo": 0,
                   "autoplay": 1
               ]
           )

           starttimer()
      
    }
    func starttimer() {
        totalTime = 60 // Reset to 60 if needed
           timerLabel.text = "\(totalTime)"
           
           timer = Timer.scheduledTimer(timeInterval: 1.0,
                                        target: self,
                                        selector: #selector(updateTimer),
                                        userInfo: nil,
                                        repeats: true)
    }
    @objc func updateTimer() {
        if totalTime > 0 {
            totalTime -= 1
            timerLabel.text = "\(totalTime)"
        } else {
            timer?.invalidate()
            timer = nil
            // You can also navigate to next screen or trigger any action
        }
    }

    func goToRestScreen() {
        if currentIndex < exercises.count - 1 {  // Not last exercise
            let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RestScreenViewController") as! RestScreenViewController
            
            vc.currentIndex = currentIndex
            vc.totalExercises = exercises.count
            vc.delegate = self

            navigationController?.pushViewController(vc, animated: true)
        } else {
            showWorkoutCompleted() // 🔹 Handle last screen
        }
    }
    
    func showWorkoutCompleted() {
        let alert = UIAlertController(
            title: "Workout Completed!",
            message: "Great job! You finished all exercises.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popToRootViewController(animated: true) // Or navigate to summary screen
        }))
        
        present(alert, animated: true)
    }
    func setupProgressBars() {
        progressStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        progressBars.removeAll()
        for _ in 0..<exercises.count {
            let dashView = UIView()
            dashView.translatesAutoresizingMaskIntoConstraints = false
            dashView.heightAnchor.constraint(equalToConstant: 6).isActive = true
            dashView.layer.addSublayer(createDashedLayer(color: UIColor.lightGray.cgColor))
            progressBars.append(dashView)
            progressStackView.addArrangedSubview(dashView)
        }
    }
    func createDashedLayer(color: CGColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.strokeColor = color
        layer.lineWidth = 6
        layer.lineDashPattern = [10, 6] // dash width, gap width
        layer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 40, height: 1)).cgPath
        return layer
    }
    @objc func closeButtonTapped() {
        let alert = UIAlertController(
               title: "Quit Workout?",
               message: "Are you sure you want to quit the workout?",
               preferredStyle: .alert
           )

           alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
               self.dismiss(animated: true) // or pop
           }))

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

           present(alert, animated: true)
    }
//    func navigateToNext() {
//        if currentIndex < exercises.count - 1 {
//            // Go to Rest Screen
//            let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "RestScreenViewController") as! RestScreenViewController
//            
//            vc.currentIndex = currentIndex
//            vc.totalExercises = exercises.count
//            vc.delegate = self
//            
//            navigationController?.pushViewController(vc, animated: true)
//        } else {
//            // Last exercise completed
//           // showWorkoutCompleted()
//        }
//    }
    func setupCloseButton() {
            // Use the system image for a consistent "close" icon
            let closeImage = UIImage(systemName: "xmark")
            
            let closeButton = UIBarButtonItem(
                image: closeImage,
                style: .plain,
                target: self,
                action: #selector(closeButtonTapped) // This calls the function below when tapped
            )
            
            navigationItem.leftBarButtonItem = closeButton
        }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        currentIndex += 1
     //   navigateToNext()
        goToRestScreen()

    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        goToRestScreen()

    }
     
}

extension _0minworkoutViewController: RestScreenDelegate {
    func restCompleted(nextIndex: Int) {
        currentIndex = nextIndex
        configureExercise()
        updateProgress()
    }
}
