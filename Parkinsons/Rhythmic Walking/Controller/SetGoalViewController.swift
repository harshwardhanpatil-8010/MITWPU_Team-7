////
////  SetGoalViewController.swift
////  Parkinson's App
////
////  Created by SDC-USER on 25/11/25.
////
//
////import UIKit
////
////class SetGoalViewController: UIViewController, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate {
////    
////    @IBOutlet weak var datePickerUIView: UIView!
////    @IBOutlet weak var DurationPicker: UIPickerView!
////    @IBOutlet weak var beatButton: UIButton!
////    @IBOutlet weak var paceButton: UIButton!
////    @IBOutlet weak var startButton: UIButton!
////    @IBOutlet weak var paceBeatUIView: UIView!
////    @IBOutlet weak var sessionTableView: UITableView!
////    @IBOutlet weak var noSessionsOutlet: UIStackView!
////    
////    var startTapsCount: Int = 0
////   
//////    private var sessions: [RhythmicSession] = []
////    
////    // Replace the old array
////    // Add this variable to the top of your class
////    var sessions: [RhythmicSession] = []
////
////    func fetchSessions() {
////        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
////        // Sort so newest session is at the top
////        request.sortDescriptors = [NSSortDescriptor(keyPath: \RhythmicSession.startDate, ascending: false)]
////        
////        do {
////            sessions = try PersistenceController.shared.context.fetch(request)
////            sessionTableView.reloadData()
////        } catch {
////            print("Fetch failed")
////        }
////    }
////   
////    private var selectedBeat = "Clock"
////    private var selectedPace: String = "Slow"
////    let dataForColumn1 = Array(00...05)
////    let dataForColumn2 = Array(00...59)
////    var selectedHoursString: String {
////        let selectedRow = DurationPicker?.selectedRow(inComponent: 0) ?? 0
////        let value = dataForColumn1[min(max(0, selectedRow), dataForColumn1.count - 1)]
////        return String(value)
////    }
////    
////    
////    
////    func numberOfComponents(in pickerView: UIPickerView) -> Int {
////        return 2
////    }
////    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
////        switch component {
////        case 0:
////            return dataForColumn1.count
////        case 1:
////            return dataForColumn2.count
////        default:
////            return 0
////        }
////    }
////    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
////
////        let container = UIView()
////        container.frame = CGRect(x: 0, y: 0, width: pickerView.frame.width/2, height: 44)
////
////        let label = UILabel(frame: CGRect(x: 0, y: 0, width: container.frame.width, height: 44))
////        label.font = UIFont.systemFont(ofSize: 22, weight: .regular)
////        label.textAlignment = .center
////        if component == 0 {
////            label.text = "\(dataForColumn1[row]) hours"
////        } else {
////            label.text = "\(dataForColumn2[row]) min"
////        }
////
////        container.addSubview(label)
////        return container
////    }
////    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
////        updateStartButtonState()
////    }
////    
////    
////
////    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return DataStore.shared.sessions.count
////    }
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
////        let session = DataStore.shared.sessions[indexPath.row]
////        _ = DataStore.shared.sessions.count - indexPath.row
////        let walked = session.elapsedSeconds
////        let hrs = walked / 3600
////        let mins = walked % 3600 / 60
////        let secs = walked % 60
////        let displayNum = session.sessionNumber
////        
////        if hrs == 0 {
////            cell.textLabel?.text = "Session \(displayNum)\t\t\t\t\t\t  \(mins)min \(secs)s"
////        }
////        else{
////            cell.textLabel?.text = "Session \(displayNum)\t\t\t\t\t\t  \(hrs)hrs \(mins)min"
////        }
////        return cell
////    }
////    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        tableView.deselectRow(at: indexPath, animated: true)
////        let selectedSession = DataStore.shared.sessions[indexPath.row]
////        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
////        guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SessionSummaryVC") as? SessionSummaryViewController else {
////            return
////        }
////        summaryVC.sessionData = selectedSession
////        let nav = UINavigationController(rootViewController: summaryVC)
////        nav.modalPresentationStyle = .formSheet
////        present(nav, animated: true)
////    }
////    
////    
////    private func updateButtons() {
////        beatButton.setTitle("\(selectedBeat)", for: .normal)
////        paceButton.setTitle("\(selectedPace)", for: .normal)
////    }
////    private func bpmForPace(_ pace: String) -> Int {
////        switch pace {
////        case "Slow":
////            return 80
////        case "Moderate":
////            return 120
////        case "Fast":
////            return 140
////        default:
////            return 100
////        }
////    }
////    private func checkGoalStatus() {
////        if let goal = DataStore.shared.dailyGoalSession {
////            let isTenMinPlus = goal.requestedDurationSeconds >= 600 // 10 mins
////            let isIncomplete = goal.elapsedSeconds < goal.requestedDurationSeconds
////            
////            if isTenMinPlus && isIncomplete {
////                DurationPicker.isUserInteractionEnabled = false
////                DurationPicker.alpha = 0.3
////                startButton.setTitle("Resume", for: .normal)
////                
////                let h = goal.requestedDurationSeconds / 3600
////                let m = (goal.requestedDurationSeconds % 3600) / 60
////                DurationPicker.selectRow(h, inComponent: 0, animated: false)
////                DurationPicker.selectRow(m, inComponent: 1, animated: false)
////            } else {
////                DurationPicker.isUserInteractionEnabled = true
////                DurationPicker.alpha = 1.0
////                startButton.setTitle("Start", for: .normal)
////            }
////        }
////    }
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        DurationPicker.dataSource = self
////        DurationPicker.delegate = self
////        DurationPicker.selectRow(10, inComponent: 1, animated: false)
////        datePickerUIView.applyCardStyle()
////        sessionTableView.dataSource = self
////        sessionTableView.layer.cornerRadius = 30
////        sessionTableView.clipsToBounds = true
////        setupBeatButton()
////        setupPaceButton()
////        updateButtons()
////        paceBeatUIView.applyCardStyle()
////        updateStartButtonState()
////        sessionTableView.delegate = self
////    }
////
////    override func viewWillAppear(_ animated: Bool) {
////        super.viewWillAppear(animated)
////        DataStore.shared.cleanupOldSessions()
////        sessionTableView.reloadData()
////        checkGoalStatus()
////    
////        if DataStore.shared.sessions.isEmpty {
////            noSessionsOutlet.isHidden = false
////            sessionTableView.isHidden = true
////        } else {
////            noSessionsOutlet.isHidden = true
////            sessionTableView.isHidden = false
////        }
////        
////        tabBarController?.tabBar.isHidden = true
////    }
////
////    override func viewWillDisappear(_ animated: Bool) {
////        super.viewWillDisappear(animated)
////        tabBarController?.tabBar.isHidden = false
////    }
////
////    /*
////    // MARK: - Navigation
////
////    // In a storyboard-based application, you will often want to do a little preparation before navigation
////    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
////        // Get the new view controller using segue.destination.
////        // Pass the selected object to the new view controller.
////    }
////    */
////    
////    @IBAction func infoButtonTapped(_ sender: UIBarButtonItem) {
////        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
////        guard let infoVC = storyboard.instantiateViewController(withIdentifier: "infoVC") as? RhythmicInfoViewController else {
////            return
////        }
////        infoVC.modalPresentationStyle = .pageSheet
////        self.present(infoVC, animated: true, completion: nil)
////    }
////    
//////    @IBAction func startButtonTapped(_ sender: Any) {
//////        let h = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
//////        let m = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
//////        let total = (h * 3600) + (m * 60)
//////        
//////        guard total > 0 else { return }
//////        let nextSessionNumber = DataStore.shared.sessions.count + 1
//////        let newSession = RhythmicSession(
//////            id: UUID(),
//////            sessionNumber: nextSessionNumber,
//////            startDate: Date(),
//////            endDate: nil,
//////            requestedDurationSeconds: total,
//////            elapsedSeconds: 0,
//////            beat: selectedBeat,
//////            pace: selectedPace,
//////            steps: 0,
//////            distanceKMeters: 0
//////        )
//////        
//////        DataStore.shared.add(newSession)
//////        
//////        sessionTableView.reloadData()
//////        
//////        noSessionsOutlet.isHidden = true
//////        sessionTableView.isHidden = false
//////        
//////        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
//////        guard let destVC = storyboard.instantiateViewController(withIdentifier: "SessionRunningVC") as? SessionRunningViewController else { return }
//////        
//////        let bpm = bpmForPace(selectedPace)
//////        destVC.totalSessionDuration = total
//////        destVC.hrs = h
//////        destVC.minn = m
//////        destVC.selectedBeat = selectedBeat
//////        destVC.selectedPace = selectedPace
//////        destVC.selectedBPM = bpm
//////        
//////        let nav = UINavigationController(rootViewController: destVC)
//////        nav.modalPresentationStyle = .formSheet
//////        present(nav, animated: true)
//////    }
////    
////    @IBAction func startButtonTapped(_ sender: Any) {
////            let h = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
////            let m = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
////            let total = (h * 3600) + (m * 60)
////            guard total > 0 else { return }
////
////            let sessionToRun: RhythmicSession
////
////            if let existingGoal = DataStore.shared.dailyGoalSession,
////               existingGoal.requestedDurationSeconds >= 600,
////               existingGoal.elapsedSeconds < existingGoal.requestedDurationSeconds {
////                sessionToRun = existingGoal
////            } else {
////                let nextNum = DataStore.shared.sessions.count + 1
////                let newSession = RhythmicSession(
////                    id: UUID(),
////                    sessionNumber: nextNum,
////                    startDate: Date(),
////                    endDate: nil,
////                    requestedDurationSeconds: total,
////                    elapsedSeconds: 0,
////                    beat: selectedBeat,
////                    pace: selectedPace,
//////                    steps: 0,
//////                    distanceKMeters: 0
////                )
////                DataStore.shared.add(newSession)
////                
////                if total >= 600 && DataStore.shared.dailyGoalSession == nil {
////                    DataStore.shared.setAsDailyGoal(newSession)
////                }
////                sessionToRun = newSession
////            }
////            let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
////            guard let destVC = storyboard.instantiateViewController(withIdentifier: "SessionRunningVC") as? SessionRunningViewController else { return }
////            
////            let remainingSeconds = sessionToRun.requestedDurationSeconds - sessionToRun.elapsedSeconds
////            destVC.totalSessionDuration = remainingSeconds
////            destVC.hrs = remainingSeconds / 3600
////            destVC.minn = (remainingSeconds % 3600) / 60
////            destVC.selectedBeat = sessionToRun.beat
////            destVC.selectedPace = sessionToRun.pace
////            destVC.selectedBPM = bpmForPace(sessionToRun.pace)
////            destVC.session = sessionToRun 
////            
////            let nav = UINavigationController(rootViewController: destVC)
////            nav.modalPresentationStyle = .formSheet
////            present(nav, animated: true)
////        }
////
////    func updateStartButtonState() {
////        let h = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
////        let m = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
////        let total = (h * 3600) + (m * 60)
////        
////        if total > 0{
////            startButton.isEnabled = true
////        }
////        else {
////            startButton.isEnabled = false
////        }
////    }
////    func setupBeatButton(){
////        let optionClosure: UIActionHandler = { [weak self] action in
////            guard let self = self else { return }
////            self.selectedBeat = action.title
////            self.updateButtons()
////        }
////        let option1 = UIAction(title: "Clock",state: .on, handler: optionClosure)
////        let option2 = UIAction(title: "Grass", handler: optionClosure)
////        let menu  = UIMenu(children: [option1, option2])
////        beatButton.menu = menu
////        beatButton.showsMenuAsPrimaryAction = true
////        beatButton.changesSelectionAsPrimaryAction = true
////    }
////    
////    func setupPaceButton(){
////        let optionClosure: UIActionHandler = { [weak self] action in
////            guard let self = self else { return }
////            self.selectedPace = action.title
////            self.updateButtons()
////        }
////        let option1 = UIAction(title: "Slow",state: .on, handler: optionClosure)
////        let option2 = UIAction(title: "Moderate", handler: optionClosure)
////        let option3 = UIAction(title: "Fast", handler: optionClosure)
////        let menu  = UIMenu(children: [option1, option2, option3])
////        paceButton.menu = menu
////        paceButton.showsMenuAsPrimaryAction = true
////        paceButton.changesSelectionAsPrimaryAction = true
////    }
////}
////
////
//
//
//import UIKit
//import CoreData
//
//class SetGoalViewController: UIViewController, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate {
//    
//    @IBOutlet weak var datePickerUIView: UIView!
//    @IBOutlet weak var DurationPicker: UIPickerView!
//    @IBOutlet weak var beatButton: UIButton!
//    @IBOutlet weak var paceButton: UIButton!
//    @IBOutlet weak var startButton: UIButton!
//    @IBOutlet weak var paceBeatUIView: UIView!
//    @IBOutlet weak var sessionTableView: UITableView!
//    @IBOutlet weak var noSessionsOutlet: UIStackView!
//    
//    var startTapsCount: Int = 0
//    private var selectedBeat = "Clock"
//    private var selectedPace: String = "Slow"
//    let dataForColumn1 = Array(0...5)
//    let dataForColumn2 = Array(0...59)
//    
//    var selectedHoursString: String {
//        let selectedRow = DurationPicker?.selectedRow(inComponent: 0) ?? 0
//        let value = dataForColumn1[min(max(0, selectedRow), dataForColumn1.count - 1)]
//        return String(value)
//    }
//    
//    // MARK: - Picker
//    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        component == 0 ? dataForColumn1.count : dataForColumn2.count
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let container = UIView()
//        container.frame = CGRect(x: 0, y: 0, width: pickerView.frame.width / 2, height: 44)
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: container.frame.width, height: 44))
//        label.font = UIFont.systemFont(ofSize: 22, weight: .regular)
//        label.textAlignment = .center
//        label.text = component == 0 ? "\(dataForColumn1[row]) hours" : "\(dataForColumn2[row]) min"
//        container.addSubview(label)
//        return container
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        updateStartButtonState()
//    }
//    
//    // MARK: - TableView
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return DataStore.shared.sessions.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
//        let session = DataStore.shared.sessions[indexPath.row]
//        let walked = session.elapsedSeconds
//        let hrs  = walked / 3600
//        let mins = walked % 3600 / 60
//        let secs = walked % 60
//        
//        if hrs == 0 {
//            cell.textLabel?.text = "Session \(session.sessionNumber)\t\t\t\t\t\t  \(mins)min \(secs)s"
//        } else {
//            cell.textLabel?.text = "Session \(session.sessionNumber)\t\t\t\t\t\t  \(hrs)hrs \(mins)min"
//        }
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let selectedSession = DataStore.shared.sessions[indexPath.row]
//        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
//        guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SessionSummaryVC") as? SessionSummaryViewController else { return }
//        summaryVC.sessionData = selectedSession
//        let nav = UINavigationController(rootViewController: summaryVC)
//        nav.modalPresentationStyle = .formSheet
//        present(nav, animated: true)
//    }
//    
//    // MARK: - Helpers
//    private func updateButtons() {
//        beatButton.setTitle(selectedBeat, for: .normal)
//        paceButton.setTitle(selectedPace, for: .normal)
//    }
//    
//    private func bpmForPace(_ pace: String) -> Int {
//        PaceConfig.bpm(for: pace)
//    }
//    
//    private func checkGoalStatus() {
//        guard let goal = DataStore.shared.dailyGoalSession else {
//            DurationPicker.isUserInteractionEnabled = true
//            DurationPicker.alpha = 1.0
//            startButton.setTitle("Start", for: .normal)
//            return
//        }
//        
//        let isIncomplete = goal.elapsedSeconds < goal.requestedDurationSeconds
//        if isIncomplete {
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
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        DurationPicker.dataSource = self
//        DurationPicker.delegate = self
//        DurationPicker.selectRow(10, inComponent: 1, animated: false)
//        datePickerUIView.applyCardStyle()
//        sessionTableView.dataSource = self
//        sessionTableView.delegate = self
//        sessionTableView.layer.cornerRadius = 30
//        sessionTableView.clipsToBounds = true
//        setupBeatButton()
//        setupPaceButton()
//        updateButtons()
//        paceBeatUIView.applyCardStyle()
//        updateStartButtonState()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        DataStore.shared.cleanupOldSessions()
//        
//        DataStore.shared.printAllSessions()
//        
//        sessionTableView.reloadData()
//        checkGoalStatus()
//        
//        let isEmpty = DataStore.shared.sessions.isEmpty
//        noSessionsOutlet.isHidden = !isEmpty
//        sessionTableView.isHidden = isEmpty
//        
//        tabBarController?.tabBar.isHidden = true
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        tabBarController?.tabBar.isHidden = false
//    }
//    
//    // MARK: - Actions
//    @IBAction func infoButtonTapped(_ sender: UIBarButtonItem) {
//        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
//        guard let infoVC = storyboard.instantiateViewController(withIdentifier: "infoVC") as? RhythmicInfoViewController else { return }
//        infoVC.modalPresentationStyle = .pageSheet
//        present(infoVC, animated: true)
//    }
//    
//    @IBAction func startButtonTapped(_ sender: Any) {
//        let h = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
//        let m = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
//        let total = (h * 3600) + (m * 60)
//        guard total > 0 else { return }
//        
//        let sessionToRun: RhythmicSessionDTO
//        
//        // Resume existing daily goal if applicable
//        if let existingGoal = DataStore.shared.dailyGoalSession,
//           existingGoal.elapsedSeconds < existingGoal.requestedDurationSeconds {
//            sessionToRun = existingGoal
//        } else {
//            // Create a brand new session
//            let newSession = RhythmicSessionDTO(
//                id: UUID(),
//                sessionNumber: DataStore.shared.sessions.count + 1,
//                startDate: Date(),
//                endDate: nil,
//                requestedDurationSeconds: total,
//                elapsedSeconds: 0,
//                beat: selectedBeat,
//                pace: selectedPace
//            )
//            DataStore.shared.add(newSession)
//            sessionToRun = newSession
//        }
//        
//        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
//        guard let destVC = storyboard.instantiateViewController(withIdentifier: "SessionRunningVC") as? SessionRunningViewController else { return }
//        
//        let remaining = sessionToRun.requestedDurationSeconds - sessionToRun.elapsedSeconds
//        destVC.totalSessionDuration = remaining
//        destVC.hrs         = remaining / 3600
//        destVC.minn        = (remaining % 3600) / 60
//        destVC.selectedBeat = sessionToRun.beat
//        destVC.selectedPace = sessionToRun.pace
//        destVC.selectedBPM  = bpmForPace(sessionToRun.pace)
//        destVC.session      = sessionToRun
//        
//        let nav = UINavigationController(rootViewController: destVC)
//        nav.modalPresentationStyle = .formSheet
//        present(nav, animated: true)
//    }
//    
//    func updateStartButtonState() {
//        let h = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
//        let m = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
//        startButton.isEnabled = (h * 3600 + m * 60) > 0
//    }
//    
//    func setupBeatButton() {
//        let optionClosure: UIActionHandler = { [weak self] action in
//            guard let self = self else { return }
//            self.selectedBeat = action.title
//            self.updateButtons()
//        }
//        beatButton.menu = UIMenu(children: [
//            UIAction(title: "Clock", state: .on, handler: optionClosure),
//            UIAction(title: "Grass", handler: optionClosure)
//        ])
//        beatButton.showsMenuAsPrimaryAction = true
//        beatButton.changesSelectionAsPrimaryAction = true
//    }
//    
//    func setupPaceButton() {
//        let optionClosure: UIActionHandler = { [weak self] action in
//            guard let self = self else { return }
//            self.selectedPace = action.title
//            self.updateButtons()
//        }
//        paceButton.menu = UIMenu(children: [
//            UIAction(title: "Slow", state: .on, handler: optionClosure),
//            UIAction(title: "Moderate", handler: optionClosure),
//            UIAction(title: "Fast", handler: optionClosure)
//        ])
//        paceButton.showsMenuAsPrimaryAction = true
//        paceButton.changesSelectionAsPrimaryAction = true
//    }
//    
//    
//
//    
//}
//
//
//
//





