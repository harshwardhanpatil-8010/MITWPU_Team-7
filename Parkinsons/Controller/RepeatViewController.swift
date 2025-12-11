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

        for i in 0..<repeatList.count {
            repeatList[i].isSelected = (i == indexPath.row)
        }
        print(repeatList)
        selectedRepeat = repeatList[indexPath.row].name
        tableView.reloadData()
    }

    
    func updateSelection(_ option: String) {
            for i in 0..<repeatList.count {
                repeatList[i].isSelected = (repeatList[i].name == option)
            }
            RepeatTableView.reloadData()
        }
    
    
    @IBAction func onTickPressed(_ sender: Any) {
        guard let selected = selectedRepeat else { return }

                // Save to DataStore
                AddMedicationDataStore.shared.repeatOption = selected

                delegate?.didSelectRepeatOption(selected)
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
