//
//  RepeatViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

// Delegate to pass back selected repeat option
protocol RepeatSelectionDelegate: AnyObject {
    func didSelectRepeatOption(_ option: String)
}

class RepeatViewController: UIViewController,
                            UITableViewDataSource,
                            UITableViewDelegate,
                            UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tickButton: UIBarButtonItem!
    @IBOutlet weak var RepeatTableView: UITableView!
    
    // MARK: - Properties
    weak var delegate: RepeatSelectionDelegate?
    var selectedRepeat: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable multiple day selection
        RepeatTableView.allowsMultipleSelection = true
        
        // UI styling
        RepeatTableView.layer.cornerRadius = 10
        RepeatTableView.clipsToBounds = true
        RepeatTableView.backgroundColor = UIColor.systemGray6
        
        // Set table view delegates
        RepeatTableView.delegate = self
        RepeatTableView.dataSource = self
        
        // Restore saved repeat option if user edited before
        if let saved = AddMedicationDataStore.shared.repeatOption {
            selectedRepeat = saved
            updateSelection(saved)
        }
    }
    
    // MARK: - TableView DataSource
    
    /// Number of rows = number of repeat types
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repeatList.count
    }
    
    /// Configure each cell with repeat type (Everyday / weekdays)
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! RepeatTableViewCell
        
        let type = repeatList[indexPath.row]
        cell.configureCell(type: type)
        return cell
    }
    
    // MARK: - TableView Selection
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tappedOption = repeatList[indexPath.row]
        
        // 1. If "Everyday" selected → only allow this option
        if tappedOption.name.lowercased() == "everyday" {
            for i in 0..<repeatList.count {
                repeatList[i].isSelected = (i == indexPath.row)
            }
            selectedRepeat = "Everyday"
            tableView.reloadData()
            return
        }
        
        // 2. If weekday selected → deselect "Everyday"
        if repeatList.first?.name.lowercased() == "everyday" {
            repeatList[0].isSelected = false
        }
        
        // Toggle the selected weekday
        repeatList[indexPath.row].isSelected.toggle()
        
        // Build string of selected days
        let selectedDays = repeatList
            .filter { $0.isSelected }
            .map { $0.name }
        
        selectedRepeat = selectedDays.joined(separator: ", ")
        
        tableView.reloadData()
    }
    
    // MARK: - Helper
    
    /// Updates UI selection when user returns to this screen
    func updateSelection(_ option: String) {
        for i in 0..<repeatList.count {
            repeatList[i].isSelected = (repeatList[i].name == option)
        }
        RepeatTableView.reloadData()
    }
    
    // MARK: - Actions
    
    /// Back button → return to previous screen
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    /// Tick button → save selected repeat option and close
    @IBAction func onTickPressed(_ sender: Any) {
        
        // Get selected days
        let selectedDays = repeatList
            .filter { $0.isSelected }
            .map { $0.name }
        
        // Everyday selected → save all days 1–7
        if selectedDays.contains("Everyday") {
            AddMedicationDataStore.shared.repeatOption = "Everyday"
            AddMedicationDataStore.shared.selectedWeekdayNumbers = [1,2,3,4,5,6,7]
        } else {
            // Map weekday names to weekday numbers
            let weekdayMap: [String: Int] = [
                "Sunday": 1,
                "Monday": 2,
                "Tuesday": 3,
                "Wednesday": 4,
                "Thursday": 5,
                "Friday": 6,
                "Saturday": 7
            ]
            
            // Convert selected names → numbers
            let mapped = selectedDays.compactMap { weekdayMap[$0] }
            
            AddMedicationDataStore.shared.repeatOption =
                selectedDays.joined(separator: ", ")
            AddMedicationDataStore.shared.selectedWeekdayNumbers = mapped
        }
        
        // Send final saved value back to parent screen
        delegate?.didSelectRepeatOption(AddMedicationDataStore.shared.repeatOption!)
        
        // Close screen
        navigationController?.popViewController(animated: true)
    }
}
