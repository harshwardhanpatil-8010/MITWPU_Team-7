//
//  AddMedicationViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class AddMedicationViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, DoseTableViewCellDelegate, UnitsAndTypeDelegate, RepeatSelectionDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let saved = AddMedicationDataStore.shared.repeatOption {
            repeatLabel.text = saved
        }
    }


    func didSelectRepeatOption(_ option: String) {
        repeatLabel.text = option
    }
    
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    func didSelectUnitsAndType(unitText: String, selectedType: String) {
        unitLabel.text = unitText
        typeLabel.text = selectedType
    }
    
    
    @IBOutlet weak var repeatStack: UIStackView!
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
        repeatStack.isUserInteractionEnabled = true
        if let savedRepeat = AddMedicationDataStore.shared.repeatOption {
                repeatLabel.text = savedRepeat
            }

            //  Add tap gesture for Repeat Stack
            repeatStack.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(onRepeatStackTapped))
            )

        
    }
    @IBAction func onStackTapped(_ sender: Any) {
        print("StackView tapped!")

            let storyboard = UIStoryboard(name: "Medication", bundle: nil)

            // 1. Load the navigation controller
            let nav = storyboard.instantiateViewController(
                withIdentifier: "UnitsAndTypeNav"
            ) as! UINavigationController

            // 2. Get the inner VC
            if let vc = nav.topViewController as? UnitAndTypeViewController {
                vc.delegate = self   // Set delegate BEFORE presenting
            }

            // 3. Present ONCE
            nav.modalPresentationStyle = .pageSheet
            present(nav, animated: true)
        
    }
    
    @objc func goToUnitsAndType() {
        performSegue(withIdentifier: "goToUnitsAndType", sender: self)
    }
//    @objc func onRepeatTapped() {
//        print("Repeat stack tapped!")
//
//        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
//
//        // Load navigation controller
//        let nav = storyboard.instantiateViewController(
//            withIdentifier: "RepeatNav"
//        ) as! UINavigationController
//
//        // Get Repeat VC
//        if let vc = nav.topViewController as? RepeatViewController {
//            vc.delegate = self   //  set delegate
//        }
//
//        nav.modalPresentationStyle = .pageSheet
//        present(nav, animated: true)
//    }
    
    @IBAction func repeatStackTapped(_ sender: Any) {
        onRepeatStackTapped()
    }
    
    @objc func onRepeatStackTapped() {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "RepeatNav") as! UINavigationController

        if let vc = nav.topViewController as? RepeatViewController {
            vc.delegate = self
        }

        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
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
