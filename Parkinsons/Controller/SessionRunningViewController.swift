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
    
    var totalSessionDuration: Int = 0
    var selectedBeat: String?
    var selectedPace: String?
    var selectedBPM: Int?
    
    private var progressView: CircularProgressView!
  //  private var timerModel: TimerModel!
    
    
    private func setupProgressView() {
        progressView = CircularProgressView(frame: circularContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        circularContainer.addSubview(progressView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        timeLabel.text = String(totalSessionDuration)
        beatButton.titleLabel?.text = selectedBeat
        paceButton.titleLabel?.text = selectedPace
        
        setupBeatButton()
        setupPaceButton()
        
//        if totalSessionDuration > 0{
//            timerModel = TimerModel(totalSeconds: totalSessionDuration)
//            updateDisplay(with: totalSessionDuration)
//        }
//        else {
//            timerModel = TimerModel(totalSeconds: 1)
//            updateDisplay(with: 0)
//        }
//        timerModel.delegate = self
//        if totalSessionDuration > 0{
//            timerModel.start()
//        }
////        let model = TimerModel(totalSeconds: totalSessionDuration)
//        model.delegate = self
//        model.start()
//        self.timerModel = model
        
//        BeatPlayer.shared.setupAudio(fileName: selectedBeat)
       // updatePauseButtonUI()
        // Do any additional setup after loading the view.
    }
    
    
    private func updateDisplay(with timeleft: Int) {
        let hours = timeleft / 60
        let minutes = timeleft % 60
        timeLabel.text = String(format: "%02d:%02d", hours, minutes)
        progressView.setProgress(1.0)
    }
    
//    @IBAction func pauseTapped(_ sender: Any) {
//        guard let timerModel = timerModel else { return }
//        if timerModel.isPaused {
//            timerModel.resume()
//        } else {
//            timerModel.pause()
//        }
//        updatePauseButtonUI()
//    }
//        
//    private func updatePauseButtonUI() {
//        let title: String
//        if let timerModel = timerModel {
//            title = timerModel.isPaused ? "Resume" : "Pause"
//        } else {
//            title = "Pause"
//        }
//        pauseButton.setTitle(title, for: .normal)
//    }
//        
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
        let option2 = UIAction(title: "Medium", state: selectedPace == "Medium" ? .on : .off, handler: optionClosure)
        let option3 = UIAction(title: "Fast", state: selectedPace == "Fast" ? .on : .off, handler: optionClosure)
        let menu  = UIMenu(children: [option1, option2, option3])
        paceButton.menu = menu
        paceButton.showsMenuAsPrimaryAction = true
        paceButton.changesSelectionAsPrimaryAction = true
    }
    
}

//extension SessionRunningViewController: TimerModelDelegate {
//        
//    func timerDidUpdate(timeLeft: Int, progress: CGFloat) {
//        let minutes = timeLeft / 60
//        let seconds = timeLeft % 60
//        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
//        
//        progressView.setProgress(progress)
//    }
//    
//    func timerDidFinish() {
//        timeLabel.text = " 00:00 "
//        progressView.setProgress(0)
//        pauseButton.isEnabled = false
//    }
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
