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
   
        RepeatTableView.allowsMultipleSelection = true
        
    
        RepeatTableView.layer.cornerRadius = 10
        RepeatTableView.clipsToBounds = true
//        RepeatTableView.backgroundColor = UIColor.systemGray6
        
       
        RepeatTableView.delegate = self
        RepeatTableView.dataSource = self
        
       
        if let saved = AddMedicationDataStore.shared.repeatOption {
            selectedRepeat = saved
            updateSelection(saved)
        }
    }
    
    // MARK: - TableView DataSource
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repeatList.count
    }
    
    
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
        
    
        if tappedOption.name.lowercased() == "everyday" {
            for i in 0..<repeatList.count {
                repeatList[i].isSelected = (i == indexPath.row)
            }
            selectedRepeat = "Everyday"
            tableView.reloadData()
            return
        }
        
        
        if repeatList.first?.name.lowercased() == "everyday" {
            repeatList[0].isSelected = false
        }
       
        repeatList[indexPath.row].isSelected.toggle()
        
        
        let selectedDays = repeatList
            .filter { $0.isSelected }
            .map { $0.name }
        
        selectedRepeat = selectedDays.joined(separator: ", ")
        
        tableView.reloadData()
    }
    
    // MARK: - Helper
    
   
    func updateSelection(_ option: String) {
        for i in 0..<repeatList.count {
            repeatList[i].isSelected = (repeatList[i].name == option)
        }
        RepeatTableView.reloadData()
    }
    
    // MARK: - Actions
    
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
   
    @IBAction func onTickPressed(_ sender: Any) {
        
       
        let selectedDays = repeatList
            .filter { $0.isSelected }
            .map { $0.name }
 
        if selectedDays.contains("Everyday") {
            AddMedicationDataStore.shared.repeatOption = "Everyday"
            AddMedicationDataStore.shared.selectedWeekdayNumbers = [1,2,3,4,5,6,7]
        } else {
          
            let weekdayMap: [String: Int] = [
                "Sunday": 1,
                "Monday": 2,
                "Tuesday": 3,
                "Wednesday": 4,
                "Thursday": 5,
                "Friday": 6,
                "Saturday": 7
            ]
            
         
            let mapped = selectedDays.compactMap { weekdayMap[$0] }
            
            AddMedicationDataStore.shared.repeatOption =
                selectedDays.joined(separator: ", ")
            AddMedicationDataStore.shared.selectedWeekdayNumbers = mapped
        }
        
       
        delegate?.didSelectRepeatOption(AddMedicationDataStore.shared.repeatOption!)
   
        navigationController?.popViewController(animated: true)
    }
}
