

import UIKit

class SessionRunningViewController: UIViewController {

    @IBOutlet weak var circularContainer: UIView!
    @IBOutlet weak var timeLabel:         UILabel!
    @IBOutlet weak var pauseButton:       UIButton!
    @IBOutlet weak var beatButton:        UIButton!
    @IBOutlet weak var paceButton:        UIButton!
    @IBOutlet weak var beatPaceUIView:    UIView!

    var totalSessionDuration: Int = 0
    var selectedBeat: String      = BeatType.click.rawValue
    var selectedPace: String      = "Slow"
    var selectedBPM:  Int         = 80
    var hrs:  Int = 0
    var minn: Int = 0
    var session: RhythmicSessionDTO?

    var onSessionEnded: ((RhythmicSessionDTO) -> Void)?

    private var progressView:      CircularProgressView!
    private var timerModel:        TimerModel!
    private var sessionEndHandled  = false
    private var healthKitStartDate: Date = Date()


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


    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        selectedBPM = PaceConfig.bpm(for: selectedPace)

        setupProgressView()
        beatButton.setTitle(selectedBeat, for: .normal)
        paceButton.setTitle(selectedPace, for: .normal)
        beatPaceUIView.applyCardStyle()
        setupBeatButton()
        setupPaceButton()

        if let existing = session {
            healthKitStartDate = existing.startDate

            let total    = existing.requestedDurationSeconds
            let timeLeft = max(0, total - existing.elapsedSeconds)
            timerModel   = TimerModel(totalSeconds: total, startWithTimeLeft: timeLeft)
            updateDisplay(seconds: timeLeft)
            progressView.setProgress(total > 0 ? CGFloat(timeLeft) / CGFloat(total) : 1.0)

        } else if totalSessionDuration > 0 {
            // Use the session's recorded startDate so HealthKit query window aligns correctly.
            healthKitStartDate = session?.startDate ?? Date()

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


    @discardableResult
    private func saveProgress(endDate: Date? = nil) -> RhythmicSessionDTO? {
        guard var s = session else { return nil }
        let elapsed      = s.requestedDurationSeconds - (timerModel?.timeLeft ?? 0)
        s.elapsedSeconds = max(0, elapsed)
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

    @IBAction func pauseTapped(_ sender: Any) {
        guard let timerModel = timerModel else { return }
        if timerModel.isPaused {
            timerModel.resume()
            RhythmicAudioManager.shared.playBeat(beatType: selectedBeat, bpm: selectedBPM)
        } else {
            timerModel.pause()
            RhythmicAudioManager.shared.pause()
        }
        updatePauseButtonUI()
    }

    @IBAction func endSessionButtonTapped(_ sender: Any) {
        endSession(fullyCompleted: false)
    }

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

extension SessionRunningViewController: TimerModelDelegate {

    func timerDidUpdate(timeLeft: Int, progress: CGFloat) {
        updateDisplay(seconds: timeLeft)
        progressView.setProgress(progress)
    }

    func timerDidFinish() {
        updateDisplay(seconds: 0)
        progressView.setProgress(0)
        pauseButton.isEnabled = false
        timerModel?.pause()
        RhythmicAudioManager.shared.stop()
        // Modal will stay presented until the user explicitly taps 'End Session'
    }
}
