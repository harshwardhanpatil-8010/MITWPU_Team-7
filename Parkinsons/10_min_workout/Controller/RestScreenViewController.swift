import UIKit

class RestScreenViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var breatheView: UIView!
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet var progressBars: [UIProgressView]!
    @IBOutlet weak var backgroundView: UIView!
    
    weak var delegate: RestDelegate?
    weak var engine: WorkoutProgressionEngine?

    private var restStartTime: Date?
    private var targetDate: Date?
    private var currentDisplayTime: Int = 60
    
    private var isCompleting = false
    private var restTimer: Timer?

    private func setupBreathGuide() {
        breatheView.layer.cornerRadius = 75
        breatheView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        UIView.animate(withDuration: 4.0, delay: 0, options: [.repeat, .autoreverse], animations: { [weak self] in
            self?.breatheView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self?.breatheView.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.4)
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        isCompleting = false
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
        
        restStartTime = Date()
        targetDate = Date().addingTimeInterval(60)
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tickCountdown()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restTimer?.invalidate()
        restTimer = nil
    }

    private func setupUI() {
        guard let engine = engine else { return }
        let completedCount = WorkoutManager.shared.completedToday.count
        exerciseLabel.text = "\(completedCount) of \(engine.allExercises.count)"
        updateProgressBars()
    }

    private func updateProgressBars() {
        guard progressBars != nil, let engine = engine else { return }
        let sortedBars = progressBars.sorted { $0.frame.origin.x < $1.frame.origin.x }

        for (index, bar) in sortedBars.enumerated() {
            if index < engine.allExercises.count {
                let exerciseID = engine.allExercises[index].id

                if WorkoutManager.shared.completedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemBlue
                } else if WorkoutManager.shared.skippedToday.contains(exerciseID) {
                    bar.progress = 1.0
                    bar.progressTintColor = .systemGray4
                } else if index == engine.currentIndexInGlobalArray {
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

    private func tickCountdown() {
        guard let target = targetDate else { return }
        let remaining = Int(ceil(target.timeIntervalSinceNow))
        
        if remaining <= 0 {
            restTimer?.invalidate()
            restTimer = nil
            timerLabel.text = "0"
            finishRest()
            return
        }
        
        if remaining != currentDisplayTime {
            currentDisplayTime = remaining
            timerLabel.text = "\(currentDisplayTime)"
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

        let duration = restStartTime.map { Date().timeIntervalSince($0) } ?? 0
        delegate?.restDidFinish(duration: duration)
    }

    @IBAction func addTimeButtonTapped(_ sender: UIButton) {
        targetDate = targetDate?.addingTimeInterval(20)
        tickCountdown()
    }
}
