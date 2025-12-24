//
//  UnitAndTypeViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

// Delegate used to pass selected unit + type back to previous screen
protocol UnitsAndTypeDelegate: AnyObject {
    func didSelectUnitsAndType(unitText: String, selectedType: String)
}

class UnitAndTypeViewController: UIViewController,
                                 UITableViewDataSource,
                                 UITableViewDelegate,
                                 UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tickButton: UIBarButtonItem!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var TypeTableView: UITableView!

    // MARK: - Properties
    weak var delegate: UnitsAndTypeDelegate?
    var selectedType: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI Setup
        unitTextField.layer.cornerRadius = 25
        unitTextField.clipsToBounds = true
        unitTextField.placeholder = "mg"
        unitTextField.delegate = self

        // Setup table appearance
        TypeTableView.layer.cornerRadius = 10
        TypeTableView.clipsToBounds = true
        TypeTableView.backgroundColor = UIColor.systemGray6
        TypeTableView.delegate = self
        TypeTableView.dataSource = self

        // Restore saved unit text
        unitTextField.text = UnitAndTypeStore.shared.savedUnit

        // Restore saved type selection
        if let savedType = UnitAndTypeStore.shared.savedType, !savedType.isEmpty {
            selectedType = savedType

            if let index = unitAndType.firstIndex(where: { $0.name == savedType }) {
                unitAndType[index].isSelected = true
            }
        }

        TypeTableView.reloadData()
    }

    // MARK: - TableView DataSource
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

    // MARK: - TableView Selection Handling
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedType = unitAndType[indexPath.row].name

        // Ensure only one type is selected
        for i in 0..<unitAndType.count {
            unitAndType[i].isSelected = (i == indexPath.row)
        }

        // Store selected type
        UnitAndTypeStore.shared.savedType = selectedType!

        tableView.reloadData()
    }

    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // hide keyboard
        return true
    }

    // MARK: - Actions
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onTickPressed(_ sender: UIBarButtonItem) {
        // Ensure both unit text and type are selected
        guard let text = unitTextField.text,
              let type = selectedType else { return }

        // Save selections
        UnitAndTypeStore.shared.savedUnit = text
        UnitAndTypeStore.shared.savedType = type

        // Pass back selected values using delegate
        delegate?.didSelectUnitsAndType(unitText: text, selectedType: type)

        // Go back
        navigationController?.popViewController(animated: true)
    }
}
