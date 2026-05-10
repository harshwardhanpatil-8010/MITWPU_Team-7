//
//import UIKit
//import CoreData
//
//class SetGoalViewController: UIViewController,
//                             UITableViewDataSource, UITableViewDelegate,
//                             UIPickerViewDataSource, UIPickerViewDelegate {
//
//    @IBOutlet weak var datePickerUIView:  UIView!
//    @IBOutlet weak var DurationPicker:    UIPickerView!
//    @IBOutlet weak var beatButton:        UIButton!
//    @IBOutlet weak var paceButton:        UIButton!
//    @IBOutlet weak var startButton:       UIButton!
//    @IBOutlet weak var paceBeatUIView:    UIView!
//    @IBOutlet weak var sessionTableView:  UITableView!
//    @IBOutlet weak var noSessionsOutlet:  UIStackView!
//
//    private var selectedBeat: String = BeatType.click.rawValue
//    private var selectedPace: String = "Slow"
//    let dataForColumn1 = Array(0...5)
//    let dataForColumn2 = Array(0...59)
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
//
//    func pickerView(_ pickerView: UIPickerView,
//                    numberOfRowsInComponent component: Int) -> Int {
//        component == 0 ? dataForColumn1.count : dataForColumn2.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
//                    forComponent component: Int, reusing view: UIView?) -> UIView {
//        let container = UIView(frame: CGRect(x: 0, y: 0,
//                                            width: pickerView.frame.width / 2, height: 44))
//        let label = UILabel(frame: container.bounds)
//        label.font          = .systemFont(ofSize: 22, weight: .regular)
//        label.textAlignment = .center
//        label.text          = component == 0
//            ? "\(dataForColumn1[row]) hours"
//            : "\(dataForColumn2[row]) min"
//        container.addSubview(label)
//        return container
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
//                    inComponent component: Int) {
//        updateStartButtonState()
//    }
//
//    func tableView(_ tableView: UITableView,
//                   numberOfRowsInSection section: Int) -> Int {
//        DataStore.shared.sessions.count
//    }
//
//    func tableView(_ tableView: UITableView,
//                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell    = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
//        let session = DataStore.shared.sessions[indexPath.row]
//        let elapsed = session.elapsedSeconds
//        let h = elapsed / 3600
//        let m = (elapsed % 3600) / 60
//        let s = elapsed % 60
//
//        let timeText = h == 0
//            ? "\(m)min \(s)s"
//            : "\(h)hrs \(m)m"
//
//        cell.textLabel?.text = "Session \(session.sessionNumber)"
//        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
//
//        if let detail = cell.detailTextLabel {
//            detail.text      = timeText
//            detail.textColor = .secondaryLabel
//            detail.font      = .systemFont(ofSize: 16, weight: .regular)
//        } else {
//            let tag = 9_001
//            let rightLabel: UILabel
//            if let existing = cell.contentView.viewWithTag(tag) as? UILabel {
//                rightLabel = existing
//            } else {
//                rightLabel = UILabel()
//                rightLabel.tag           = tag
//                rightLabel.textAlignment = .right
//                rightLabel.textColor     = .secondaryLabel
//                rightLabel.font          = .systemFont(ofSize: 16, weight: .regular)
//                rightLabel.translatesAutoresizingMaskIntoConstraints = false
//                cell.contentView.addSubview(rightLabel)
//                NSLayoutConstraint.activate([
//                    rightLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
//                    rightLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor,
//                                                         constant: -16)
//                ])
//            }
//            rightLabel.text = timeText
//        }
//
//        cell.accessoryType = .disclosureIndicator
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView,
//                   didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let selected = DataStore.shared.sessions[indexPath.row]
//        pushSummary(for: selected)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let gradient = navGradientOverlay
//        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140)
//        view.layer.addSublayer(gradient)
//        DurationPicker.dataSource = self
//        DurationPicker.delegate   = self
//        DurationPicker.selectRow(10, inComponent: 1, animated: false)
//
//        datePickerUIView.applyCardStyle()
//        paceBeatUIView.applyCardStyle()
//
//        sessionTableView.dataSource         = self
//        sessionTableView.delegate           = self
//        sessionTableView.layer.cornerRadius = 30
//        sessionTableView.clipsToBounds      = true
//
//        setupBeatButton()
//        setupPaceButton()
//        updateStartButtonState()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tabBarController?.tabBar.isHidden = true
//        let gradient = navGradientOverlay
//        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140)
//        view.layer.addSublayer(gradient)
//        sessionTableView.reloadData()
//        checkGoalStatus()
//        refreshListVisibility()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        tabBarController?.tabBar.isHidden = false
//    }
//
//    private func refreshListVisibility() {
//        let empty = DataStore.shared.sessions.isEmpty
//        noSessionsOutlet.isHidden = !empty
//        sessionTableView.isHidden  =  empty
//    }
//
//    private func checkGoalStatus() {
//        if let goal = DataStore.shared.dailyGoalSession {
//            DurationPicker.isUserInteractionEnabled = false
//            DurationPicker.alpha = 0.3
//            startButton.setTitle("Resume", for: .normal)
//            let h = goal.requestedDurationSeconds / 3600
//            let m = (goal.requestedDurationSeconds % 3600) / 60
//            DurationPicker.selectRow(h, inComponent: 0, animated: false)
//            DurationPicker.selectRow(m, inComponent: 1, animated: false)
//        } else {
//            DurationPicker.isUserInteractionEnabled = true
//            DurationPicker.alpha = 1.0
//            startButton.setTitle("Start", for: .normal)
//        }
//    }
//    private var navGradientOverlay: CAGradientLayer {
//        let gradient = CAGradientLayer()
//        gradient.colors = [
//            UIColor(hex: "90AF81").withAlphaComponent(0.35).cgColor,
//            UIColor(hex: "90AF81").withAlphaComponent(0.0).cgColor
//        ]
//        gradient.startPoint = CGPoint(x: 0.5, y: 0)
//        gradient.endPoint   = CGPoint(x: 0.5, y: 1)
//        return gradient
//    }
//    
//
//    func updateStartButtonState() {
//        let h = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
//        let m = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
//        startButton.isEnabled = (h * 3600 + m * 60) > 0
//    }
//
//    func setupBeatButton() {
//        beatButton.setTitle(selectedBeat, for: .normal)
//        let actions = BeatType.allCases.map { beat -> UIAction in
//            UIAction(title: beat.rawValue,
//                     state: beat.rawValue == selectedBeat ? .on : .off) { [weak self] action in
//                self?.selectedBeat = action.title
//                self?.beatButton.setTitle(action.title, for: .normal)
//            }
//        }
//        beatButton.menu = UIMenu(children: actions)
//        beatButton.showsMenuAsPrimaryAction       = true
//        beatButton.changesSelectionAsPrimaryAction = true
//    }
//
//    func setupPaceButton() {
//        paceButton.setTitle(selectedPace, for: .normal)
//        let actions = ["Slow", "Moderate", "Fast"].map { pace -> UIAction in
//            UIAction(title: pace,
//                     state: pace == selectedPace ? .on : .off) { [weak self] action in
//                self?.selectedPace = action.title
//                self?.paceButton.setTitle(action.title, for: .normal)
//            }
//        }
//        paceButton.menu = UIMenu(children: actions)
//        paceButton.showsMenuAsPrimaryAction       = true
//        paceButton.changesSelectionAsPrimaryAction = true
//    }
//
//    func pushSummary(for session: RhythmicSessionDTO) {
//        let sb = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
//        guard let vc = sb.instantiateViewController(withIdentifier: "SessionSummaryVC")
//                as? SessionSummaryViewController else { return }
//        vc.sessionData = session
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
//    @IBAction func infoButtonTapped(_ sender: UIBarButtonItem) {
//        let sb = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
//        guard let vc = sb.instantiateViewController(withIdentifier: "infoVC")
//                as? RhythmicInfoViewController else { return }
//        vc.modalPresentationStyle = .pageSheet
//        present(vc, animated: true)
//    }
//
//    @IBAction func startButtonTapped(_ sender: Any) {
//        let h     = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
//        let m     = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
//        let total = h * 3600 + m * 60
//        guard total > 0 else { return }
//
//        let sessionToRun: RhythmicSessionDTO
//
//        if let goal = DataStore.shared.dailyGoalSession {
//            sessionToRun = goal
//        } else {
//            let new = RhythmicSessionDTO(
//                id: UUID(),
//                sessionNumber: DataStore.shared.sessions.count + 1,
//                startDate: Date(),
//                endDate: nil,
//                requestedDurationSeconds: total,
//                elapsedSeconds: 0,
//                beat: selectedBeat,
//                pace: selectedPace
//            )
//            DataStore.shared.add(new)
//            sessionToRun = new
//        }
//
//        let sb = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
//        guard let runVC = sb.instantiateViewController(withIdentifier: "SessionRunningVC")
//                as? SessionRunningViewController else { return }
//
//        let remaining           = max(0, sessionToRun.requestedDurationSeconds
//                                           - sessionToRun.elapsedSeconds)
//        runVC.totalSessionDuration = remaining
//        runVC.hrs               = remaining / 3600
//        runVC.minn              = (remaining % 3600) / 60
//        runVC.selectedBeat      = sessionToRun.beat
//        runVC.selectedPace      = sessionToRun.pace
//        runVC.selectedBPM       = PaceConfig.bpm(for: sessionToRun.pace)
//        runVC.session           = sessionToRun
//
//        runVC.onSessionEnded = { [weak self] finishedSession in
//            guard let self else { return }
//            self.sessionTableView.reloadData()
//            self.refreshListVisibility()
//            self.checkGoalStatus()
//            self.pushSummary(for: finishedSession)
//        }
//
//        runVC.modalPresentationStyle = .pageSheet
//        if let sheet = runVC.sheetPresentationController {
//            sheet.detents = [.large()]
//            sheet.prefersGrabberVisible = false
//        }
//        present(runVC, animated: true)
//    }
//}






