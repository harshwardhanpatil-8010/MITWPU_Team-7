//
//  AddMedicationViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

// MARK: - Delegates
protocol AddMedicationDelegate: AnyObject {
    func didUpdateMedication()
}

class AddMedicationViewController: UIViewController,
                                   UITableViewDelegate,
                                   UITableViewDataSource,
                                   DoseTableViewCellDelegate,
                                   UnitsAndTypeDelegate,
                                   RepeatSelectionDelegate,UITextFieldDelegate {
    
    // ---------------------------------------------------------
    // MARK: - Properties
    // ---------------------------------------------------------
    weak var delegate: AddMedicationDelegate?
    var isEditMode = false
    var medicationToEdit: Medication!
    var doseArray: [Date] = [Date()]
    var doseCount: Int = 1     // tracks number of dose rows
    
    // ---------------------------------------------------------
    // MARK: - Outlets
    // ---------------------------------------------------------
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var strengthLabel: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var medicationNameTextField: UITextField!
    @IBOutlet weak var strengthUnitLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var repeatStack: UIStackView!
    @IBOutlet weak var unitandTypeStack: UIStackView!
    @IBOutlet weak var doseStepper: UIStepper!
    @IBOutlet weak var doseTableView: UITableView!
    @IBOutlet weak var uiStackView: UIStackView!
    
    // ---------------------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        medicationNameTextField.delegate = self
        strengthLabel.delegate = self
        
        // setup UI + hide delete button if adding new medication
        deleteButton.isHidden = !isEditMode
        backgroundView.layer.cornerRadius = 16
        
        // configure tableView and stepper
        doseTableView.dataSource = self
        doseTableView.delegate = self
        doseStepper.value = Double(doseArray.count)
        
        // enable tapping on stacks
        repeatStack.isUserInteractionEnabled = true
        unitandTypeStack.isUserInteractionEnabled = true
        
        // pre-fill UI when editing existing medication
        if isEditMode {
            fillFieldsForEditing()
            deleteButton.isHidden = false
        }
        
        // load last selected repeat value
        if let savedRepeat = AddMedicationDataStore.shared.repeatOption {
            repeatLabel.text = savedRepeat
        }
        
        // add tap gesture for repeat selection
        repeatStack.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(repeatStackTapped))
        )
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh displayed units & type (only when adding new)
        if !isEditMode {
            unitLabel.text = UnitAndTypeStore.shared.savedUnit ?? "mg"
            strengthUnitLabel.text = UnitAndTypeStore.shared.savedUnit ?? "mg"
            typeLabel.text = UnitAndTypeStore.shared.savedType ?? "Capsule"
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        // ensure fields reload properly in edit mode
//        if isEditMode { fillFieldsForEditing() }
//    }
    
    // ---------------------------------------------------------
    // MARK: - Helpers
    // ---------------------------------------------------------
    
    /// Updates label color if showing placeholder text
    func updateLabelPlaceholderStyle(label: UILabel, placeholder: String) {
        label.textColor = (label.text == placeholder) ? .systemGray2 : .label
    }
    
    /// Returns SF Symbol name based on medication type
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
        default: return "tablet"
        }
    }
    
    /// Loads all medication fields when editing an existing medication
    func fillFieldsForEditing() {
        guard let med = medicationToEdit else { return }
        
        medicationNameTextField.text = med.name
        
        typeLabel.text = med.form
        typeLabel.textColor = .label
        
        unitLabel.text = med.unit
        strengthUnitLabel.text = med.unit
        unitLabel.textColor = .label
        strengthUnitLabel.textColor = .label
        
        if let strength = med.strength {
            strengthLabel.text = "\(strength)"
            strengthLabel.textColor = .label
        } else {
            strengthLabel.text = "10"
            strengthLabel.textColor = .systemGray2
        }
        
        repeatLabel.text = med.schedule.displayString()
        repeatLabel.textColor = .label
        
        doseArray = med.doses.map { $0.time }
        doseTableView.reloadData()
        
        updateStepperValue()
    }
    
    /// Syncs stepper value after modifying dose count
    func updateStepperValue() {
        doseStepper.value = Double(doseArray.count)
    }
    
    /// Renumbers dose labels after deleting rows
    func renumberDoses() {
        for i in 0..<doseArray.count {
            if let cell = doseTableView.cellForRow(at: IndexPath(row: i, section: 0))
                as? DoseTableViewCell {
                cell.doseNumberLabel.text = "\(i + 1)"
            }
        }
    }
    
    // ---------------------------------------------------------
    // MARK: - Actions
    // ---------------------------------------------------------
    
    /// Handles back button press
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Opens Units + Type screen using push navigation
    ///
    ///
    
    @IBAction func onUnitStackTapped(_ sender: UITapGestureRecognizer) {
                let storyboard = UIStoryboard(name: "Medication", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "UnitAndTypeVC")
                        as? UnitAndTypeViewController else { return }
        
                vc.delegate = self
                navigationController?.pushViewController(vc, animated: true)
    }
    
