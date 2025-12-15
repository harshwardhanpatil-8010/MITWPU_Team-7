//
//  UnitAndTypeViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit
protocol UnitsAndTypeDelegate: AnyObject {
    func didSelectUnitsAndType(unitText: String, selectedType: String)
}

class UnitAndTypeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate  {
    @IBOutlet weak var tickButton: UIBarButtonItem!
    @IBOutlet weak var unitTextField: UITextField!
    weak var delegate: UnitsAndTypeDelegate?
    var selectedType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unitTextField.layer.cornerRadius = 25
        
        unitTextField.clipsToBounds = true
        TypeTableView.layer.cornerRadius = 10
        TypeTableView.clipsToBounds = true
        TypeTableView.backgroundColor = UIColor.systemGray6
        TypeTableView.delegate = self
        TypeTableView.dataSource = self
        unitTextField.delegate = self
        unitTextField.placeholder = "mg"

        unitTextField.text = UnitAndTypeStore.shared.savedUnit

           // Restore previous type selection
        if let savedType = UnitAndTypeStore.shared.savedType, !savedType.isEmpty {
            selectedType = savedType

            if let index = unitAndType.firstIndex(where: { $0.name == savedType }) {
                unitAndType[index].isSelected = true
            }
        }


           TypeTableView.reloadData()

        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        unitAndType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UnitAndTypeTableViewCell
        let type = unitAndType[indexPath.row]
        cell.configureCell(type: type)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedType = unitAndType[indexPath.row].name

        for i in 0..<unitAndType.count {
            unitAndType[i].isSelected = (i == indexPath.row)
        }
        UnitAndTypeStore.shared.savedType = selectedType!
        print(unitAndType)
        tableView.reloadData()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()   // hides keyboard
        return true
    }
    
    

    @IBAction func onTickPressed(_ sender: UIBarButtonItem) {
        guard let text = unitTextField.text,
                  let type = selectedType else {
                return
            }
        UnitAndTypeStore.shared.savedUnit = text
        UnitAndTypeStore.shared.savedType = type

            delegate?.didSelectUnitsAndType(unitText: text, selectedType: type)

            dismiss(animated: true)
    }
    @IBOutlet weak var TypeTableView: UITableView!
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
