//////
//////  SessionRunningViewController.swift
//////  Parkinson's App
//////
//////  Created by SDC-USER on 25/11/25.
//////
////
////import UIKit
////
////class SessionRunningViewController: UIViewController {
////
////    
////    @IBOutlet weak var circularContainer: UIView!
////    @IBOutlet weak var timeLabel: UILabel!
////    @IBOutlet weak var pauseButton: UIButton!
////    @IBOutlet weak var beatButton: UIButton!
////    @IBOutlet weak var paceButton: UIButton!
////    @IBOutlet weak var beatPaceUIView: UIView!
////    
////    
////    
////    var totalSessionDuration: Int = 0
////    var selectedBeat: String?
////    var selectedPace: String?
////    var selectedBPM: Int?
////    var hrs: Int = 0
////    var minn: Int = 0
////    
////    private var progressView: CircularProgressView!
////    private var timerModel: TimerModel!
////    
////    var session: RhythmicSession?
////    
////    private func setupProgressView() {
////        progressView = CircularProgressView(frame: circularContainer.bounds)
////        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        circularContainer.addSubview(progressView)
////        progressView.progressColor = UIColor(hex: "90AF81")
////        progressView.trackColor = UIColor(hex: "90AF81")
////        
////
////    }
//////    private func updateDisplay(hours: Int, minutes: Int) {
//////        timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, 0)
//////        progressView.setProgress(1.0)
//////    }
////    
////    
////    private func updateDisplay(hours: Int, minutes: Int) {
////        timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, 0)
////        progressView.setProgress(1.0) // Start full for brand new sessions
////    }
////    
////    private func updatePauseButtonUI() {
////        let title: String
////        if let timerModel = timerModel {
////            title = timerModel.isPaused ? "Resume" : "Pause"
////        } else {
////            title = "Pause"
////        }
////        pauseButton.setTitle(title, for: .normal)
////    }
////    
////    
////    
////    
//////    override func viewDidLoad() {
//////        super.viewDidLoad()
//////        title = "Rhythmic Walking"
//////
//////        isModalInPresentation = true
//////
//////        
//////        setupProgressView()
//////        beatButton.titleLabel?.text = selectedBeat
//////        paceButton.titleLabel?.text = selectedPace
//////        beatPaceUIView.applyCardStyle()
//////        setupBeatButton()
//////        setupPaceButton()
//////   
//////        if totalSessionDuration > 0{
//////            timerModel = TimerModel(totalSeconds: totalSessionDuration)
//////            updateDisplay( hours:hrs, minutes: minn)
//////        }
//////        else {
//////            timerModel = TimerModel(totalSeconds: 1)
//////            updateDisplay( hours:0, minutes:0)
//////        }
//////        timerModel.delegate = self
//////        if totalSessionDuration > 0{
//////            timerModel.start()
//////        }
//////        updatePauseButtonUI()
//////    }
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        title = "Rhythmic Walking"
////        isModalInPresentation = true
////        
////        setupProgressView()
////        
////        beatButton.setTitle(selectedBeat, for: .normal)
////        paceButton.setTitle(selectedPace, for: .normal)
////        beatPaceUIView.applyCardStyle()
////        setupBeatButton()
////        setupPaceButton()
////        
////        if let existingSession = session {
////            let timeLeft = existingSession.requestedDurationSeconds - existingSession.elapsedSeconds
////            timerModel = TimerModel(totalSeconds: timeLeft)
////            let initialProgress = CGFloat(timeLeft) / CGFloat(existingSession.requestedDurationSeconds)
////            
////            let h = timeLeft / 3600
////            let m = (timeLeft % 3600) / 60
////            let s = timeLeft % 60
////            timeLabel.text = String(format: "%02d:%02d:%02d", h, m, s)
////            progressView.setProgress(initialProgress)
////            
////        } else if totalSessionDuration > 0 {
////            timerModel = TimerModel(totalSeconds: totalSessionDuration)
////            updateDisplay(hours: hrs, minutes: minn)
////        } else {
////            timerModel = TimerModel(totalSeconds: 1)
////            updateDisplay(hours: 0, minutes: 0)
////        }
////        
////        timerModel.delegate = self
////        
////        if totalSessionDuration > 0 || (session != nil) {
////            timerModel.start()
////        }
////        
////        updatePauseButtonUI()
////    }
////    
////    override func viewWillDisappear(_ animated: Bool) {
////        super.viewWillDisappear(animated)
////    }
////
////    override func viewWillAppear(_ animated: Bool) {
////        super.viewWillAppear(animated)
////        tabBarController?.tabBar.isHidden = true
////    }
////
//// 
////    
////    @IBAction func pauseTapped(_ sender: Any) {
////        guard let timerModel = timerModel else { return }
////        if timerModel.isPaused {
////            timerModel.resume()
////        } else {
////            timerModel.pause()
////        }
////        updatePauseButtonUI()
////    }
////   
////    func setupBeatButton(){
////        beatButton.setTitle(selectedBeat ?? "Clock", for: .normal)
////        let optionClosure: UIActionHandler = { [weak self] action in
////                _ = self
////        }
////        let option1 = UIAction(title: "Clock", state: selectedBeat == "Clock" ? .on : .off, handler: optionClosure)
////        let option2 = UIAction(title: "Grass", state: selectedBeat == "Grass" ? .on : .off, handler: optionClosure)
////        let menu  = UIMenu(children: [option1, option2])
////        beatButton.menu = menu
////        beatButton.showsMenuAsPrimaryAction = true
////        beatButton.changesSelectionAsPrimaryAction = true
////    }
////    
////    func setupPaceButton(){
////        paceButton.setTitle(selectedPace ?? "slow", for: .normal)
////        let optionClosure: UIActionHandler = { [weak self] action in
////                _ = self
////        }
////        let option1 = UIAction(title: "Slow", state: selectedPace == "Slow" ? .on : .off, handler: optionClosure)
////        let option2 = UIAction(title: "Moderate", state: selectedPace == "Moderate" ? .on : .off, handler: optionClosure)
////        let option3 = UIAction(title: "Fast", state: selectedPace == "Fast" ? .on : .off, handler: optionClosure)
////        let menu  = UIMenu(children: [option1, option2, option3])
////        paceButton.menu = menu
////        paceButton.showsMenuAsPrimaryAction = true
////        paceButton.changesSelectionAsPrimaryAction = true
////    }
////    func presentSummaryAndDismiss() {
////
////        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
////        guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SessionSummaryVC") as? SessionSummaryViewController else {
////            return
////        }
////        summaryVC.sessionData = session
////        navigationController?.pushViewController(summaryVC, animated: true)
////        
////    }
////    
////    @IBAction func endSessionButtonTapped(_ sender: Any) {
////        guard var session = DataStore.shared.sessions.first else{
////            presentSummaryAndDismiss()
////            return
////        }
////        let parts = timeLabel.text?.split(separator: ":") ?? ["0", "0", "0"]
////        let h = Int(parts[0]) ?? 0
////        let m = Int(parts[1]) ?? 0
////        let s = Int(parts[2]) ?? 0
////        let timeLeft = (h * 3600) + (m * 60) + s
////        let elapsedSeconds = session.requestedDurationSeconds - timeLeft
////        session.endDate = Date()
////        session.elapsedSeconds = elapsedSeconds
////        
////        DataStore.shared.update(session)
////        
////        self.session = session
////        presentSummaryAndDismiss()
////    }
////}
////
////
////
////
////extension SessionRunningViewController: TimerModelDelegate {
////    
////    func timerDidUpdate(timeLeft: Int, progress: CGFloat) {
////        let hours = timeLeft / 3600
////        let minutes = (timeLeft % 3600) / 60
////        let seconds = timeLeft % 60
////        
////        timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
////        
////        progressView.setProgress(progress)
////    }
////    
////    func timerDidFinish() {
////        timeLabel.text = "00:00:00"
////        progressView.setProgress(0)
////        pauseButton.isEnabled = false
////        presentSummaryAndDismiss()
////    }
////}
////    /*
////    // MARK: - Navigation
////
////    // In a storyboard-based application, you will often want to do a little preparation before navigation
////    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
////        // Get the new view controller using segue.destination.
////        // Pass the selected object to the new view controller.
////    }
////    */
//
//
//
//
//
//
//// after review changes
////
////import UIKit
////
////class SessionRunningViewController: UIViewController {
////
////    @IBOutlet weak var circularContainer: UIView!
////    @IBOutlet weak var timeLabel: UILabel!
////    @IBOutlet weak var pauseButton: UIButton!
////    @IBOutlet weak var beatButton: UIButton!
////    @IBOutlet weak var paceButton: UIButton!
////    @IBOutlet weak var beatPaceUIView: UIView!
////    
////    var totalSessionDuration: Int = 0
////    var selectedBeat: String?
////    var selectedPace: String?
////    var selectedBPM: Int?
////    var hrs: Int = 0
////    var minn: Int = 0
////    
////    private var progressView: CircularProgressView!
////    private var timerModel: TimerModel!
////    var session: RhythmicSessionDTO?
////    
////    private func setupProgressView() {
////        progressView = CircularProgressView(frame: circularContainer.bounds)
////        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        circularContainer.addSubview(progressView)
////        progressView.progressColor = UIColor(hex: "90AF81")
////        progressView.trackColor = UIColor(hex: "90AF81").withAlphaComponent(0.3)
////    }
////    
////    private func updateDisplay(seconds: Int) {
////        let h = seconds / 3600
////        let m = (seconds % 3600) / 60
////        let s = seconds % 60
////        timeLabel.text = String(format: "%02d:%02d:%02d", h, m, s)
////    }
////    
////    private func updatePauseButtonUI() {
////        let title = (timerModel?.isPaused ?? false) ? "Resume" : "Pause"
////        pauseButton.setTitle(title, for: .normal)
////    }
////    
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        title = "Rhythmic Walking"
////        isModalInPresentation = true
////        
////        setupProgressView()
////        self.selectedBPM = PaceConfig.bpm(for: selectedPace ?? "Slow")
////        
////        beatButton.setTitle(selectedBeat ?? "Clock", for: .normal)
////        paceButton.setTitle(selectedPace ?? "Slow", for: .normal)
////        beatPaceUIView.applyCardStyle()
////        setupBeatButton()
////        setupPaceButton()
////        
////        if let existingSession = session {
////            let originalTotal = existingSession.requestedDurationSeconds
////            let timeLeft = originalTotal - existingSession.elapsedSeconds
////            timerModel = TimerModel(totalSeconds: originalTotal, startWithTimeLeft: timeLeft)
////            
////            let initialProgress = CGFloat(timeLeft) / CGFloat(originalTotal)
////            updateDisplay(seconds: timeLeft)
////            progressView.setProgress(initialProgress)
////            
////        } else if totalSessionDuration > 0 {
////            timerModel = TimerModel(totalSeconds: totalSessionDuration)
////            updateDisplay(seconds: totalSessionDuration)
////            progressView.setProgress(1.0)
////        } else {
////            timerModel = TimerModel(totalSeconds: 1)
////            updateDisplay(seconds: 0)
////        }
////        
////        timerModel.delegate = self
////        timerModel.start()
////        
////        startAudio()
////        updatePauseButtonUI()
////    }
////    
////    override func viewWillAppear(_ animated: Bool) {
////        super.viewWillAppear(animated)
////        tabBarController?.tabBar.isHidden = true
////    }
////    private func startAudio() {
////            let beatFile = selectedBeat ?? "clock"
////            let bpm = selectedBPM ?? 100
////            RhythmicAudioManager.shared.playBeat(fileName: beatFile, bpm: bpm)
////        }
////    
//////    @IBAction func pauseTapped(_ sender: Any) {
//////        guard let timerModel = timerModel else { return }
//////        timerModel.isPaused ? timerModel.resume() : timerModel.pause()
//////        updatePauseButtonUI()
//////    }
////    @IBAction func pauseTapped(_ sender: Any) {
////            guard let timerModel = timerModel else { return }
////            if timerModel.isPaused {
////                timerModel.resume()
//////                RhythmicAudioManager.shared.resume()
////                
////            } else {
////                timerModel.pause()
//////                RhythmicAudioManager.shared.pause()
////                RhythmicAudioManager.shared.stop()
////            }
////            updatePauseButtonUI()
////        }
////    
//////    func setupBeatButton() {
//////        let optionClosure: UIActionHandler = { [weak self] action in
//////            self?.selectedBeat = action.title
//////        }
//////        let option1 = UIAction(title: "Clock", state: selectedBeat == "Clock" ? .on : .off, handler: optionClosure)
//////        let option2 = UIAction(title: "Grass", state: selectedBeat == "Grass" ? .on : .off, handler: optionClosure)
//////        beatButton.menu = UIMenu(children: [option1, option2])
//////        beatButton.showsMenuAsPrimaryAction = true
//////        beatButton.changesSelectionAsPrimaryAction = true
//////    }
////    
//////    func setupPaceButton() {
//////        let optionClosure: UIActionHandler = { [weak self] action in
//////            self?.selectedPace = action.title
//////        }
//////        let option1 = UIAction(title: "Slow", state: selectedPace == "Slow" ? .on : .off, handler: optionClosure)
//////        let option2 = UIAction(title: "Moderate", state: selectedPace == "Moderate" ? .on : .off, handler: optionClosure)
//////        let option3 = UIAction(title: "Fast", state: selectedPace == "Fast" ? .on : .off, handler: optionClosure)
//////        paceButton.menu = UIMenu(children: [option1, option2, option3])
//////        paceButton.showsMenuAsPrimaryAction = true
//////        paceButton.changesSelectionAsPrimaryAction = true
//////    }
////    func setupPaceButton() {
////        // Set the initial title
////        paceButton.setTitle(selectedPace ?? "Slow", for: .normal)
////        
////        let optionClosure: UIActionHandler = { [weak self] action in
////            guard let self = self else { return }
////            
////            // 1. Update the local variable
////            self.selectedPace = action.title
////            
////            // 2. Get the new BPM from your PaceConfig helper
////            let newBPM = PaceConfig.bpm(for: action.title)
////            self.selectedBPM = newBPM
////            
////            // 3. Restart the audio with the new BPM (only if not paused)
////            if !(self.timerModel?.isPaused ?? false) {
////                RhythmicAudioManager.shared.playBeat(fileName: self.selectedBeat ?? "Clock", bpm: newBPM)
////            }
////        }
////        
////        let option1 = UIAction(title: "Slow", state: selectedPace == "Slow" ? .on : .off, handler: optionClosure)
////        let option2 = UIAction(title: "Moderate", state: selectedPace == "Moderate" ? .on : .off, handler: optionClosure)
////        let option3 = UIAction(title: "Fast", state: selectedPace == "Fast" ? .on : .off, handler: optionClosure)
////        
////        paceButton.menu = UIMenu(children: [option1, option2, option3])
////        paceButton.showsMenuAsPrimaryAction = true
////        paceButton.changesSelectionAsPrimaryAction = true
////    }
////
////    func setupBeatButton() {
////        beatButton.setTitle(selectedBeat ?? "Clock", for: .normal)
////        
////        let optionClosure: UIActionHandler = { [weak self] action in
////            guard let self = self else { return }
////            
////            self.selectedBeat = action.title
////            
////            if !(self.timerModel?.isPaused ?? false) {
////                let currentBPM = self.selectedBPM ?? 100
////                RhythmicAudioManager.shared.playBeat(fileName: action.title, bpm: currentBPM)
////            }
////        }
////        
////        let option1 = UIAction(title: "Clock", state: selectedBeat == "Clock" ? .on : .off, handler: optionClosure)
////        let option2 = UIAction(title: "Grass", state: selectedBeat == "Grass" ? .on : .off, handler: optionClosure)
////        
////        beatButton.menu = UIMenu(children: [option1, option2])
////        beatButton.showsMenuAsPrimaryAction = true
////        beatButton.changesSelectionAsPrimaryAction = true
////    }
////    
////    func presentSummaryAndDismiss() {
////        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
////        guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SessionSummaryVC") as? SessionSummaryViewController else { return }
////        summaryVC.sessionData = session
////        navigationController?.pushViewController(summaryVC, animated: true)
////    }
////    
////    @IBAction func endSessionButtonTapped(_ sender: Any) {
////        RhythmicAudioManager.shared.stop()
////        guard var sessionToUpdate = self.session ?? DataStore.shared.sessions.first else {
////            presentSummaryAndDismiss()
////            return
////        }
////        
////        let timeLeft = timerModel.timeLeft
////        let elapsed = sessionToUpdate.requestedDurationSeconds - timeLeft
////        
////        sessionToUpdate.endDate = Date()
////        sessionToUpdate.elapsedSeconds = elapsed
////        
////        DataStore.shared.update(sessionToUpdate)
////        self.session = sessionToUpdate
////        
////        presentSummaryAndDismiss()
////    }
////}
////
////extension SessionRunningViewController: TimerModelDelegate {
////    
////    func timerDidUpdate(timeLeft: Int, progress: CGFloat) {
////        updateDisplay(seconds: timeLeft)
////        progressView.setProgress(progress)
////    }
////    
////    func timerDidFinish() {
////        RhythmicAudioManager.shared.stop()
////        timeLabel.text = "00:00:00"
////        progressView.setProgress(0)
////        pauseButton.isEnabled = false
////        
////        if var finishedSession = session {
////            finishedSession.elapsedSeconds = finishedSession.requestedDurationSeconds
////            finishedSession.endDate = Date()
////            DataStore.shared.update(finishedSession)
////            self.session = finishedSession
////        }
////        
////        presentSummaryAndDismiss()
////    }
////}
//
//
//
//import UIKit
//
//class SessionRunningViewController: UIViewController {
//    
//    @IBOutlet weak var circularContainer: UIView!
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var pauseButton: UIButton!
//    @IBOutlet weak var beatButton: UIButton!
//    @IBOutlet weak var paceButton: UIButton!
//    @IBOutlet weak var beatPaceUIView: UIView!
//    
//    var totalSessionDuration: Int = 0
//    var selectedBeat: String?
//    var selectedPace: String?
//    var selectedBPM: Int?
//    var hrs: Int = 0
//    var minn: Int = 0
//    var session: RhythmicSessionDTO?
//    
//    private var progressView: CircularProgressView!
//    private var timerModel: TimerModel!
//    
//    // MARK: - Setup
//    private func setupProgressView() {
//        progressView = CircularProgressView(frame: circularContainer.bounds)
//        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        circularContainer.addSubview(progressView)
//        progressView.progressColor = UIColor(hex: "90AF81")
//        progressView.trackColor = UIColor(hex: "90AF81").withAlphaComponent(0.3)
//    }
//    
//    private func updateDisplay(seconds: Int) {
//        let h = seconds / 3600
//        let m = (seconds % 3600) / 60
//        let s = seconds % 60
//        timeLabel.text = String(format: "%02d:%02d:%02d", h, m, s)
//    }
//    
//    private func updatePauseButtonUI() {
//        pauseButton.setTitle((timerModel?.isPaused ?? false) ? "Resume" : "Pause", for: .normal)
//    }
//    
//    private func startAudio() {
//        RhythmicAudioManager.shared.playBeat(
//            fileName: selectedBeat ?? "Clock",
//            bpm: selectedBPM ?? 100
//        )
//    }
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Rhythmic Walking"
//        isModalInPresentation = true
//        
//        setupProgressView()
//        selectedBPM = PaceConfig.bpm(for: selectedPace ?? "Slow")
//        beatButton.setTitle(selectedBeat ?? "Clock", for: .normal)
//        paceButton.setTitle(selectedPace ?? "Slow", for: .normal)
//        beatPaceUIView.applyCardStyle()
//        setupBeatButton()
//        setupPaceButton()
//        
//        if let existing = session {
//            let originalTotal = existing.requestedDurationSeconds
//            let timeLeft = originalTotal - existing.elapsedSeconds
//            timerModel = TimerModel(totalSeconds: originalTotal, startWithTimeLeft: timeLeft)
//            updateDisplay(seconds: timeLeft)
//            progressView.setProgress(CGFloat(timeLeft) / CGFloat(originalTotal))
//        } else if totalSessionDuration > 0 {
//            timerModel = TimerModel(totalSeconds: totalSessionDuration)
//            updateDisplay(seconds: totalSessionDuration)
//            progressView.setProgress(1.0)
//        } else {
//            timerModel = TimerModel(totalSeconds: 1)
//            updateDisplay(seconds: 0)
//        }
//        
//        timerModel.delegate = self
//        timerModel.start()
//        startAudio()
//        updatePauseButtonUI()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tabBarController?.tabBar.isHidden = true
//    }
//    
//    // MARK: - Actions
//    @IBAction func pauseTapped(_ sender: Any) {
//        guard let timerModel = timerModel else { return }
//        if timerModel.isPaused {
//            timerModel.resume()
//        } else {
//            timerModel.pause()
//            RhythmicAudioManager.shared.stop()
//        }
//        updatePauseButtonUI()
//    }
//    
//    @IBAction func endSessionButtonTapped(_ sender: Any) {
//        RhythmicAudioManager.shared.stop()
//        
//        guard var sessionToUpdate = self.session else {
//            presentSummaryAndDismiss()
//            return
//        }
//        
//        let elapsed = sessionToUpdate.requestedDurationSeconds - timerModel.timeLeft
//        sessionToUpdate.elapsedSeconds = elapsed
//        sessionToUpdate.endDate = Date()
//        
//        DataStore.shared.update(sessionToUpdate)
//        self.session = sessionToUpdate
//        
//        presentSummaryAndDismiss()
//    }
//    
//    // MARK: - Navigation
//    func presentSummaryAndDismiss() {
//        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
//        guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SessionSummaryVC") as? SessionSummaryViewController else { return }
//        summaryVC.sessionData = session
//        navigationController?.pushViewController(summaryVC, animated: true)
//    }
//    
//    // MARK: - Button Setup
//    func setupBeatButton() {
//        beatButton.setTitle(selectedBeat ?? "Clock", for: .normal)
//        let optionClosure: UIActionHandler = { [weak self] action in
//            guard let self = self else { return }
//            self.selectedBeat = action.title
//            if !(self.timerModel?.isPaused ?? false) {
//                RhythmicAudioManager.shared.playBeat(fileName: action.title, bpm: self.selectedBPM ?? 100)
//            }
//        }
//        beatButton.menu = UIMenu(children: [
//            UIAction(title: "Clock", state: selectedBeat == "Clock" ? .on : .off, handler: optionClosure),
//            UIAction(title: "Grass", state: selectedBeat == "Grass" ? .on : .off, handler: optionClosure)
//        ])
//        beatButton.showsMenuAsPrimaryAction = true
//        beatButton.changesSelectionAsPrimaryAction = true
//    }
//    
//    func setupPaceButton() {
//        paceButton.setTitle(selectedPace ?? "Slow", for: .normal)
//        let optionClosure: UIActionHandler = { [weak self] action in
//            guard let self = self else { return }
//            self.selectedPace = action.title
//            let newBPM = PaceConfig.bpm(for: action.title)
//            self.selectedBPM = newBPM
//            if !(self.timerModel?.isPaused ?? false) {
//                RhythmicAudioManager.shared.playBeat(fileName: self.selectedBeat ?? "Clock", bpm: newBPM)
//            }
//        }
//        paceButton.menu = UIMenu(children: [
//            UIAction(title: "Slow",     state: selectedPace == "Slow"     ? .on : .off, handler: optionClosure),
//            UIAction(title: "Moderate", state: selectedPace == "Moderate" ? .on : .off, handler: optionClosure),
//            UIAction(title: "Fast",     state: selectedPace == "Fast"     ? .on : .off, handler: optionClosure)
//        ])
//        paceButton.showsMenuAsPrimaryAction = true
//        paceButton.changesSelectionAsPrimaryAction = true
//    }
//}
//
//// MARK: - TimerModelDelegate
//extension SessionRunningViewController: TimerModelDelegate {
//    
//    func timerDidUpdate(timeLeft: Int, progress: CGFloat) {
//        updateDisplay(seconds: timeLeft)
//        progressView.setProgress(progress)
//    }
//    
//    func timerDidFinish() {
//        RhythmicAudioManager.shared.stop()
//        timeLabel.text = "00:00:00"
//        progressView.setProgress(0)
//        pauseButton.isEnabled = false
//        
//        if var finished = session {
//            finished.elapsedSeconds = finished.requestedDurationSeconds
//            finished.endDate = Date()
//            DataStore.shared.update(finished)
//            self.session = finished
//        }
//        presentSummaryAndDismiss()
//    }
//}



