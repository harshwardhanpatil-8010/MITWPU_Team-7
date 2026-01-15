//
//  SetGoalViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class SetGoalViewController: UIViewController, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate {
    
    @IBOutlet weak var datePickerUIView: UIView!
    
    @IBOutlet weak var DurationPicker: UIPickerView!
    
    @IBOutlet weak var beatButton: UIButton!
    
    @IBOutlet weak var paceButton: UIButton!
    
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var paceBeatUIView: UIView!
    @IBOutlet weak var sessionTableView: UITableView!

    
    @IBOutlet weak var noSessionsOutlet: UIStackView!
    
    
    var startTapsCount: Int = 0
    private let paces = ["Slow", "Moderate", "Fast"]
    private var beats: [String] = []
    private var selectedBeat = "Clock"
    private var selectedPace: String = "Slow"
    let dataForColumn1 = Array(00...05)
    let dataForColumn2 = Array(00...59)
    var selectedHoursString: String {
        let selectedRow = DurationPicker?.selectedRow(inComponent: 0) ?? 0
        let value = dataForColumn1[min(max(0, selectedRow), dataForColumn1.count - 1)]
        return String(value)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return dataForColumn1.count
        case 1:
            return dataForColumn2.count
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: pickerView.frame.width/2, height: 44)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: container.frame.width, height: 44))
        label.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        label.textAlignment = .center
        if component == 0 {
            label.text = "\(dataForColumn1[row]) hours"
        } else {
            label.text = "\(dataForColumn2[row]) min"
        }

        container.addSubview(label)
        return container
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateStartButtonState()
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataStore.shared.sessions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
        let session = DataStore.shared.sessions[indexPath.row]
        let sessionNumber = DataStore.shared.sessions.count - indexPath.row
        let walked = session.elapsedSeconds
        let hrs = walked / 3600
        let mins = walked % 3600 / 60
        let secs = walked % 60
        let displayNum = session.sessionNumber
        
        if hrs == 0 {
            cell.textLabel?.text = "Session \(displayNum)\t\t\t\t\t\t \(mins)min \(secs)s"
        }
        else{
            cell.textLabel?.text = "Session \(displayNum)\t\t\t\t\t\t\(hrs)hrs \(mins)min"
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1. Deselect the row for a clean UI transition
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 2. Get the specific session data for the tapped row
        let selectedSession = DataStore.shared.sessions[indexPath.row]
        
        // 3. Instantiate the Summary View Controller from the storyboard
        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
        guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SessionSummaryVC") as? SessionSummaryViewController else {
            return
        }
        
        // 4. Pass the data to the summary view
        summaryVC.sessionData = selectedSession
        
        // 5. Present the view controller
        // If you want it to look like the start button tap, use a Navigation Controller wrapper
        let nav = UINavigationController(rootViewController: summaryVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    
    private func updateButtons() {
        beatButton.setTitle("\(selectedBeat)", for: .normal)
        paceButton.setTitle("\(selectedPace)", for: .normal)
    }
    private func bpmForPace(_ pace: String) -> Int {
        switch pace {
        case "Slow":
            return 80
        case "Moderate":
            return 120
        case "Fast":
            return 140
        default:
            return 100
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DurationPicker.dataSource = self
        DurationPicker.delegate = self
        DurationPicker.selectRow(10, inComponent: 1, animated: false)
        datePickerUIView.applyCardStyle()
        sessionTableView.dataSource = self
        sessionTableView.layer.cornerRadius = 30
        sessionTableView.clipsToBounds = true
        setupBeatButton()
        setupPaceButton()
        updateButtons()
        paceBeatUIView.applyCardStyle()
        updateStartButtonState()
        sessionTableView.delegate = self

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataStore.shared.cleanupOldSessions()
        sessionTableView.reloadData()
    
        if DataStore.shared.sessions.isEmpty {
            noSessionsOutlet.isHidden = false
            sessionTableView.isHidden = true
        } else {
            noSessionsOutlet.isHidden = true
            sessionTableView.isHidden = false
        }
        
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func infoButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
        guard let infoVC = storyboard.instantiateViewController(withIdentifier: "infoVC") as? RhythmicInfoViewController else {
            return
        }
        infoVC.modalPresentationStyle = .pageSheet
        self.present(infoVC, animated: true, completion: nil)
        
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        let h = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
        let m = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
        let total = (h * 3600) + (m * 60)
        
        guard total > 0 else { return }
        let nextSessionNumber = DataStore.shared.sessions.count + 1
        let newSession = RhythmicSession(
            id: UUID(),
            sessionNumber: nextSessionNumber,
            startDate: Date(),
            endDate: nil,
            requestedDurationSeconds: total,
            elapsedSeconds: 0,
            beat: selectedBeat,
            pace: selectedPace,
            steps: 0,
            distanceKMeters: 0
        )
        
        DataStore.shared.add(newSession)
        
        sessionTableView.reloadData()
        
        noSessionsOutlet.isHidden = true
        sessionTableView.isHidden = false
        
        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
        guard let destVC = storyboard.instantiateViewController(withIdentifier: "SessionRunningVC") as? SessionRunningViewController else { return }
        
        let bpm = bpmForPace(selectedPace)
        destVC.totalSessionDuration = total
        destVC.hrs = h
        destVC.minn = m
        destVC.selectedBeat = selectedBeat
        destVC.selectedPace = selectedPace
        destVC.selectedBPM = bpm
        
        let nav = UINavigationController(rootViewController: destVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    func updateStartButtonState() {
        let h = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
        let m = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
        let total = (h * 3600) + (m * 60)
        
        if total > 0{
            startButton.isEnabled = true
        }
        else {
            startButton.isEnabled = false
        }
    }
    func setupBeatButton(){
        let optionClosure: UIActionHandler = { [weak self] action in
            guard let self = self else { return }
            self.selectedBeat = action.title
            self.updateButtons()
        }
        let option1 = UIAction(title: "Clock",state: .on, handler: optionClosure)
        let option2 = UIAction(title: "Grass", handler: optionClosure)
        let menu  = UIMenu(children: [option1, option2])
        beatButton.menu = menu
        beatButton.showsMenuAsPrimaryAction = true
        beatButton.changesSelectionAsPrimaryAction = true
    }
    
    func setupPaceButton(){
        let optionClosure: UIActionHandler = { [weak self] action in
            guard let self = self else { return }
            self.selectedPace = action.title
            self.updateButtons()
        }
        let option1 = UIAction(title: "Slow",state: .on, handler: optionClosure)
        let option2 = UIAction(title: "Moderate", handler: optionClosure)
        let option3 = UIAction(title: "Fast", handler: optionClosure)
        let menu  = UIMenu(children: [option1, option2, option3])
        paceButton.menu = menu
        paceButton.showsMenuAsPrimaryAction = true
        paceButton.changesSelectionAsPrimaryAction = true
    }
}


