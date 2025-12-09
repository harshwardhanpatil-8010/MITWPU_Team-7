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
    
    var completedExerciseIDs: [UUID] = []
    var skippedExerciseIDs: [UUID] = []
    var timer: Timer?
    var totalTime = 60
    var currentIndex: Int = 0
    var exercises: [Exercise] = WorkoutManager.shared.getTodayWorkout()
    var progressBars: [UIView] = []
    var shouldLoadExercise = true
    var hasLoadedFirstExercise = false
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 35
        backgroundView.clipsToBounds = true
        setupCloseButton()
        setupProgressBars()
        playerView.isUserInteractionEnabled = false
        }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews( )
        setupProgressBars()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasLoadedFirstExercise {
            hasLoadedFirstExercise = true
            configureExercise()
            return
        }
        
    }

    func updateProgress(step: Int) {
        stepLabel.text = "1 of 10"
    }
    
    func updateProgressBars() {
        for (index, bar) in progressBars.enumerated() {
            bar.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            let color: UIColor = index < currentIndex ? .systemBlue : .lightGray
            let dashed = dashedLayer(for: bar, color: color)
            bar.layer.addSublayer(dashed)
        }
    }
    func dashedLayer(for view: UIView, color: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.strokeColor = color.cgColor
        layer.lineWidth = 4
        layer.lineDashPattern = [8, 6]
        let path = UIBezierPath()
        let midY = view.bounds.height / 2
        path.move(to: CGPoint(x: 0, y: midY))
        path.addLine(to: CGPoint(x: view.bounds.width, y: midY))
        layer.path = path.cgPath
        return layer
    }


    func animateBar(at index: Int) {
        guard index < progressBars.count else { return }
        
        let bar = progressBars[index]
        if let layer = bar.layer.sublayers?.first as? CAShapeLayer {
            let animation = CABasicAnimation(keyPath: "strokeColor")
            animation.fromValue = UIColor.lightGray.cgColor
            animation.toValue = UIColor.systemBlue.cgColor
            animation.duration = 0.45
            layer.add(animation, forKey: "colorAnim")
        }
    }

    func configureExercise() {
        guard !exercises.isEmpty else {
            showCompletion()
            return }
        guard currentIndex >= 0, currentIndex < exercises.count else {
            showCompletion()
            return }
        updateProgressBars()
        let exercise = exercises[currentIndex]
        exerciseName.text = exercise.name
        repsLabel.text = "\(exercise.reps)"
        stepLabel.text = "\(currentIndex + 1) of \(exercises.count)"
       
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
        timer?.invalidate()
        totalTime = 60
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
          
        }
    }

    func goToRestScreen() {
        if currentIndex < exercises.count - 1 {  // Not last exercise
            let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "RestScreenViewController") as! RestScreenViewController
            
            vc.currentIndex = currentIndex
            vc.totalExercises = exercises.count
            vc.delegate = self

            navigationController?.pushViewController(vc, animated: true)
        } else {
            showCompletion()
        }
    }
    
    func showCompletion() {
        let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GoodJobViewController") as! _0minworkoutGoodJobViewController
        
        vc.completed = WorkoutManager.shared.completedToday.count
        vc.skipped = WorkoutManager.shared.SkippedToday.count
        navigationController?.pushViewController(vc, animated: true)
    }
    func setupProgressBars() {
        progressStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        progressBars.removeAll()

        for _ in 0..<exercises.count {
            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.heightAnchor.constraint(equalToConstant: 12).isActive = true

            bar.backgroundColor = UIColor.systemGray6 
            bar.layer.cornerRadius = 6
            bar.clipsToBounds = true

            progressBars.append(bar)
            progressStackView.addArrangedSubview(bar)
        }


        view.layoutIfNeeded()   // ensures correct width before drawing dashed lines
        updateProgressBars()
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
        showQuitWorkoutAlert()
    }
    
    func setupCloseButton() {
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        navigationItem.leftBarButtonItem = closeButton
    }

    
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "InfoModalViewController") as! InfoModalViewController
        vc.currentIndex = currentIndex
        vc.exercises = exercises
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
    }
    
    
    
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard !exercises.isEmpty else {return}
        let exercise = exercises[currentIndex]
        if !WorkoutManager.shared.completedToday.contains(exercise.id) {
            WorkoutManager.shared.completedToday.append(exercise.id)
        }
       
        
        goToRestScreen()
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        guard !exercises.isEmpty else { return }
        let exercise = exercises[currentIndex]
        if !WorkoutManager.shared.SkippedToday.contains(exercise.id) {
            WorkoutManager.shared.SkippedToday.append(exercise.id)
        }
        goToRestScreen()
    }
}

extension _0minworkoutViewController: RestScreenDelegate {
    func restCompleted(nextIndex: Int) {
        if nextIndex < exercises.count {
            currentIndex = nextIndex
            configureExercise()
        } else {
            showCompletion()
        }
    }
}
