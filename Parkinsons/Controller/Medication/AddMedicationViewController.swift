//
//  AddMedicationViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit
protocol AddMedicationDelegate: AnyObject {
    func didUpdateMedication()
}

class AddMedicationViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, DoseTableViewCellDelegate, UnitsAndTypeDelegate, RepeatSelectionDelegate {
    weak var delegate: AddMedicationDelegate?
    var isEditMode = false
    var medicationToEdit: Medication!


    @IBOutlet weak var strengthLabel: UITextField!
    @IBOutlet weak var deleteButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

            if !isEditMode {
                if let unit = UnitAndTypeStore.shared.savedUnit {
                    unitLabel.text = unit
                    strengthUnitLabel.text = unit
                } else {
                    unitLabel.text = "mg"
                    strengthUnitLabel.text = "mg"
                }

                if let medType = UnitAndTypeStore.shared.savedType {
                    typeLabel.text = medType
                } else {
                    typeLabel.text = "Capsule"
                }
            }
    }
    
    func updateLabelPlaceholderStyle(label: UILabel, placeholder: String) {
        if label.text == placeholder {
            label.textColor = .systemGray2       // light grey placeholder
        } else {
            label.textColor = .label             // normal text color
        }
    }
    
    
    func didSelectRepeatOption(_ option: String) {
        repeatLabel.text = option
        repeatLabel.textColor = .label
    }
    
    
    @IBOutlet weak var medicationNameTextField: UITextField!
    @IBOutlet weak var strengthUnitLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    func didSelectUnitsAndType(unitText: String, selectedType: String) {
        unitLabel.text = unitText
        typeLabel.text = selectedType
        strengthUnitLabel.text = unitText
        
        unitLabel.textColor = .label
        typeLabel.textColor = .label
        strengthUnitLabel.textColor = .label
        
    }
    func iconForType(_ type: String) -> String {
        switch type.lowercased() {
        case "capsule": return "capsule"
        case "tablet": return "tablet"
        case "liquid": return "liquid"
        case "cream": return "cream"
        case "device": return "device"
        case "drops": return "drops"
        case "foam": return "foam"
        case "gel": return "gel"
        case "powder": return "powder"
        case "spray": return "spray"
        default: return "tablet"   // fallback icon
        }
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
            cell.doseNumberLabel.text = "\(indexPath.row + 1)"

            // SET SAVED TIME HERE
            cell.timePicker.date = doseArray[indexPath.row]

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
        deleteButton.isHidden = !isEditMode
        
        uiStackView.layer.cornerRadius = 30
        uiStackView.clipsToBounds = true
        doseTableView.dataSource = self
        doseTableView.delegate = self
        doseStepper.value = Double(doseArray.count)
        unitandTypeStack.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
        repeatStack.isUserInteractionEnabled = true
        if isEditMode {
                fillFieldsForEditing()
                deleteButton.isHidden = false
            } else {
                deleteButton.isHidden = true
            }
        if let savedRepeat = AddMedicationDataStore.shared.repeatOption {
            repeatLabel.text = savedRepeat
        }
        
        //  Add tap gesture for Repeat Stack
        repeatStack.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onRepeatStackTapped))
        )
        



        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isEditMode {
            fillFieldsForEditing()
        }
    }

    
    func fillFieldsForEditing() {
        guard let med = medicationToEdit else { return }

        medicationNameTextField.text = med.name
        typeLabel.text = med.form
        typeLabel.textColor = .label

        // UNIT
        unitLabel.text = med.unit
        strengthUnitLabel.text = med.unit
        unitLabel.textColor = .label
        strengthUnitLabel.textColor = .label

        
        // 3. STRENGTH VALUE
        if let strength = med.strength {
            strengthLabel.text = "\(strength)"
            strengthLabel.textColor = .label
        } else {
            strengthLabel.text = "10"   // or "" or placeholder
            strengthLabel.textColor = .systemGray2
        }

        // 4. STRENGTH UNIT (same as unit)
        strengthUnitLabel.text = med.unit
        strengthUnitLabel.textColor = .label


        // REPEAT
        repeatLabel.text = med.schedule.displayString()
        repeatLabel.textColor = .label

        // DOSES
        doseArray = med.doses.map { $0.time }
        doseTableView.reloadData()
        updateStepperValue()
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
    
    func didUpdateTime(cell: DoseTableViewCell, newTime: Date) {
        if let indexPath = doseTableView.indexPath(for: cell) {
            doseArray[indexPath.row] = newTime
            print("Updated dose time for row \(indexPath.row): \(newTime)")
        }
    }

    @IBAction func deleteMedication(_ sender: UIButton) {
        guard let med = medicationToEdit else { return }

            MedicationDataStore.shared.deleteMedication(med.id)

            dismiss(animated: true)
    }
    @IBAction func onTickPressed(_ sender: UIBarButtonItem) {
        let strengthValue = Int(strengthLabel.text ?? "")

        guard let name = medicationNameTextField.text, !name.isEmpty else { return }

            // Determine correct ID early
            let medicationID: UUID = isEditMode ? medicationToEdit.id : UUID()

            let repeatText = repeatLabel.text ?? "Everyday"
            let schedule: RepeatRule

            switch repeatText.lowercased() {
            case "everyday": schedule = .everyday
            case "none": schedule = .none
            default: schedule = .weekly(AddMedicationDataStore.shared.selectedWeekdayNumbers)
            }

            // Generate doses with SAFE medicationID
            let updatedDoses = doseArray.map { date in
                MedicationDose(
                    id: UUID(),
                    time: date,
                    status: .none,
                    medicationID: medicationID
                )
            }

            if isEditMode {
                // UPDATE existing medication
                MedicationDataStore.shared.updateMedication(
                    originalID: medicationToEdit.id,
                    newName: name,
                    newForm: typeLabel.text ?? "Capsule",
                    newSchedule: schedule,
                    newDoses: updatedDoses,
                    newUnit: unitLabel.text ?? "mg",
                    newStrength: strengthValue
                )

            } else {
                // ADD new medication
                let newMedication = Medication(
                    id: medicationID,
                    name: name,
                    form: typeLabel.text ?? "Capsule",
                    unit: unitLabel.text ?? "mg",
                    strength: strengthValue,
                    iconName: iconForType(typeLabel.text ?? "Capsule"),
                    schedule: schedule,
                    doses: updatedDoses,
                    createdAt: Date()
                )

                MedicationDataStore.shared.addMedication(newMedication)
            }

            delegate?.didUpdateMedication()
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

