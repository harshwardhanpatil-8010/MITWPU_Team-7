
//
//
//import UIKit
//
//
//protocol RestScreenDelegate: AnyObject {
//    func recordRestDuration(seconds: TimeInterval)
//    func restCompleted()
//}
//
//
//class RestScreenViewController: UIViewController {
//    
//    @IBOutlet weak var timerLabel: UILabel!
//    @IBOutlet weak var breatheView: UIView!
//    @IBOutlet weak var exerciseLabel: UILabel!
//    @IBOutlet var progressBars: [UIProgressView]!
//    @IBOutlet weak var backgroundView: UIView!
//    
//    weak var delegate: RestScreenDelegate?
//    var currentIndex: Int = 0
//    var totalExercises: Int = 0
//    var totalTime = 60
//    var restStartTime: Date?
//    private var isCompleting = false
//    private var restTimer: Timer?
//
//    private func setupBreathGuide() {
//        breatheView.layer.cornerRadius = 75
//        breatheView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
//        UIView.animate(withDuration: 4.0, delay: 0, options: [.repeat, .autoreverse], animations: { [self] in
//            breatheView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//            breatheView.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.4)
//        }, completion: nil)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tabBarController?.tabBar.isHidden = true
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        backgroundView.layer.cornerRadius = 35
//        backgroundView.clipsToBounds = true
//        backgroundView.layer.shadowColor = UIColor.black.cgColor
//        backgroundView.layer.shadowOpacity = 0.2
//        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 1)
//        backgroundView.layer.shadowRadius = 3
//        backgroundView.layer.masksToBounds = false
//        setupUI()
//        setupBreathGuide()
//        
//        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
//            self?.tick(t)
//        }
//
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        restTimer?.invalidate()
//        restTimer = nil
//    }
//
//
//    private func setupUI() {
//        let completedCount = WorkoutManager.shared.completedToday.count
//        exerciseLabel.text = "\(completedCount) of \(totalExercises)"
//        restStartTime = Date()
//        updateProgressBars()
//    }
//
//    private func updateProgressBars() {
//        guard progressBars != nil else { return }
//        let sortedBars = progressBars.sorted { $0.frame.origin.x < $1.frame.origin.x }
//        
//        let allExercises = WorkoutManager.shared.exercises
//        
//        for (index, bar) in sortedBars.enumerated() {
//            if index < allExercises.count {
//                let exerciseID = allExercises[index].id
//                
//                if WorkoutManager.shared.completedToday.contains(exerciseID) {
//                    bar.progress = 1.0
//                    bar.progressTintColor = .systemBlue
//                }
//                else if WorkoutManager.shared.skippedToday.contains(exerciseID) {
//                    bar.progress = 1.0
//                    bar.progressTintColor = .systemGray4
//                }
//                
//                else if index == currentIndex {
//                    bar.progress = 1.0
//                    bar.progressTintColor = UIColor.systemBlue.withAlphaComponent(0.3)
//                }
//  
//                else {
//                    bar.progress = 0.0
//                    bar.trackTintColor = .systemGray5
//                }
//            }
//        }
//    }
//
//    private func tick(_ t: Timer) {
//        if totalTime > 0 {
//            totalTime -= 1
//            timerLabel.text = "\(totalTime)"
//        } else {
//            t.invalidate()
//            finishRest()
//        }
//    }
//    
//
//    @IBAction func skipButtonTapped(_ sender: Any) {
//        finishRest()
//    }
//
//    private func finishRest() {
//        guard !isCompleting else { return }
//        isCompleting = true
//        restTimer?.invalidate()
//        restTimer = nil
//        
//        let transition = CATransition()
//        transition.duration = 0.4
//        transition.type = .push
//        transition.subtype = .fromRight
//        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        navigationController?.view.layer.add(transition, forKey: kCATransition)
//        navigationController?.popViewController(animated: false)
//
//        DispatchQueue.main.async {
//            self.delegate?.restCompleted()
//        }
//    }
//
//
//    @IBAction func addTimeButtonTapped(_ sender: UIButton) {
//        totalTime += 20
//        updateTimerLabel()
//    }
//    func updateTimerLabel() {
//            timerLabel.text = "\(totalTime)"
//       }
//}



import UIKit
protocol RestScreenDelegate: AnyObject {
    func recordRestDuration(seconds: TimeInterval)
    func restCompleted(exercises: [WorkoutExercise], nextIndex: Int)
    /// Called when rest finishes but there are no more exercises to show —
    /// the workout VC should handle completion / skipped-exercise logic itself.
    func restCompletedWorkoutDone()
}
class RestScreenViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var breatheView: UIView!
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet var progressBars: [UIProgressView]!
    @IBOutlet weak var backgroundView: UIView!
    
    weak var delegate: RestScreenDelegate?

    var currentIndex: Int = 0        // already-incremented index of the NEXT exercise

    var totalExercises: Int = 0
    var exercises: [WorkoutExercise] = []
    var totalTime = 60
    var restStartTime: Date?
    private var isCompleting = false
    private var restTimer: Timer?

    private func setupBreathGuide() {
        breatheView.layer.cornerRadius = 75
        breatheView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        UIView.animate(withDuration: 4.0, delay: 0, options: [.repeat, .autoreverse], animations: { [self] in
            breatheView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            breatheView.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.4)
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
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
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            self?.tick(t)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restTimer?.invalidate()
        restTimer = nil
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

                if WorkoutManager.shared.completedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemBlue
                } else if WorkoutManager.shared.skippedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemGray4

                } else if index == currentIndex {

                    bar.progress = 1.0
                    bar.progressTintColor = UIColor.systemBlue.withAlphaComponent(0.3)
                } else {
                    bar.progress = 0.0
                    bar.progressTintColor = .systemBlue
                }
                bar.trackTintColor = .systemGray5
                bar.isHidden = false
            } else {
                bar.isHidden = true
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
        restTimer?.invalidate()
        restTimer = nil

        // Notify delegate to record rest duration first
        delegate?.recordRestDuration(seconds: restStartTime.map { Date().timeIntervalSince($0) } ?? 0)

        // If there are no more exercises, hand control back to the workout VC
        // so it can handle skipped-exercise prompts and the Good Job screen.
        guard currentIndex < exercises.count else {
            // Pop back to the workout VC and let it call checkForSkippedExercises
            navigationController?.popViewController(animated: false)
            DispatchQueue.main.async {
                self.delegate?.restCompletedWorkoutDone()
            }
            return
        }

        // There IS a next exercise — push the countdown screen
        let countdown = ExerciseCountdownViewController()
        countdown.exercises     = exercises
        countdown.startingIndex = currentIndex

        let transition = CATransition()
        transition.duration = 0.4
        transition.type = .push
        transition.subtype = .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(countdown, animated: false)

        DispatchQueue.main.async {
            self.delegate?.restCompleted(exercises: self.exercises, nextIndex: self.currentIndex)
        }
    }

    @IBAction func addTimeButtonTapped(_ sender: UIButton) {
        totalTime += 20
        timerLabel.text = "\(totalTime)"
    }
}
