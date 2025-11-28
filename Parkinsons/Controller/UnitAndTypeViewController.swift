//
//  UnitAndTypeViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class UnitAndTypeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate  {
    @IBOutlet weak var unitTextField: UITextField!
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

        for i in 0..<unitAndType.count {
            unitAndType[i].isSelected = (i == indexPath.row)
        }
        print(unitAndType)
        tableView.reloadData()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()   // hides keyboard
        return true
    }

    

    @IBOutlet weak var TypeTableView: UITableView!
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

        // Do any additional setup after loading the view.
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
