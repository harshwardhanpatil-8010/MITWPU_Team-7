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

class AddMedicationViewController: UIViewController,
                                   UITableViewDelegate,
                                   UITableViewDataSource,
                                   DoseTableViewCellDelegate,
                                   UnitsAndTypeDelegate,
                                   RepeatSelectionDelegate {
    func didSelectRepeatRule(_ rule: RepeatRule) {
        selectedRepeatRule = rule
        repeatLabel.text = rule.displayString()
        repeatLabel.textColor = .label
        evaluateTickButtonState()
    }
    
    private var originalMedicationSnapshot: Medication?
    private var selectedRepeatRule: RepeatRule = .everyday
    private let unitPlaceholder = "Add unit,"
    private let typePlaceholder = "Select type"
    private let repeatPlaceholder = "Select days"

    weak var delegate: AddMedicationDelegate?
    var isEditMode: Bool = false
    var medicationToEdit: Medication!
    var doseArray: [Date] = [Date()]
    
    @IBOutlet weak var tickButton: UIBarButtonItem!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tickButton.isEnabled = false

        medicationNameTextField.addAction(
            UIAction { [weak self] _ in
                self?.evaluateTickButtonState()
            },
            for: .editingChanged
        )

        strengthLabel.addAction(
            UIAction { [weak self] _ in
                self?.evaluateTickButtonState()
            },
            for: .editingChanged
        )


        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        deleteButton.isHidden = !isEditMode
        backgroundView.layer.cornerRadius = 16
        doseTableView.dataSource = self
        doseTableView.delegate = self
        doseStepper.value = Double(doseArray.count)
        
        repeatStack.isUserInteractionEnabled = true
        unitandTypeStack.isUserInteractionEnabled = true
        
        if isEditMode {
            fillFieldsForEditing()
            navigationItem.title = "Edit Medication"
            deleteButton.isHidden = false
        }
        if !isEditMode {
            UnitAndTypeStore.shared.reset()
            resetUnitAndTypeUI()
        }
        
        repeatStack.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(repeatStackTapped))
        )
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func didSelectUnitsAndType(unitText: String, selectedType: String) {
        unitLabel.attributedText = nil
        typeLabel.attributedText = nil
        strengthUnitLabel.attributedText = nil

        unitLabel.text = unitText
        typeLabel.text = selectedType
        strengthUnitLabel.text = unitText

        unitLabel.textColor = .label
        typeLabel.textColor = .label
        strengthUnitLabel.textColor = .label

        evaluateTickButtonState()
    }
    
    private func resetUnitAndTypeUI() {
        unitLabel.text = unitPlaceholder
        typeLabel.text = typePlaceholder
        strengthUnitLabel.text = "Units"

        unitLabel.textColor = .placeholderText
        typeLabel.textColor = .placeholderText
        strengthUnitLabel.textColor = .placeholderText
    }
    
    func didUpdateTime(cell: DoseTableViewCell, newTime: Date) {
        if let indexPath = doseTableView.indexPath(for: cell) {
            doseArray[indexPath.row] = newTime
            evaluateTickButtonState()
        }
    }
    
    func fillFieldsForEditing() {
        guard let med = medicationToEdit else { return }

        medicationNameTextField.text = med.name
        typeLabel.text = med.form
        unitLabel.text = med.unit
        strengthUnitLabel.text = med.unit

        typeLabel.textColor = .label
        unitLabel.textColor = .label
        strengthUnitLabel.textColor = .label

        if let strength = med.strength {
            strengthLabel.text = "\(strength)"
        }

        selectedRepeatRule = med.schedule
        repeatLabel.text = med.schedule.displayString()
        repeatLabel.textColor = .label

        doseArray = med.doses.map { $0.time }

        doseStepper.value = Double(doseArray.count)

        doseTableView.reloadData()
        originalMedicationSnapshot = med
        tickButton.isEnabled = false
    }

    private func evaluateTickButtonState() {
        if !isEditMode {
            let text = medicationNameTextField.text ?? ""
            tickButton.isEnabled = !text.trimmingCharacters(in: .whitespaces).isEmpty
            return
        }

        guard let original = originalMedicationSnapshot else {
            tickButton.isEnabled = false
            return
        }

        let nameChanged = medicationNameTextField.text != original.name
        let strengthChanged = Int(strengthLabel.text ?? "") != original.strength
        let unitChanged = unitLabel.text != original.unit
        let typeChanged = typeLabel.text != original.form
        let repeatChanged = selectedRepeatRule != original.schedule
        let dosesChanged = doseArray.map { $0.timeIntervalSince1970 } != original.doses.map { $0.time.timeIntervalSince1970 }

        tickButton.isEnabled = nameChanged || strengthChanged || unitChanged || typeChanged || repeatChanged || dosesChanged
    }
    
    func renumberDoses() {
        for i in 0..<doseArray.count {
            if let cell = doseTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? DoseTableViewCell {
                cell.doseNumberLabel.text = "\(i + 1)"
            }
        }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onUnitStackTapped(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "UnitAndTypeVC") as? UnitAndTypeViewController else { return }
        
        vc.delegate = self
        vc.selectedUnit = unitLabel.textColor == .label ? unitLabel.text : nil
        vc.selectedType = typeLabel.textColor == .label ? typeLabel.text : nil

        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func repeatStackTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "RepeatVC") as? RepeatViewController else { return }

        vc.delegate = self
        vc.preselectedSchedule = selectedRepeatRule
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func doseStepperChanged(_ sender: UIStepper) {
        let newCount = Int(sender.value)
        if newCount > doseArray.count {
            doseArray.append(Date())
        } else {
            doseArray.removeLast()
        }
        doseTableView.reloadData()
        evaluateTickButtonState()
    }
    
    @IBAction func deleteMedication(_ sender: UIButton) {
        guard let med = medicationToEdit else { return }
        MedicationDataStore.shared.deleteMedication(med.id)
        delegate?.didUpdateMedication()
        dismiss(animated: true)
    }
    
    @IBAction func onTickPressed(_ sender: UIBarButtonItem) {
        let strengthValue = Int(strengthLabel.text ?? "")
        guard let name = medicationNameTextField.text, !name.isEmpty else { return }
        let medicationID = isEditMode ? medicationToEdit.id : UUID()
        let schedule = selectedRepeatRule
        let updatedDoses = doseArray.map { date in
            MedicationDose(id: UUID(), time: date, status: .none, medicationID: medicationID)
        }
       
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
        } else {
            let newMedication = Medication(
                id: medicationID,
                name: name,
                form: typeLabel.text ?? "Capsule",
                unit: unitLabel.text ?? "mg",
                strength: strengthValue,
                iconName: UnitAndType.icon(for: typeLabel.text ?? "Capsule"),
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

extension AddMedicationViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        doseArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoseCell", for: indexPath) as! DoseTableViewCell
        cell.delegate = self
        cell.doseNumberLabel.text = "\(indexPath.row + 1)"
        cell.timePicker.date = doseArray[indexPath.row]
        return cell
    }
 
    func didTapDelete(cell: DoseTableViewCell) {
        guard let indexPath = doseTableView.indexPath(for: cell) else { return }
        doseArray.remove(at: indexPath.row)
        doseTableView.deleteRows(at: [indexPath], with: .fade)
        doseStepper.value = Double(doseArray.count)
        renumberDoses()
        evaluateTickButtonState()
    }
}

