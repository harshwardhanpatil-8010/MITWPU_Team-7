import UIKit

protocol CountdownDelegate: AnyObject {
    func countdownDidFinish()
    func countdownDidCancel()
}

protocol WorkoutDelegate: AnyObject {
    func workoutDidFinish(skipped: Bool, duration: TimeInterval)
    func workoutDidRequestPrevious()
    func workoutDidRequestQuitEarly()
}

protocol RestDelegate: AnyObject {
    func restDidFinish(duration: TimeInterval)
}

class WorkoutContainerViewController: UIViewController {
    
    let engine: WorkoutProgressionEngine
    var totalWorkoutSeconds: TimeInterval = 0
    private var activeChildVC: UIViewController?
    private var lastObservedPhase: WorkoutPhase
    
    init(engine: WorkoutProgressionEngine) {
        self.engine = engine
        self.lastObservedPhase = engine.phase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        advanceToNextPhaseOrExercise(showCountdown: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func advanceToNextPhaseOrExercise(showCountdown: Bool) {
        let currentPhase = engine.phase
        
        if currentPhase == .revisiting && lastObservedPhase == .main {
            lastObservedPhase = .revisiting
            showRevisitPrompt()
            return
        }
        
        lastObservedPhase = currentPhase
        
        switch currentPhase {
        case .completed:
            showCompletion()
        case .main, .revisiting:
            guard engine.currentExercise != nil else {
                showCompletion()
                return
            }
            if showCountdown {
                showCountdownScreen()
            } else {
                showActiveWorkoutScreen()
            }
        }
    }
    
    private func showCountdownScreen() {
        let countdown = ExerciseCountdownViewController()
        countdown.engine = engine
        countdown.delegate = self
        swapTo(child: countdown, transitionType: .pushFromRight)
    }
    
    private func showActiveWorkoutScreen(pushFromLeft: Bool = false) {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutViewController") as? _0minworkoutViewController {
            vc.engine = engine
            vc.delegate = self
            swapTo(child: vc, transitionType: pushFromLeft ? .pushFromLeft : .crossDissolve)
        }
    }
    
    private func showRestScreen() {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "RestScreenViewController") as? RestScreenViewController {
            vc.engine = engine
            vc.delegate = self
            swapTo(child: vc, transitionType: .crossDissolve)
        }
    }
    
    private func showRevisitPrompt() {
        let alert = UIAlertController(
            title: "Skipped Exercises",
            message: "Would you like to try the exercises you skipped?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Maybe later", style: .cancel) { [weak self] _ in
            self?.engine.forceComplete()
            self?.advanceToNextPhaseOrExercise(showCountdown: false)
        })
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.advanceToNextPhaseOrExercise(showCountdown: true)
        })
        present(alert, animated: true)
    }
    
    private func showCompletion() {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "GoodJobViewController") as? _0minworkoutGoodJobViewController {
            vc.completed = WorkoutManager.shared.completedToday.count
            vc.totalWorkoutSeconds = self.totalWorkoutSeconds
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    enum TransitionType {
        case crossDissolve
        case pushFromRight
        case pushFromLeft
    }
    
    private func swapTo(child newChild: UIViewController, transitionType: TransitionType) {
        newChild.willMove(toParent: self)
        addChild(newChild)
        newChild.view.frame = view.bounds
        newChild.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let oldChild = activeChildVC {
            oldChild.willMove(toParent: nil)
            
            let transitionDuration: TimeInterval = 0.4
            
            switch transitionType {
            case .crossDissolve:
                transition(from: oldChild, to: newChild, duration: transitionDuration, options: .transitionCrossDissolve, animations: nil) { _ in
                    oldChild.removeFromParent()
                    newChild.didMove(toParent: self)
                    self.activeChildVC = newChild
                }
            case .pushFromRight:
                newChild.view.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
                view.addSubview(newChild.view)
                UIView.animate(withDuration: transitionDuration, delay: 0, options: .curveEaseInOut, animations: {
                    newChild.view.transform = .identity
                    oldChild.view.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
                }) { _ in
                    oldChild.view.transform = .identity
                    oldChild.view.removeFromSuperview()
                    oldChild.removeFromParent()
                    newChild.didMove(toParent: self)
                    self.activeChildVC = newChild
                }
            case .pushFromLeft:
                newChild.view.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
                view.addSubview(newChild.view)
                UIView.animate(withDuration: transitionDuration, delay: 0, options: .curveEaseInOut, animations: {
                    newChild.view.transform = .identity
                    oldChild.view.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
                }) { _ in
                    oldChild.view.transform = .identity
                    oldChild.view.removeFromSuperview()
                    oldChild.removeFromParent()
                    newChild.didMove(toParent: self)
                    self.activeChildVC = newChild
                }
            }
        } else {
            view.addSubview(newChild.view)
            newChild.didMove(toParent: self)
            activeChildVC = newChild
        }
    }
}

extension WorkoutContainerViewController: CountdownDelegate {
    func countdownDidFinish() {
        showActiveWorkoutScreen()
    }
    
    func countdownDidCancel() {
        navigationController?.popViewController(animated: true)
    }
}

extension WorkoutContainerViewController: WorkoutDelegate {
    func workoutDidFinish(skipped: Bool, duration: TimeInterval) {
        totalWorkoutSeconds += duration
        engine.markCurrent(skipped: skipped)
        
        if engine.phase == .completed {
            showCompletion()
        } else if engine.phase == .revisiting && lastObservedPhase == .main {
            advanceToNextPhaseOrExercise(showCountdown: false)
        } else {
            showRestScreen()
        }
    }
    
    func workoutDidRequestPrevious() {
        engine.goPrevious()
        showActiveWorkoutScreen(pushFromLeft: true)
    }
    
    func workoutDidRequestQuitEarly() {
        engine.quitEarlyAndModifyRemaining()
        navigationController?.popViewController(animated: true)
    }
}

extension WorkoutContainerViewController: RestDelegate {
    func restDidFinish(duration: TimeInterval) {
        totalWorkoutSeconds += duration
        advanceToNextPhaseOrExercise(showCountdown: true)
    }
}
