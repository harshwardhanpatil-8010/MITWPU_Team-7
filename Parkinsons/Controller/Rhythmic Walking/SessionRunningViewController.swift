//
//  SessionRunningViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class SessionRunningViewController: UIViewController {

    
    @IBOutlet weak var circularContainer: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var beatButton: UIButton!
    @IBOutlet weak var paceButton: UIButton!
    @IBOutlet weak var beatPaceUIView: UIView!
    
    var totalSessionDuration: Int = 0
    var selectedBeat: String?
    var selectedPace: String?
    var selectedBPM: Int?
    var hrs: Int = 0
    var minn: Int = 0
    
    private var progressView: CircularProgressView!
    private var timerModel: TimerModel!
    
    var session: RhythmicSession?
    
    private func setupProgressView() {
        progressView = CircularProgressView(frame: circularContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        circularContainer.addSubview(progressView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        progressView.progressColor = UIColor(hex: "90AF81")
        progressView.trackColor = .systemGray5
        beatButton.titleLabel?.text = selectedBeat
        paceButton.titleLabel?.text = selectedPace
        beatPaceUIView.applyCardStyle()
        setupBeatButton()
        setupPaceButton()
        
//        guard let beat = selectedBeat, let bpm = selectedBPM else { return }
        
        if totalSessionDuration > 0{
            timerModel = TimerModel(totalSeconds: totalSessionDuration)
            updateDisplay( hours:hrs, minutes: minn)
        }
        else {
            timerModel = TimerModel(totalSeconds: 1)
            updateDisplay( hours:0, minutes:0)
        }
        timerModel.delegate = self
        if totalSessionDuration > 0{
            timerModel.start()
        }
//        BeatPlayer.shared.startBeat(fileName: beat, bpm: bpm)
        updatePauseButtonUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BeatPlayer.shared.stopBeat()
    }
    
    
    private func updateDisplay(hours: Int, minutes: Int) {
        timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, 0)
        progressView.setProgress(1.0)
    }
    
    @IBAction func pauseTapped(_ sender: Any) {
        guard let timerModel = timerModel else { return }
        if timerModel.isPaused {
            timerModel.resume()
            BeatPlayer.shared.resumeBeat()
        } else {
            timerModel.pause()
            BeatPlayer.shared.pauseBeat()
        }
        updatePauseButtonUI()
    }
        
    private func updatePauseButtonUI() {
        let title: String
        if let timerModel = timerModel {
            title = timerModel.isPaused ? "Resume" : "Pause"
        } else {
            title = "Pause"
        }
        pauseButton.setTitle(title, for: .normal)
    }
        
    func setupBeatButton(){
        beatButton.setTitle(selectedBeat ?? "Clock", for: .normal)
        let optionClosure: UIActionHandler = { [weak self] action in
                _ = self
        }
        let option1 = UIAction(title: "Clock", state: selectedBeat == "Clock" ? .on : .off, handler: optionClosure)
        let option2 = UIAction(title: "Grass", state: selectedBeat == "Grass" ? .on : .off, handler: optionClosure)
        let menu  = UIMenu(children: [option1, option2])
        beatButton.menu = menu
        beatButton.showsMenuAsPrimaryAction = true
        beatButton.changesSelectionAsPrimaryAction = true
    }
    
    func setupPaceButton(){
        paceButton.setTitle(selectedPace ?? "slow", for: .normal)
        let optionClosure: UIActionHandler = { [weak self] action in
                _ = self
        }
        let option1 = UIAction(title: "Slow", state: selectedPace == "Slow" ? .on : .off, handler: optionClosure)
        let option2 = UIAction(title: "Moderate", state: selectedPace == "Moderate" ? .on : .off, handler: optionClosure)
        let option3 = UIAction(title: "Fast", state: selectedPace == "Fast" ? .on : .off, handler: optionClosure)
        let menu  = UIMenu(children: [option1, option2, option3])
        paceButton.menu = menu
        paceButton.showsMenuAsPrimaryAction = true
        paceButton.changesSelectionAsPrimaryAction = true
    }
    func presentSummaryAndDismiss() {
        
        // 1. Get the original view controller (SetGoalViewController) that presented this modal.
        // This is the anchor point for finding the navigation stack.
        guard let presentingVC = self.presentingViewController else {
            print("Error: Presenting view controller not found.")
            return
        }

        // 2. Instantiate the next aView Controller (SessionSummaryViewController)
        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil) // Update "Main" to your actual Storyboard name
        guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SessionSummaryVC") as? SessionSummaryViewController else {
            print("Error: Could not instantiate SessionSummaryViewController.")
            return
        }
        summaryVC.sessionData = session
        
        // *** CRITICAL STEP ***
        // 3. Find the target navigation stack to push onto.
        // This is the navigation controller that *contains* the SetGoalVC.
        guard let targetNav = presentingVC.navigationController else {
            // Fallback if presentingVC is somehow not in a navigation stack.
            // If this happens, you must present the SummaryVC modally instead of pushing.
            print("Error: Presenting VC is not embedded in a UINavigationController. Presenting modally as a fallback.")
//            summaryVC.modalPresentationStyle = .fullScreen
            self.dismiss(animated: true) {
                presentingVC.present(summaryVC, animated: true)
            }
            return
        }

        // 4. Dismiss the current modal view controller (SessionRunningVC)
        self.dismiss(animated: true) {
            // This block executes ONLY AFTER the modal dismissal animation completes.
            
            // 5. Push the Session Summary View Controller onto the original stack
            // This will show a standard push animation (slide from right).
            targetNav.pushViewController(summaryVC, animated: true)
        }
    }
    
    @IBAction func endSessionButtonTapped(_ sender: Any) {
        guard var session = DataStore.shared.sessions.first else{
            presentSummaryAndDismiss()
            return
        }
        let parts = timeLabel.text?.split(separator: ":") ?? ["0", "0", "0"]
        let h = Int(parts[0]) ?? 0
        let m = Int(parts[1]) ?? 0
        let s = Int(parts[2]) ?? 0
        let timeLeft = (h * 3600) + (m * 60) + s
        let elapsedSeconds = session.requestedDurationSeconds - timeLeft
        session.endDate = Date()
        session.elapsedSeconds = elapsedSeconds
        
        DataStore.shared.update(session)
        
        self.session = session
        presentSummaryAndDismiss()
    }
    
    
}

extension SessionRunningViewController: TimerModelDelegate {
        
    func timerDidUpdate(timeLeft: Int, progress: CGFloat) {
        let hours = timeLeft / 3600
        let minutes = (timeLeft % 3600) / 60
        let seconds = timeLeft % 60
        
        timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        progressView.setProgress(progress)
    }
    
    func timerDidFinish() {
        timeLabel.text = " 00:00:00 "
        progressView.setProgress(0)
        pauseButton.isEnabled = false
        presentSummaryAndDismiss()
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