import UIKit
import CoreData

class SetGoalViewController: UIViewController,
                             UITableViewDataSource, UITableViewDelegate,
                             UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var datePickerUIView:  UIView!
    @IBOutlet weak var DurationPicker:    UIPickerView!
    @IBOutlet weak var beatButton:        UIButton!
    @IBOutlet weak var paceButton:        UIButton!
    @IBOutlet weak var startButton:       UIButton!
    @IBOutlet weak var paceBeatUIView:    UIView!
    @IBOutlet weak var sessionTableView:  UITableView!
    @IBOutlet weak var noSessionsOutlet:  UIStackView!

    private var selectedBeat: String = BeatType.click.rawValue
    private var selectedPace: String = "Slow"
    let dataForColumn1 = Array(0...5)
    let dataForColumn2 = Array(10...59)

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        component == 0 ? dataForColumn1.count : dataForColumn2.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                    forComponent component: Int, reusing view: UIView?) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0,
                                            width: pickerView.frame.width / 2, height: 44))
        let label = UILabel(frame: container.bounds)
        label.font          = .systemFont(ofSize: 22, weight: .regular)
        label.textAlignment = .center
        label.text          = component == 0
            ? "\(dataForColumn1[row]) hours"
            : "\(dataForColumn2[row]) min"
        container.addSubview(label)
        return container
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        updateStartButtonState()
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        DataStore.shared.sessions.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell    = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
        let session = DataStore.shared.sessions[indexPath.row]
        let elapsed = session.elapsedSeconds
        let h = elapsed / 3600
        let m = (elapsed % 3600) / 60
        let s = elapsed % 60

        let timeText = h == 0
            ? "\(m)min \(s)s"
            : "\(h)hrs \(m)m"

        cell.textLabel?.text = "Session \(session.sessionNumber)"
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)

        if let detail = cell.detailTextLabel {
            detail.text      = timeText
            detail.textColor = .secondaryLabel
            detail.font      = .systemFont(ofSize: 16, weight: .regular)
        } else {
            let tag = 9_001
            let rightLabel: UILabel
            if let existing = cell.contentView.viewWithTag(tag) as? UILabel {
                rightLabel = existing
            } else {
                rightLabel = UILabel()
                rightLabel.tag           = tag
                rightLabel.textAlignment = .right
                rightLabel.textColor     = .secondaryLabel
                rightLabel.font          = .systemFont(ofSize: 16, weight: .regular)
                rightLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(rightLabel)
                NSLayoutConstraint.activate([
                    rightLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    rightLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor,
                                                         constant: -16)
                ])
            }
            rightLabel.text = timeText
        }

        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selected = DataStore.shared.sessions[indexPath.row]
        pushSummary(for: selected, isHistory: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let gradient = navGradientOverlay
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140)
        view.layer.addSublayer(gradient)
        DurationPicker.dataSource = self
        DurationPicker.delegate   = self
        DurationPicker.selectRow(10, inComponent: 1, animated: false)

        datePickerUIView.applyCardStyle()
        paceBeatUIView.applyCardStyle()

        sessionTableView.dataSource         = self
        sessionTableView.delegate           = self
        sessionTableView.layer.cornerRadius = 30
        sessionTableView.clipsToBounds      = true

        setupBeatButton()
        setupPaceButton()
        updateStartButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        let gradient = navGradientOverlay
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140)
        view.layer.addSublayer(gradient)
        sessionTableView.reloadData()
        checkGoalStatus()
        refreshListVisibility()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func refreshListVisibility() {
        let empty = DataStore.shared.sessions.isEmpty
        noSessionsOutlet.isHidden = !empty
        sessionTableView.isHidden  =  empty
    }

    private func checkGoalStatus() {
        if let goal = DataStore.shared.dailyGoalSession {
            DurationPicker.isUserInteractionEnabled = false
            DurationPicker.alpha = 0.3
            startButton.setTitle("Resume", for: .normal)
            let h = goal.requestedDurationSeconds / 3600
            let m = (goal.requestedDurationSeconds % 3600) / 60
            DurationPicker.selectRow(h, inComponent: 0, animated: false)
            DurationPicker.selectRow(m, inComponent: 1, animated: false)
        } else {
            DurationPicker.isUserInteractionEnabled = true
            DurationPicker.alpha = 1.0
            startButton.setTitle("Start", for: .normal)
        }
    }

    private var navGradientOverlay: CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(hex: "90AF81").withAlphaComponent(0.35).cgColor,
            UIColor(hex: "90AF81").withAlphaComponent(0.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1)
        return gradient
    }

    func updateStartButtonState() {
        let h = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
        let m = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
        startButton.isEnabled = (h * 3600 + m * 60) > 0
    }

    func setupBeatButton() {
        beatButton.setTitle(selectedBeat, for: .normal)
        let actions = BeatType.allCases.map { beat -> UIAction in
            UIAction(title: beat.rawValue,
                     state: beat.rawValue == selectedBeat ? .on : .off) { [weak self] action in
                self?.selectedBeat = action.title
                self?.beatButton.setTitle(action.title, for: .normal)
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
                self?.selectedPace = action.title
                self?.paceButton.setTitle(action.title, for: .normal)
            }
        }
        paceButton.menu = UIMenu(children: actions)
        paceButton.showsMenuAsPrimaryAction       = true
        paceButton.changesSelectionAsPrimaryAction = true
    }

    func pushSummary(for session: RhythmicSessionDTO, isHistory: Bool = true) {
        let sb = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "SessionSummaryVC")
                as? SessionSummaryViewController else { return }
        vc.sessionData   = session
        vc.isHistoryView = isHistory
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func infoButtonTapped(_ sender: UIBarButtonItem) {
        let sb = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "infoVC")
                as? RhythmicInfoViewController else { return }
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }

    @IBAction func startButtonTapped(_ sender: Any) {
        let h     = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
        let m     = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
        let total = h * 3600 + m * 60
        guard total > 0 else { return }

        let sessionToRun: RhythmicSessionDTO

        if let goal = DataStore.shared.dailyGoalSession {
            sessionToRun = goal
        } else {
            let new = RhythmicSessionDTO(
                id: UUID(),
                sessionNumber: DataStore.shared.sessions.count + 1,
                startDate: Date(),
                endDate: nil,
                requestedDurationSeconds: total,
                elapsedSeconds: 0,
                beat: selectedBeat,
                pace: selectedPace
            )
            DataStore.shared.add(new)
            sessionToRun = new
        }

        let sb = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
        guard let runVC = sb.instantiateViewController(withIdentifier: "SessionRunningVC")
                as? SessionRunningViewController else { return }

        let remaining           = max(0, sessionToRun.requestedDurationSeconds
                                           - sessionToRun.elapsedSeconds)
        runVC.totalSessionDuration = remaining
        runVC.hrs               = remaining / 3600
        runVC.minn              = (remaining % 3600) / 60
        runVC.selectedBeat      = sessionToRun.beat
        runVC.selectedPace      = sessionToRun.pace
        runVC.selectedBPM       = PaceConfig.bpm(for: sessionToRun.pace)
        runVC.session           = sessionToRun

        runVC.onSessionEnded = { [weak self] finishedSession in
            guard let self else { return }
            self.sessionTableView.reloadData()
            self.refreshListVisibility()
            self.checkGoalStatus()
            self.pushSummary(for: finishedSession, isHistory: false)
        }

        runVC.modalPresentationStyle = .pageSheet
        if let sheet = runVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
        }
        present(runVC, animated: true)
    }
}