//    @IBAction func onUnitStackTapped(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "UnitAndTypeVC")
//                as? UnitAndTypeViewController else { return }
//        
//        vc.delegate = self
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    /// Opens Repeat screen using push navigation
    @IBAction func repeatStackTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "RepeatVC")
                as? RepeatViewController else { return }
        
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Handles stepper increase/decrease to add/remove dose rows
    @IBAction func doseStepperChanged(_ sender: UIStepper) {
        let newCount = Int(sender.value)
        
        if newCount > doseArray.count {
            doseArray.append(Date())
        } else {
            doseArray.removeLast()
        }
        
        doseTableView.reloadData()
    }
    
    /// Deletes medication in edit mode
    @IBAction func deleteMedication(_ sender: UIButton) {
        guard let med = medicationToEdit else { return }
        MedicationDataStore.shared.deleteMedication(med.id)
        dismiss(animated: true)
    }
    
    /// Saves medication (new or updated)
    @IBAction func onTickPressed(_ sender: UIBarButtonItem) {
        let strengthValue = Int(strengthLabel.text ?? "")
        guard let name = medicationNameTextField.text, !name.isEmpty else { return }
        
        let medicationID = isEditMode ? medicationToEdit.id : UUID()
        let repeatText = repeatLabel.text ?? "Everyday"
        
        // determine schedule rule
        let schedule: RepeatRule
        switch repeatText.lowercased() {
        case "everyday": schedule = .everyday
        case "none": schedule = .none
        default: schedule = .weekly(AddMedicationDataStore.shared.selectedWeekdayNumbers)
        }
        
        // build all dose objects
        let updatedDoses = doseArray.map { date in
            MedicationDose(
                id: UUID(),
                time: date,
                status: .none,
                medicationID: medicationID
            )
        }
        
        // update existing medication
        if isEditMode {
            MedicationDataStore.shared.updateMedication(
                originalID: medicationToEdit.id,
                newName: name,
                newForm: typeLabel.text ?? "Capsule",
                newSchedule: schedule,
                newDoses: updatedDoses,
                newUnit: unitLabel.text ?? "mg",
                newStrength: strengthValue
            )
        }
        // create new medication
        else {
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
}

// ---------------------------------------------------------
// MARK: - Extensions (Delegates)
// ---------------------------------------------------------
extension AddMedicationViewController {
    
    /// Receives selected unit + type from UnitAndTypeVC
    func didSelectUnitsAndType(unitText: String, selectedType: String) {
        unitLabel.text = unitText
        typeLabel.text = selectedType
        strengthUnitLabel.text = unitText
        
        unitLabel.textColor = .label
        typeLabel.textColor = .label
        strengthUnitLabel.textColor = .label
    }
    
    /// Receives selected repeat option from RepeatVC
    func didSelectRepeatOption(_ option: String) {
        repeatLabel.text = option
        repeatLabel.textColor = .label
        AddMedicationDataStore.shared.repeatOption = option
    }

    
    /// Updates dose time when user changes time picker
    func didUpdateTime(cell: DoseTableViewCell, newTime: Date) {
        if let indexPath = doseTableView.indexPath(for: cell) {
            doseArray[indexPath.row] = newTime
        }
    }
}

// ---------------------------------------------------------
// MARK: - TableView DataSource + Delegate
// ---------------------------------------------------------
extension AddMedicationViewController {
    
    /// Number of dose rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        doseArray.count
    }
    
    /// Configure each dose row
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoseCell",
                                                 for: indexPath) as! DoseTableViewCell
        
        cell.delegate = self
        cell.doseNumberLabel.text = "\(indexPath.row + 1)"
        cell.timePicker.date = doseArray[indexPath.row]
        
        return cell
    }
    
    /// Handles delete button inside dose row
    func didTapDelete(cell: DoseTableViewCell) {
        guard let indexPath = doseTableView.indexPath(for: cell) else { return }
        
        doseArray.remove(at: indexPath.row)
        doseTableView.deleteRows(at: [indexPath], with: .fade)
        doseStepper.value = Double(doseArray.count)
        
        renumberDoses()
    }
}
