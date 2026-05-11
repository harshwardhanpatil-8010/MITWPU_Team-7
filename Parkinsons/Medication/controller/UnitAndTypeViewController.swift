// UnitAndTypeViewController.swift
// Parkinsons

import UIKit

protocol UnitsAndTypeDelegate: AnyObject {
    func didSelectUnitsAndType(unitText: String, selectedType: String)
}

class UnitAndTypeViewController: UIViewController,
                                 UITableViewDataSource,
                                 UITableViewDelegate,
                                 UITextFieldDelegate {

    @IBOutlet weak var tickButton: UIBarButtonItem!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var TypeTableView: UITableView!

    weak var delegate: UnitsAndTypeDelegate?
    var selectedUnit: String?
    var selectedType: String?

    // MARK: - Common unit presets shown in the dropdown
    private let commonUnits = ["mg", "ml", "mcg", "g", "IU", "%", "mEq", "mmol"]

    // MARK: - Lifecycle

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        unitTextField.layer.cornerRadius = unitTextField.frame.height / 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tickButton.isEnabled = false

        setupUnitTextField()

        TypeTableView.layer.cornerRadius = 25
        TypeTableView.clipsToBounds      = true
        TypeTableView.delegate           = self
        TypeTableView.dataSource         = self


        unitTextField.text = selectedUnit

        for i in 0..<unitAndType.count { unitAndType[i].isSelected = false }
        if let selectedType,
           let index = unitAndType.firstIndex(where: { $0.name == selectedType }) {
            unitAndType[index].isSelected = true
        }

        TypeTableView.reloadData()
        updateTickButtonState()
    }

    // MARK: - Unit text field setup

    private func setupUnitTextField() {

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        unitTextField.leftView = paddingView
        unitTextField.leftViewMode = .always

        unitTextField.borderStyle = .none
        unitTextField.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        unitTextField.delegate = self
        unitTextField.autocorrectionType = .no
        unitTextField.spellCheckingType = .no


        let dropdownButton = UIButton(type: .system)
        dropdownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        dropdownButton.tintColor = .secondaryLabel
        

        dropdownButton.frame = CGRect(x: 0, y: 0, width: 48, height: 36)
        

        dropdownButton.contentHorizontalAlignment = .center
        

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.down")

        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        dropdownButton.configuration = config

        dropdownButton.addTarget(self, action: #selector(showUnitDropdown), for: .touchUpInside)

        unitTextField.rightView = dropdownButton
        unitTextField.rightViewMode = .always

        unitTextField.addAction(
            UIAction { [weak self] _ in self?.updateTickButtonState() },
            for: .editingChanged
        )
    }
    // MARK: - Dropdown

    @objc private func showUnitDropdown() {
        unitTextField.resignFirstResponder()

        let alert = UIAlertController(title: "Select Unit", message: nil, preferredStyle: .actionSheet)

        for unit in commonUnits {
            alert.addAction(UIAlertAction(title: unit, style: .default) { [weak self] _ in
                self?.unitTextField.text = unit
                self?.updateTickButtonState()
            })
        }


        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))


        if let popover = alert.popoverPresentationController {
            popover.sourceView = unitTextField
            popover.sourceRect = unitTextField.bounds
        }

        present(alert, animated: true)
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
        guard textField == unitTextField else { return true }


        if string.isEmpty { return true }


        let digitsOnly = CharacterSet.decimalDigits
        if string.unicodeScalars.allSatisfy({ digitsOnly.contains($0) }) {

            let current  = (textField.text ?? "") as NSString
            let proposed = current.replacingCharacters(in: range, with: string)
            let hasLetter = proposed.unicodeScalars.contains { CharacterSet.letters.contains($0) }
            return hasLetter
        }

        return true
    }

    // MARK: - TypeTableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        unitAndType.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UnitAndTypeTableViewCell
        cell.configureCell(type: unitAndType[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedType = unitAndType[indexPath.row].name
        for i in 0..<unitAndType.count { unitAndType[i].isSelected = (i == indexPath.row) }
        tableView.reloadData()
        updateTickButtonState()
    }

    // MARK: - Tick state

    private func updateTickButtonState() {
        let rawText  = unitTextField.text ?? ""
        let unit     = rawText.trimmingCharacters(in: .whitespaces)

        
        let hasLetter = unit.unicodeScalars.contains { CharacterSet.letters.contains($0) }
        let hasUnit   = !unit.isEmpty && hasLetter
        let hasType   = selectedType != nil

        tickButton.isEnabled = hasUnit && hasType
    }

    // MARK: - Navigation

    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onTickPressed(_ sender: UIBarButtonItem) {
        guard
            let rawText = unitTextField.text,
            let type    = selectedType
        else { return }

        let unit = rawText.trimmingCharacters(in: .whitespaces)

        // Final guard — must contain a letter
        let hasLetter = unit.unicodeScalars.contains { CharacterSet.letters.contains($0) }
        guard !unit.isEmpty && hasLetter else {
            let alert = UIAlertController(
                title: "Invalid Unit",
                message: "Please enter a unit like mg, ml, mcg, etc.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        UnitAndTypeStore.shared.savedUnit = unit
        UnitAndTypeStore.shared.savedType = type

        delegate?.didSelectUnitsAndType(unitText: unit, selectedType: type)
        navigationController?.popViewController(animated: true)
    }
}
