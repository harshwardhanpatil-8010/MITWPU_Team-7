//
//  AddMedicationViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.

import UIKit
import CoreData

protocol AddMedicationDelegate: AnyObject {
    func didUpdateMedication()
}

class AddMedicationViewController: UIViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    DoseTableViewCellDelegate,
                                    UnitsAndTypeDelegate,
                                    RepeatSelectionDelegate,
                                    UITextFieldDelegate {

    func didSelectSchedule(type: String, days: [Int]?) {
        selectedScheduleType = type
        selectedScheduleDays = days
        
        repeatLabel.text = Medication.scheduleDisplayText(
            type: type,
            days: days
        )
        
        repeatLabel.textColor = .label
        evaluateTickButtonState()
    }

    
    private var originalMedicationSnapshot: Medication?
    private var selectedScheduleType: String?
    private var selectedScheduleDays: [Int]?

    private let unitPlaceholder = "Add unit"
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
        medicationNameTextField.delegate = self
        strengthLabel.delegate = self
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDoseTableInsets()
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
        
        medicationNameTextField.text = med.medicationName
        typeLabel.text = med.medicationForm
        unitLabel.text = med.medicationUnit
        strengthUnitLabel.text = med.medicationUnit
        
        typeLabel.textColor = .label
        unitLabel.textColor = .label
        strengthUnitLabel.textColor = .label
        
        strengthLabel.text = "\(med.medicationStrength)"
        

        selectedScheduleType = med.medicationScheduleType
        selectedScheduleDays = med.medicationScheduleDays as? [Int]

        repeatLabel.text = Medication.scheduleDisplayText(
            type: med.medicationScheduleType ?? "none",
            days: med.medicationScheduleDays as? [Int]
        )

        repeatLabel.textColor = .label

        repeatLabel.textColor = .label
        
        let doseSet = med.doses as? Set<MedicationDose> ?? []
        doseArray = doseSet
            .sorted { $0.doseTime ?? Date() < $1.doseTime ?? Date() }
            .compactMap { $0.doseTime }


        doseStepper.value = Double(doseArray.count)

        doseTableView.reloadData()
        originalMedicationSnapshot = med
        tickButton.isEnabled = false
    }
    
    private func evaluateTickButtonState() {

        if !isEditMode {

            let nameValid = !(medicationNameTextField.text ?? "")
                .trimmingCharacters(in: .whitespaces).isEmpty

            let strengthValid = !(strengthLabel.text ?? "")
                .trimmingCharacters(in: .whitespaces).isEmpty

            let unitValid = unitLabel.textColor == .label
            let typeValid = typeLabel.textColor == .label

            let repeatValid = selectedScheduleType != nil

            let hasDose = !doseArray.isEmpty

            tickButton.isEnabled =
                nameValid &&
                strengthValid &&
                unitValid &&
                typeValid &&
                repeatValid &&
                hasDose

            return
        }


        guard let original = originalMedicationSnapshot else {
            tickButton.isEnabled = false
            return
        }

        let nameChanged = medicationNameTextField.text != original.medicationName

        let strengthChanged =
            Int16(Int(strengthLabel.text ?? "") ?? 0) != original.medicationStrength

        let unitChanged = unitLabel.text != original.medicationUnit
        let typeChanged = typeLabel.text != original.medicationForm

        let repeatChanged =
            selectedScheduleType != original.medicationScheduleType ||
            (selectedScheduleDays ?? []) != (original.medicationScheduleDays as? [Int] ?? [])

        let originalDoseTimes = (original.doses as? Set<MedicationDose> ?? [])
            .compactMap { $0.doseTime?.timeIntervalSince1970 }
            .sorted()

        let currentDoseTimes = doseArray
            .map { $0.timeIntervalSince1970 }
            .sorted()

        let dosesChanged = originalDoseTimes != currentDoseTimes

        tickButton.isEnabled =
            nameChanged ||
            strengthChanged ||
            unitChanged ||
            typeChanged ||
            repeatChanged ||
            dosesChanged
    }
    
    func renumberDoses() {
        for i in 0..<doseArray.count {
            if let cell = doseTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? DoseTableViewCell {
                cell.doseNumberLabel.text = "\(i + 1)"
            }
        }
    }

    private func updateDoseTableInsets() {
        let bottomInset: CGFloat = deleteButton.isHidden ? 16 : (deleteButton.bounds.height + 56)
        doseTableView.contentInset.bottom = bottomInset
        doseTableView.verticalScrollIndicatorInsets.bottom = bottomInset
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
        vc.preselectedType = selectedScheduleType
        vc.preselectedDays = selectedScheduleDays

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

        let context = PersistenceController.shared.viewContext
        context.delete(med)
        PersistenceController.shared.save(context)


        MedicationNotificationManager.shared.rescheduleAll()

        delegate?.didUpdateMedication()
        dismiss(animated: true)
    }

    
    @IBAction func onTickPressed(_ sender: UIBarButtonItem) {
        
        sender.isEnabled = false

        guard let name = medicationNameTextField.text,
              !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let context = PersistenceController.shared.viewContext

        let medication: Medication

        if isEditMode {
            medication = medicationToEdit
        } else {
            medication = Medication(context: context)
            medication.id = UUID()
            medication.createdAt = Date()
        }

        medication.medicationName = name
        medication.medicationForm = typeLabel.text ?? "Capsule"
        medication.medicationUnit = unitLabel.text ?? "mg"
        medication.medicationStrength = Int16(Int(strengthLabel.text ?? "") ?? 0)
        medication.medicationIconName = UnitAndType.icon(for: typeLabel.text ?? "Capsule")

        medication.medicationScheduleType = selectedScheduleType
        medication.medicationScheduleDays = selectedScheduleDays as NSObject?

        if isEditMode {
            let oldDoses = medication.doses as? Set<MedicationDose> ?? []
            for dose in oldDoses {
                context.delete(dose)
            }
        }

        for date in doseArray {
            let dose = MedicationDose(context: context)
            dose.id = UUID()
            dose.doseTime = date
            dose.doseStatus = "none"
            dose.medication = medication
        }

        PersistenceController.shared.save(context)


        MedicationNotificationManager.shared.rescheduleAll()

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
