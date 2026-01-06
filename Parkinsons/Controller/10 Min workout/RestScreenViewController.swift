

import UIKit
import YouTubeiOSPlayerHelper

protocol RestScreenDelegate: AnyObject {
    func recordRestDuration(seconds: TimeInterval)
    func restCompleted(nextIndex: Int)
}

class RestScreenViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var breatheView: UIView!
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet var progressBars: [UIProgressView]!
    @IBOutlet weak var backgroundView: UIView!
    
    weak var delegate: RestScreenDelegate?
    var currentIndex: Int = 0
    var totalExercises: Int = 0
    var totalTime = 60
    var restStartTime: Date?
    private var isCompleting = false

    private func setupBreathGuide() {
        breatheView.layer.cornerRadius = 75
        breatheView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        UIView.animate(withDuration: 4.0, delay: 0, options: [.repeat, .autoreverse], animations: { [self] in
            breatheView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            breatheView.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.4)
        }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 35
        backgroundView.clipsToBounds = true
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 0.2
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 1)
        backgroundView.layer.shadowRadius = 3
        backgroundView.layer.masksToBounds = false
        setupUI()
        setupBreathGuide()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            self?.tick(t)
        }
    }

    private func setupUI() {
        let completedCount = WorkoutManager.shared.completedToday.count
        exerciseLabel.text = "\(completedCount) of \(totalExercises)"
        restStartTime = Date()
        updateProgressBars()
    }

    private func updateProgressBars() {
        guard progressBars != nil else { return }
        let sortedBars = progressBars.sorted { $0.frame.origin.x < $1.frame.origin.x }
        
        let allExercises = WorkoutManager.shared.exercises
        
        for (index, bar) in sortedBars.enumerated() {
            if index < allExercises.count {
                let exerciseID = allExercises[index].id
                
                // Priority 1: Was it completed?
                if WorkoutManager.shared.completedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemBlue
                }
                // Priority 2: Was it skipped?
                else if WorkoutManager.shared.SkippedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemGray4
                }
                // Priority 3: Is this the exercise we are currently resting AFTER?
                // In your flow, if you just finished exercise 0, currentIndex is 0.
                else if index == currentIndex {
                    bar.progress = 1.0
                    bar.progressTintColor = UIColor.systemBlue.withAlphaComponent(0.3)
                }
                // Priority 4: Future exercises
                else {
                    bar.progress = 0.0
                    bar.trackTintColor = .systemGray5
                }
            }
        }
    }

    private func tick(_ t: Timer) {
        if totalTime > 0 {
            totalTime -= 1
            timerLabel.text = "\(totalTime)"
        } else {
            t.invalidate()
            finishRest()
        }
    }
    

    @IBAction func skipButtonTapped(_ sender: Any) {
        finishRest()
    }

    private func finishRest() {
        guard !isCompleting else { return }
        isCompleting = true
        
        // 1. Tell the delegate to update the index
        delegate?.restCompleted(nextIndex: currentIndex + 1)
       
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = .push
        transition.subtype = .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        navigationController?.popViewController(animated: false)
    }
    @IBAction func addTimeButtonTapped(_ sender: UIButton) {
        totalTime += 20
        updateTimerLabel()
    }
    func updateTimerLabel() {
            timerLabel.text = "\(totalTime)"
       }
}