//
//  SetGoalViewController.swift
//  Parkinsons
//
//  Cell layout fix: uses UITableViewCell with .value1 style (set in storyboard
//  OR overridden in code below) so session name is left-aligned and time is
//  right-aligned at the trailing edge.
//
//  NOTE: In your storyboard, set the "sessionCell" prototype cell style to
//  "Right Detail" — this makes textLabel left and detailTextLabel right.
//  The code below also works if the style is "Basic" by building the layout
//  programmatically as a fallback.

import UIKit
import CoreData

class SetGoalViewController: UIViewController,
                             UITableViewDataSource, UITableViewDelegate,
                             UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var datePickerUIView:  UIView!
    @IBOutlet weak var DurationPicker:    UIPickerView!
    @IBOutlet weak var beatButton:        UIButton!
    @IBOutlet weak var paceButton:        UIButton!
    @IBOutlet weak var startButton:       UIButton!
    @IBOutlet weak var paceBeatUIView:    UIView!
    @IBOutlet weak var sessionTableView:  UITableView!
    @IBOutlet weak var noSessionsOutlet:  UIStackView!

    // MARK: - State
    private var selectedBeat: String = BeatType.click.rawValue
    private var selectedPace: String = "Slow"
    let dataForColumn1 = Array(0...5)
    let dataForColumn2 = Array(0...59)

    // MARK: - PickerView

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

    // MARK: - TableView

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

        // Use textLabel for the session name (left side)
        cell.textLabel?.text = "Session \(session.sessionNumber)"
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)

        // Use detailTextLabel for the time (right side — requires "Right Detail" cell style)
        // If detailTextLabel is nil (Basic style), fall back to building it in code.
        if let detail = cell.detailTextLabel {
            detail.text      = timeText
            detail.textColor = .secondaryLabel
            detail.font      = .systemFont(ofSize: 16, weight: .regular)
        } else {
            // Fallback: add a right-aligned label programmatically
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
        pushSummary(for: selected)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
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
        sessionTableView.reloadData()
        checkGoalStatus()
        refreshListVisibility()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Helpers

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

    func updateStartButtonState() {
        let h = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
        let m = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
        startButton.isEnabled = (h * 3600 + m * 60) > 0
    }

    // MARK: - Beat / Pace buttons

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

    // MARK: - Navigation

    func pushSummary(for session: RhythmicSessionDTO) {
        let sb = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "SessionSummaryVC")
                as? SessionSummaryViewController else { return }
        vc.sessionData = session
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Actions

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
            self.pushSummary(for: finishedSession)
        }

        runVC.modalPresentationStyle = .pageSheet
        if let sheet = runVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
        }
        present(runVC, animated: true)
    }
}
