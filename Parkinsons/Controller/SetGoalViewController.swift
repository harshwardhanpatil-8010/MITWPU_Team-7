//
//  SetGoalViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class SetGoalViewController: UIViewController, UITableViewDataSource, UIPickerViewDataSource {
    
    
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

    @IBOutlet weak var beatPaceView: UIView!
    @IBOutlet weak var picker: UIPickerView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
        cell.textLabel?.text = "\(session[indexPath.row].title)"
        
        return cell
    }
    
    let dataForColumn1: [String] = ["00","01","02","03","04","05"]
    let dataForColumn2 = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60"]

    
    @IBOutlet weak var sessionTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
//        beatPaceView.applyCardStyle()
        sessionTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // Removes old sessions (yesterday) automatically
//        DataStore.shared.cleanupOldSessions()
//
//        // Refresh your UITableView/CollectionView
//        sessionsTableView.reloadData()
//    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension SetGoalViewController: UIPickerViewDataSource{
//    
//}
extension SetGoalViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
            case 0:
                return dataForColumn1[row]
            case 1:
                return dataForColumn2[row]
            default:
                return nil
            }
    }
}
