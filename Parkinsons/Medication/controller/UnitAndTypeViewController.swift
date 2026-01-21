//
//  UnitAndTypeViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        unitTextField.layer.cornerRadius = unitTextField.frame.height / 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tickButton.isEnabled = false
        
        unitTextField.addAction(
            UIAction { [weak self] _ in
                self?.updateTickButtonState()
            },
            for: .editingChanged
        )

        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        unitTextField.leftView = paddingView
        unitTextField.leftViewMode = .always

        unitTextField.borderStyle = .none
        unitTextField.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        unitTextField.delegate = self

        TypeTableView.layer.cornerRadius = 25
        TypeTableView.clipsToBounds = true
        TypeTableView.delegate = self
        TypeTableView.dataSource = self

        unitTextField.text = selectedUnit

        if let selectedType,
           let index = unitAndType.firstIndex(where: { $0.name == selectedType }) {

            for i in 0..<unitAndType.count {
                unitAndType[i].isSelected = (i == index)
            }
        }

        TypeTableView.reloadData()
        updateTickButtonState()

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return unitAndType.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath) as! UnitAndTypeTableViewCell

        let type = unitAndType[indexPath.row]
        cell.configureCell(type: type)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedType = unitAndType[indexPath.row].name

        for i in 0..<unitAndType.count {
            unitAndType[i].isSelected = (i == indexPath.row)
        }
        tableView.reloadData()
        updateTickButtonState()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    private func updateTickButtonState() {
        let unitText = unitTextField.text ?? ""
        let hasUnit = !unitText.trimmingCharacters(in: .whitespaces).isEmpty
        let hasType = selectedType != nil

        tickButton.isEnabled = hasUnit && hasType
    }


    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onTickPressed(_ sender: UIBarButtonItem) {
        guard
            let rawText = unitTextField.text,
            let type = selectedType
        else { return }

        let unit = rawText.trimmingCharacters(in: .whitespaces)

        UnitAndTypeStore.shared.savedUnit = unit
        UnitAndTypeStore.shared.savedType = type

        delegate?.didSelectUnitsAndType(unitText: unit, selectedType: type)
        navigationController?.popViewController(animated: true)
    }

}

