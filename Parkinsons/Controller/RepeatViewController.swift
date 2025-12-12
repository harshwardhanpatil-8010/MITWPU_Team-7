//
//  RepeatViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit
protocol RepeatSelectionDelegate: AnyObject {
    func didSelectRepeatOption(_ option: String)
}

class RepeatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var tickButton: UIBarButtonItem!
    @IBOutlet weak var RepeatTableView: UITableView!
    weak var delegate: RepeatSelectionDelegate?
    var selectedRepeat: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        RepeatTableView.allowsMultipleSelection = true
        RepeatTableView.layer.cornerRadius = 10
        RepeatTableView.clipsToBounds = true
        RepeatTableView.backgroundColor = UIColor.systemGray6
        RepeatTableView.delegate = self
        RepeatTableView.dataSource = self
        // Do any additional setup after loading the view.
        if let saved = AddMedicationDataStore.shared.repeatOption {
                    selectedRepeat = saved
                    updateSelection(saved)
                }
    }
   

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repeatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RepeatTableViewCell
        let type = repeatList[indexPath.row]
        cell.configureCell(type: type)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if repeatList[indexPath.row].name.lowercased() == "everyday" {

                // Select ONLY everyday
                for i in 0..<repeatList.count {
                    repeatList[i].isSelected = (i == indexPath.row)
                }

                selectedRepeat = "Everyday"
                tableView.reloadData()
                return
            }

            // 2. User selected a weekday → must unselect Everyday
            if repeatList.first?.name.lowercased() == "everyday" {
                repeatList[0].isSelected = false  // unselect everyday
            }

            // Toggle weekday selection
            repeatList[indexPath.row].isSelected.toggle()

            // Update final selection list
            let selectedDays = repeatList
                .filter { $0.isSelected }
                .map { $0.name }

            selectedRepeat = selectedDays.joined(separator: ", ")

            tableView.reloadData()
    }

    
    func updateSelection(_ option: String) {
            for i in 0..<repeatList.count {
                repeatList[i].isSelected = (repeatList[i].name == option)
            }
            RepeatTableView.reloadData()
        }
    
    
    @IBAction func onTickPressed(_ sender: Any) {
        let selectedDays = repeatList
                .filter { $0.isSelected }
                .map { $0.name }

            if selectedDays.contains("Everyday") {
                // Save simple string
                AddMedicationDataStore.shared.repeatOption = "Everyday"
                AddMedicationDataStore.shared.selectedWeekdayNumbers = [1,2,3,4,5,6,7]
            } else {

                // Convert weekday names to numbers
                let weekdayMap: [String: Int] = [
                    "Sunday": 1,
                    "Monday": 2,
                    "Tuesday": 3,
                    "Wednesday": 4,
                    "Thursday": 5,
                    "Friday": 6,
                    "Saturday": 7
                ]

                let mappedNumbers = selectedDays.compactMap { weekdayMap[$0] }

                AddMedicationDataStore.shared.repeatOption = selectedDays.joined(separator: ", ")
                AddMedicationDataStore.shared.selectedWeekdayNumbers = mappedNumbers
            }

            delegate?.didSelectRepeatOption(AddMedicationDataStore.shared.repeatOption!)
            dismiss(animated: true)
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
