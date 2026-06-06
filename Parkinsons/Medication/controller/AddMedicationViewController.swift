// AddMedicationViewController.swift
// Parkinsons
//

import UIKit
import CoreData

struct DoseData {
    var dose: MedicationDose?
    var period: String
    var startTime: Date
    var endTime: Date
}

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
        repeatLabel.text      = Medication.scheduleDisplayText(type: type, days: days)
        repeatLabel.textColor = .label
        evaluateTickButtonState()
    }

    private var originalMedicationSnapshot: Medication?
    private var selectedScheduleType: String?
    private var selectedScheduleDays: [Int]?

    private let unitPlaceholder   = "Add unit"
    private let typePlaceholder   = "Select type"

    weak var delegate: AddMedicationDelegate?
    var isEditMode: Bool   = false
    var medicationToEdit: Medication!
    var doseArray: [DoseData]  = [DoseData(dose: nil, period: "Morning", startTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(), endTime: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date()) ?? Date())]

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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tickButton.isEnabled = false

        medicationNameTextField.addAction(
            UIAction { [weak self] _ in self?.evaluateTickButtonState() },
            for: .editingChanged
        )
        medicationNameTextField.delegate = self

        strengthLabel.keyboardType = .numberPad
        strengthLabel.delegate     = self
        strengthLabel.addAction(
            UIAction { [weak self] _ in self?.evaluateTickButtonState() },
            for: .editingChanged
        )

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        strengthLabel.inputAccessoryView = toolbar

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        deleteButton.isHidden             = !isEditMode
        backgroundView.layer.cornerRadius = 16
        doseTableView.dataSource          = self
        doseTableView.delegate            = self
        doseStepper.value                 = Double(doseArray.count)

        repeatStack.isUserInteractionEnabled     = true
        unitandTypeStack.isUserInteractionEnabled = true

        if isEditMode {
            fillFieldsForEditing()
            navigationItem.title  = "Edit Medication"
            deleteButton.isHidden = false
        } else {
            UnitAndTypeStore.shared.reset()
            resetUnitAndTypeUI()
        }

        repeatStack.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(repeatStackTapped))
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDoseTableInsets()
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard textField == strengthLabel else { return true }

        if string.isEmpty { return true }

        let allowedChars = CharacterSet.decimalDigits
        guard string.unicodeScalars.allSatisfy({ allowedChars.contains($0) }) else { return false }

        let current    = (textField.text ?? "") as NSString
        let newText    = current.replacingCharacters(in: range, with: string)
        if newText.hasPrefix("0") { return false }

        return true
    }

    // MARK: - Helpers

    @objc private func dismissKeyboard() { view.endEditing(true) }

    func didSelectUnitsAndType(unitText: String, selectedType: String) {
        unitLabel.attributedText        = nil
        typeLabel.attributedText        = nil
        strengthUnitLabel.attributedText = nil

        unitLabel.text         = unitText
        typeLabel.text         = selectedType
        strengthUnitLabel.text = unitText

        unitLabel.textColor         = .label
        typeLabel.textColor         = .label
        strengthUnitLabel.textColor = .label

        evaluateTickButtonState()
    }

    private func resetUnitAndTypeUI() {
        unitLabel.text         = unitPlaceholder
        typeLabel.text         = typePlaceholder
        strengthUnitLabel.text = "Units"

        unitLabel.textColor         = .placeholderText
        typeLabel.textColor         = .placeholderText
        strengthUnitLabel.textColor = .placeholderText
    }

    func didUpdateDose(cell: DoseTableViewCell, period: String, startTime: Date, endTime: Date) {
        if let indexPath = doseTableView.indexPath(for: cell) {
            doseArray[indexPath.row].period = period
            doseArray[indexPath.row].startTime = startTime
            doseArray[indexPath.row].endTime = endTime
            evaluateTickButtonState()
        }
    }

    // MARK: - Edit mode fill

    func fillFieldsForEditing() {
        guard let med = medicationToEdit else { return }

        medicationNameTextField.text = med.medicationName
        typeLabel.text               = med.medicationForm
        unitLabel.text               = med.medicationUnit
        strengthUnitLabel.text       = med.medicationUnit

        typeLabel.textColor         = .label
        unitLabel.textColor         = .label
        strengthUnitLabel.textColor = .label

        let strength = Int(med.medicationStrength)
        strengthLabel.text = strength > 0 ? "\(strength)" : ""

        selectedScheduleType = med.medicationScheduleType
        selectedScheduleDays = med.medicationScheduleDays as? [Int]

        repeatLabel.text = Medication.scheduleDisplayText(
            type: med.medicationScheduleType ?? "none",
            days: med.medicationScheduleDays as? [Int]
        )
        repeatLabel.textColor = .label

        let doseSet = med.doses as? Set<MedicationDose> ?? []
        doseArray = doseSet
            .sorted { $0.doseTime ?? Date() < $1.doseTime ?? Date() }
            .map { dose in
                let info = getPeriodAndRange(for: dose)
                return DoseData(dose: dose, period: info.period, startTime: info.rangeStart, endTime: info.rangeEnd)
            }

        doseStepper.value = Double(doseArray.count)
        doseTableView.reloadData()
        originalMedicationSnapshot = med
        tickButton.isEnabled       = false
    }

    // MARK: - Validation

    private func evaluateTickButtonState() {
        if !isEditMode {
            let nameValid     = !(medicationNameTextField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
            let strengthValue = Int(strengthLabel.text ?? "") ?? 0
            let strengthValid = strengthValue > 0           
            let unitValid     = unitLabel.textColor == .label
            let typeValid     = typeLabel.textColor == .label
            let repeatValid   = selectedScheduleType != nil
            let hasDose       = !doseArray.isEmpty

            tickButton.isEnabled = nameValid && strengthValid && unitValid && typeValid && repeatValid && hasDose
            return
        }

        guard let original = originalMedicationSnapshot else {
            tickButton.isEnabled = false
            return
        }

        let strengthValue = Int(strengthLabel.text ?? "") ?? 0
        guard strengthValue > 0 else {
            tickButton.isEnabled = false
            return
        }

        let nameChanged     = medicationNameTextField.text != original.medicationName
        let strengthChanged = Int16(strengthValue) != original.medicationStrength
        let unitChanged     = unitLabel.text != original.medicationUnit
        let typeChanged     = typeLabel.text != original.medicationForm
        let repeatChanged   = selectedScheduleType != original.medicationScheduleType ||
                              (selectedScheduleDays ?? []) != (original.medicationScheduleDays as? [Int] ?? [])

        let originalDosesRepresentation = (original.doses as? Set<MedicationDose> ?? [])
            .sorted { $0.doseTime ?? Date() < $1.doseTime ?? Date() }
            .map { dose -> String in
                let info = getPeriodAndRange(for: dose)
                return "\(info.period)_\(Int(info.rangeStart.timeIntervalSince1970))_\(Int(info.rangeEnd.timeIntervalSince1970))"
            }
        let currentDosesRepresentation = doseArray.map {
            "\($0.period)_\(Int($0.startTime.timeIntervalSince1970))_\(Int($0.endTime.timeIntervalSince1970))"
        }
        let dosesChanged = originalDosesRepresentation != currentDosesRepresentation

        tickButton.isEnabled = nameChanged || strengthChanged || unitChanged ||
                               typeChanged || repeatChanged || dosesChanged
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
        doseTableView.contentInset.bottom                = bottomInset
        doseTableView.verticalScrollIndicatorInsets.bottom = bottomInset
    }

    // MARK: - IBActions

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func onUnitStackTapped(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "UnitAndTypeVC")
                as? UnitAndTypeViewController else { return }
        vc.delegate     = self
        vc.selectedUnit = unitLabel.textColor == .label ? unitLabel.text : nil
        vc.selectedType = typeLabel.textColor == .label ? typeLabel.text : nil
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func repeatStackTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "RepeatVC")
                as? RepeatViewController else { return }
        vc.delegate          = self
        vc.preselectedType   = selectedScheduleType
        vc.preselectedDays   = selectedScheduleDays
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func doseStepperChanged(_ sender: UIStepper) {
        let newCount = Int(sender.value)
        if newCount > doseArray.count {
            let idx = doseArray.count
            let period: String
            let startH: Int
            let endH: Int
            let endM: Int

            if idx == 0 {
                period = "Morning"
                startH = 8; endH = 11; endM = 0
            } else if idx == 1 {
                period = "Afternoon"
                startH = 12; endH = 15; endM = 0
            } else if idx == 2 {
                period = "Evening"
                startH = 17; endH = 20; endM = 0
            } else if idx == 3 {
                period = "Night"
                startH = 21; endH = 23; endM = 59
            } else {
                period = "Morning"
                startH = 8; endH = 11; endM = 0
            }
            let cal = Calendar.current
            let start = cal.date(bySettingHour: startH, minute: 0, second: 0, of: Date()) ?? Date()
            let end = cal.date(bySettingHour: endH, minute: endM, second: 0, of: Date()) ?? Date()
            doseArray.append(DoseData(dose: nil, period: period, startTime: start, endTime: end))
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

        let strengthValue = Int(strengthLabel.text ?? "") ?? 0
        guard strengthValue > 0 else {
            showStrengthError()
            return
        }

        guard
            let name = medicationNameTextField.text,
            !name.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }

        sender.isEnabled = false

        let context    = PersistenceController.shared.viewContext
        let medication: Medication

        if isEditMode {
            medication = medicationToEdit
        } else {
            medication          = Medication(context: context)
            medication.id       = UUID()
            medication.createdAt = Date()
        }

        medication.medicationName      = name
        medication.medicationForm      = typeLabel.text ?? "Capsule"
        medication.medicationUnit      = unitLabel.text ?? "mg"
        medication.medicationStrength  = Int16(strengthValue)
        medication.medicationIconName  = UnitAndType.icon(for: typeLabel.text ?? "Capsule")
        medication.medicationScheduleType = selectedScheduleType
        medication.medicationScheduleDays = selectedScheduleDays as NSObject?

        let oldDoses = isEditMode ? (medication.doses as? Set<MedicationDose> ?? []) : []
        var usedDoses: Set<MedicationDose> = []

        for data in doseArray {
            let dose: MedicationDose
            if let existing = data.dose {
                dose = existing
                usedDoses.insert(existing)
            } else {
                dose = MedicationDose(context: context)
                dose.id = UUID()
                dose.doseStatus = "none"
                dose.medication = medication
            }
            dose.dosePeriod = data.period
            dose.rangeStartTime = data.startTime
            dose.rangeEndTime = data.endTime
            dose.doseTime = data.startTime
        }

        if isEditMode {
            let dosesToDelete = oldDoses.subtracting(usedDoses)
            for dose in dosesToDelete {
                context.delete(dose)
            }
        }

        PersistenceController.shared.save(context)

        MedicationNotificationManager.shared.rescheduleAll()
        delegate?.didUpdateMedication()
        dismiss(animated: true)
    }

    private func showStrengthError() {
        let alert = UIAlertController(
            title: "Invalid Strength",
            message: "Please enter a strength value greater than 0.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func getPeriodAndRange(for dose: MedicationDose) -> (period: String, rangeStart: Date, rangeEnd: Date) {
        if let period = dose.dosePeriod,
           let start = dose.rangeStartTime,
           let end = dose.rangeEndTime {
            return (period, start, end)
        }

        let date = dose.doseTime ?? Date()
        let cal = Calendar.current
        let hour = cal.component(.hour, from: date)

        let period: String
        let startHour: Int
        let endHour: Int
        let endMin: Int

        if hour >= 5 && hour < 12 {
            period = "Morning"
            startHour = 8
            endHour = 11
            endMin = 0
        } else if hour >= 12 && hour < 17 {
            period = "Afternoon"
            startHour = 12
            endHour = 15
            endMin = 0
        } else if hour >= 17 && hour < 21 {
            period = "Evening"
            startHour = 17
            endHour = 20
            endMin = 0
        } else {
            period = "Night"
            startHour = 21
            endHour = 23
            endMin = 59
        }

        let start = cal.date(bySettingHour: startHour, minute: 0, second: 0, of: date) ?? date
        let end = cal.date(bySettingHour: endHour, minute: endMin, second: 0, of: date) ?? date
        return (period, start, end)
    }
}

// MARK: - TableView (Dose rows)

extension AddMedicationViewController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        doseArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoseCell", for: indexPath) as! DoseTableViewCell
        cell.delegate = self
        let data = doseArray[indexPath.row]
        cell.configure(period: data.period, startTime: data.startTime, endTime: data.endTime, doseIndex: indexPath.row + 1)
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
