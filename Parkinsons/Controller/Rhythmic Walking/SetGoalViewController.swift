//
//  SetGoalViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class SetGoalViewController: UIViewController, UITableViewDataSource, UIPickerViewDataSource {
    
    @IBAction func infoButtonTapped(_ sender: UIBarButtonItem) {
        let overLay = OverlayPopUp()
        overLay.appear(sender: self)
    }

    private let paces = ["Slow", "Moderate", "Fast"]
    private var beats: [String] = []
    private var selectedBeat = "Clock"
    private var selectedPace: String = "Slow"

    let dataForColumn1 = Array(00...05)
    let dataForColumn2 = Array(00...60)
    //    let dataForColumn1: [String] = ["00","01","02","03","04","05"]
    //    let dataForColumn2 = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60"]

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

    @IBOutlet weak var DurationPicker: UIPickerView!
    @IBOutlet weak var beatButton: UIButton!
    @IBOutlet weak var paceButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    // Computed property if you need a string for the currently selected hours
    var selectedHoursString: String {
        let selectedRow = DurationPicker?.selectedRow(inComponent: 0) ?? 0
        let value = dataForColumn1[min(max(0, selectedRow), dataForColumn1.count - 1)]
        return String(value)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
        cell.textLabel?.text = "\(session[indexPath.row].title)"
        
        return cell
    }
    

    @IBOutlet weak var sessionTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        DurationPicker.dataSource = self
        DurationPicker.delegate = self
        sessionTableView.dataSource = self
        beats = BeatPlayer.shared.availableBeats()
        setupBeatButton()
        setupPaceButton()
        updateButtons()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataStore.shared.cleanupOldSessions()
        sessionTableView.reloadData()
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func startButtonTapped(_ sender: Any) {
        let h = dataForColumn1[DurationPicker.selectedRow(inComponent: 0)]
        let m = dataForColumn2[DurationPicker.selectedRow(inComponent: 1)]
        let total = (h * 3600) + (m * 60)

        guard total > 0 else {
            let alert = UIAlertController(title: "Choose duration", message: "Please select a duration greater than 0.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

//        let bpm = bpmForPace(selectedPace)
//
//        var session = RhythmicSession(durationSeconds: total, beat: selectedBeat, pace: selectedPace)

        let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
        guard let runningVC = storyboard.instantiateViewController(withIdentifier: "SessionRunningVC") as? SessionRunningViewController else { return }
        runningVC.totalSessionDuration = total
//        runningVC.session = session
//        runningVC.selectedBPM = bpm
//        runningVC.selectedBeat = selectedBeat   // now dynamic

        navigationController?.pushViewController(runningVC, animated: true)
    }
    

    @IBAction func beatButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func paceButtonTapped(_ sender: Any) {
    }
    
    func setupBeatButton(){
        let optionClosure: UIActionHandler = { [weak self] action in
                _ = self
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
                _ = self
        }
        let option1 = UIAction(title: "Slow",state: .on, handler: optionClosure)
        let option2 = UIAction(title: "Medium", handler: optionClosure)
        let option3 = UIAction(title: "Fast", handler: optionClosure)
        let menu  = UIMenu(children: [option1, option2, option3])
        paceButton.menu = menu
        paceButton.showsMenuAsPrimaryAction = true
        paceButton.changesSelectionAsPrimaryAction = true
    }
}


extension SetGoalViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(dataForColumn1[row])
        case 1:
            return String(dataForColumn2[row])
        default:
            return nil
        }
    }
}

