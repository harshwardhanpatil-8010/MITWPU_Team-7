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

    // MARK: - Outlets
    @IBOutlet weak var tickButton: UIBarButtonItem!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var TypeTableView: UITableView!

    // MARK: - Properties
    weak var delegate: UnitsAndTypeDelegate?
    var selectedType: String?
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        unitTextField.layer.cornerRadius = unitTextField.frame.height / 2
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        unitTextField.leftView = paddingView
        unitTextField.leftViewMode = .always

//        unitTextField.layer.cornerRadius = 25
//        unitTextField.clipsToBounds = true
        unitTextField.borderStyle = .none
        unitTextField.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        unitTextField.layer.borderWidth = 0
//        unitTextField.placeholder = "mg"
        unitTextField.delegate = self

        TypeTableView.layer.cornerRadius = 25
        TypeTableView.clipsToBounds = true
//        TypeTableView.backgroundColor = UIColor.systemGray6
        TypeTableView.delegate = self
        TypeTableView.dataSource = self

   
        unitTextField.text = UnitAndTypeStore.shared.savedUnit

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

        
        for i in 0..<unitAndType.count {
            unitAndType[i].isSelected = (i == indexPath.row)
        }

        UnitAndTypeStore.shared.savedType = selectedType!

        tableView.reloadData()
    }

    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Actions
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onTickPressed(_ sender: UIBarButtonItem) {
        
        guard let text = unitTextField.text,
              let type = selectedType else { return }

        UnitAndTypeStore.shared.savedUnit = text
        UnitAndTypeStore.shared.savedType = type

      
        delegate?.didSelectUnitsAndType(unitText: text, selectedType: type)

       
        navigationController?.popViewController(animated: true)
    }
}
