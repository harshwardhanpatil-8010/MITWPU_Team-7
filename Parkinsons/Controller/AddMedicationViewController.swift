//
//  AddMedicationViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class AddMedicationViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, DoseTableViewCellDelegate {
    
    @IBOutlet weak var unitandTypeStack: UIStackView!
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    var doseArray: [Date] = [Date()]
    func didTapDelete(cell: DoseTableViewCell) {
        guard let indexPath = doseTableView.indexPath(for: cell) else { return }

                // Remove correct dose
                doseArray.remove(at: indexPath.row)

                // Animate removal
                doseTableView.deleteRows(at: [indexPath], with: .fade)

                // Update stepper
                doseStepper.value = Double(doseArray.count)

                // Renumber labels
                renumberDoses()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoseCell",
                                                         for: indexPath) as! DoseTableViewCell

                cell.delegate = self
                cell.doseNumberLabel.text = " \(indexPath.row + 1)"

                return cell
    }
    
    @objc func deleteDose(_ sender: UIButton) {
        if doseCount > 1 {
            doseCount -= 1
            doseTableView.reloadData()
        }
    }
    
    @IBOutlet weak var doseStepper: UIStepper!
    @IBAction func doseStepperChanged(_ sender: UIStepper) {
        let newCount = Int(sender.value)

                if newCount > doseArray.count {
                    doseArray.append(Date())         // add new dose
                } else {
                    doseArray.removeLast()           // remove last dose
                }

                doseTableView.reloadData()
    }
    func updateStepperValue() {
        doseStepper.value = Double(doseArray.count)
    }
    func renumberDoses() {
        for i in 0..<doseArray.count {
                    if let cell = doseTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? DoseTableViewCell {
                        cell.doseNumberLabel.text = "\(i + 1)"
                    }
                }
    }


    
    @IBOutlet weak var doseTableView: UITableView!
    var doseCount: Int = 1
    @IBOutlet weak var uiStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        uiStackView.layer.cornerRadius = 30
        uiStackView.clipsToBounds = true
        doseTableView.dataSource = self
        doseTableView.delegate = self
        doseStepper.value = Double(doseArray.count)
        unitandTypeStack.isUserInteractionEnabled = true
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