//
//  SessionRunningViewController.swift
//  Parkinsons
//
//  Navigation:
//  - Presented as .pageSheet from SetGoalVC (slides UP)
//  - On End Session / timer finish → dismiss (slides DOWN) → onSessionEnded callback
//    → SetGoalVC pushes SummaryVC
//
//  HealthKit window fix for RESUMED sessions:
//  - New session:     startDate = Date() stamped when timer starts
//  - Resumed session: startDate = session.startDate (the ORIGINAL start from Core Data)
//    so the HealthKit fetch window covers the entire walk, not just the resumed segment.
//  - endDate is always set to Date() when the session ends.

import UIKit

class SessionRunningViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var circularContainer: UIView!
    @IBOutlet weak var timeLabel:         UILabel!
    @IBOutlet weak var pauseButton:       UIButton!
    @IBOutlet weak var beatButton:        UIButton!
    @IBOutlet weak var paceButton:        UIButton!
    @IBOutlet weak var beatPaceUIView:    UIView!

    // MARK: - Input (set by SetGoalViewController)
    var totalSessionDuration: Int = 0
    var selectedBeat: String      = BeatType.click.rawValue
    var selectedPace: String      = "Slow"
    var selectedBPM:  Int         = 80
    var hrs:  Int = 0
    var minn: Int = 0
    /// Non-nil when RESUMING an existing session; nil for a brand-new one.
    var session: RhythmicSessionDTO?

    // MARK: - Callback
    var onSessionEnded: ((RhythmicSessionDTO) -> Void)?

    // MARK: - Private
    private var progressView:      CircularProgressView!
    private var timerModel:        TimerModel!
    private var sessionEndHandled  = false

    /// The date used as the HealthKit fetch-window START.
    /// • New session  → stamped when viewDidLoad fires (user just pressed Start)
    /// • Resumed      → kept as the original session.startDate so the window covers
    ///                  every segment of the walk, not just the current resume.
    private var healthKitStartDate: Date = Date()

    // MARK: - Setup

    private func setupProgressView() {
        progressView = CircularProgressView(frame: circularContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        circularContainer.addSubview(progressView)
        progressView.progressColor = UIColor(hex: "90AF81")
        progressView.trackColor    = UIColor(hex: "90AF81").withAlphaComponent(0.3)
        progressView.lineWidth     = 15
    }

    private func updateDisplay(seconds: Int) {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        timeLabel.text = String(format: "%02d:%02d:%02d", h, m, s)
    }

    private func updatePauseButtonUI() {
        pauseButton.setTitle((timerModel?.isPaused ?? false) ? "Resume" : "Pause", for: .normal)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedBPM = PaceConfig.bpm(for: selectedPace)

        setupProgressView()
        beatButton.setTitle(selectedBeat, for: .normal)
        paceButton.setTitle(selectedPace, for: .normal)
        beatPaceUIView.applyCardStyle()
        setupBeatButton()
        setupPaceButton()

        if let existing = session {
            // ── RESUMED session ───────────────────────────────────────────
            // Keep the original startDate so HealthKit covers the full walk
            healthKitStartDate = existing.startDate

            let total    = existing.requestedDurationSeconds
            let timeLeft = max(0, total - existing.elapsedSeconds)
            timerModel   = TimerModel(totalSeconds: total, startWithTimeLeft: timeLeft)
            updateDisplay(seconds: timeLeft)
            progressView.setProgress(total > 0 ? CGFloat(timeLeft) / CGFloat(total) : 1.0)

        } else if totalSessionDuration > 0 {
            // ── NEW session ───────────────────────────────────────────────
            healthKitStartDate = Date()   // stamp now — user is about to walk

            timerModel = TimerModel(totalSeconds: totalSessionDuration)
            updateDisplay(seconds: totalSessionDuration)
            progressView.setProgress(1.0)

        } else {
            healthKitStartDate = Date()
            timerModel = TimerModel(totalSeconds: 1)
            updateDisplay(seconds: 0)
        }

        timerModel.delegate = self
        timerModel.start()
        RhythmicAudioManager.shared.playBeat(beatType: selectedBeat, bpm: selectedBPM)
        updatePauseButtonUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RhythmicAudioManager.shared.stop()
        if !sessionEndHandled { saveProgress() }
    }

    // MARK: - Save

    @discardableResult
    private func saveProgress(endDate: Date? = nil) -> RhythmicSessionDTO? {
        guard var s = session else { return nil }
        let elapsed      = s.requestedDurationSeconds - (timerModel?.timeLeft ?? 0)
        s.elapsedSeconds = max(0, elapsed)
        // Always use healthKitStartDate (original for resumes, fresh for new)
        s = RhythmicSessionDTO(
            id:                       s.id,
            sessionNumber:            s.sessionNumber,
            startDate:                healthKitStartDate,
            endDate:                  endDate ?? s.endDate,
            requestedDurationSeconds: s.requestedDurationSeconds,
            elapsedSeconds:           s.elapsedSeconds,
            beat:                     s.beat,
            pace:                     s.pace
        )
        DataStore.shared.update(s)
        session = s
        return s
    }

    // MARK: - End session

    private func endSession(fullyCompleted: Bool = false) {
        guard !sessionEndHandled else { return }
        sessionEndHandled = true

        timerModel?.pause()
        RhythmicAudioManager.shared.stop()

        let endDate = Date()

        if fullyCompleted, var s = session {
            s.elapsedSeconds = s.requestedDurationSeconds
            s = RhythmicSessionDTO(
                id:                       s.id,
                sessionNumber:            s.sessionNumber,
                startDate:                healthKitStartDate,
                endDate:                  endDate,
                requestedDurationSeconds: s.requestedDurationSeconds,
                elapsedSeconds:           s.elapsedSeconds,
                beat:                     s.beat,
                pace:                     s.pace
            )
            DataStore.shared.update(s)
            session = s
        } else {
            saveProgress(endDate: endDate)
        }

        guard let finishedSession = session else { return }

        dismiss(animated: true) { [weak self] in
            self?.onSessionEnded?(finishedSession)
        }
    }

    // MARK: - Actions

    @IBAction func pauseTapped(_ sender: Any) {
        guard let timerModel = timerModel else { return }
        if timerModel.isPaused {
            timerModel.resume()
            RhythmicAudioManager.shared.resume()
        } else {
            timerModel.pause()
            RhythmicAudioManager.shared.pause()
        }
        updatePauseButtonUI()
    }

    @IBAction func endSessionButtonTapped(_ sender: Any) {
        endSession(fullyCompleted: false)
    }

    // MARK: - Beat / Pace menus

    func setupBeatButton() {
        beatButton.setTitle(selectedBeat, for: .normal)
        let actions = BeatType.allCases.map { beat -> UIAction in
            UIAction(title: beat.rawValue,
                     state: beat.rawValue == selectedBeat ? .on : .off) { [weak self] action in
                guard let self else { return }
                self.selectedBeat = action.title
                self.beatButton.setTitle(action.title, for: .normal)
                if !(self.timerModel?.isPaused ?? false) {
                    RhythmicAudioManager.shared.playBeat(beatType: action.title,
                                                         bpm: self.selectedBPM)
                }
            }
        }
        beatButton.menu = UIMenu(children: actions)
        beatButton.showsMenuAsPrimaryAction       = true
        beatButton.changesSelectionAsPrimaryAction = true
    }

    func setupPaceButton() {
        paceButton.setTitle(selectedPace, for: .normal)
        let actions = ["Slow", "Moderate", "Fast"].map { pace -> UIAction in
            UIAction(title: pace,
                     state: pace == selectedPace ? .on : .off) { [weak self] action in
                guard let self else { return }
                self.selectedPace = action.title
                let bpm           = PaceConfig.bpm(for: action.title)
                self.selectedBPM  = bpm
                self.paceButton.setTitle(action.title, for: .normal)
                if !(self.timerModel?.isPaused ?? false) {
                    RhythmicAudioManager.shared.playBeat(beatType: self.selectedBeat, bpm: bpm)
                }
            }
        }
        paceButton.menu = UIMenu(children: actions)
        paceButton.showsMenuAsPrimaryAction       = true
        paceButton.changesSelectionAsPrimaryAction = true
    }
}

// MARK: - TimerModelDelegate

extension SessionRunningViewController: TimerModelDelegate {

    func timerDidUpdate(timeLeft: Int, progress: CGFloat) {
        updateDisplay(seconds: timeLeft)
        progressView.setProgress(progress)
    }

    func timerDidFinish() {
        updateDisplay(seconds: 0)
        progressView.setProgress(0)
        pauseButton.isEnabled = false
        endSession(fullyCompleted: true)
    }
}
