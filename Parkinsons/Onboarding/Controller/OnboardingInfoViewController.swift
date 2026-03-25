//
//  OnboardingInfoViewController.swift
//  Parkinsons
//

import UIKit

class OnboardingInfoViewController: UIViewController, UITextFieldDelegate,
                                     UIPickerViewDelegate, UIPickerViewDataSource {

  
    @IBOutlet weak var stageLabelField: UITextField!
    @IBOutlet weak var genderLabelField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!   // replaces UIDatePicker
    @IBOutlet weak var nameTextField: UITextField!

    // MARK: - Data
    let genderOptions = ["Male", "Female", "Other"]
    let stageOptions  = ["Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5"]

    // MARK: - Pickers
    private let genderPickerView = UIPickerView()
    private let stagePickerView  = UIPickerView()
    private let datePicker       = UIDatePicker()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        configureGenderPicker()
        configureStagePicker()
        configureDatePicker()
        configureTextFields()
        configureKeyboardDismissGesture()
    }

    // MARK: - Gender Picker

    private func configureGenderPicker() {
        genderPickerView.delegate   = self
        genderPickerView.dataSource = self
        genderPickerView.tag        = 0

        genderLabelField.inputView          = genderPickerView
        genderLabelField.inputAccessoryView = makeToolbar(doneAction: #selector(genderDoneTapped))
        genderLabelField.tintColor          = .clear
        genderLabelField.placeholder        = "Select Gender"
    }

    @objc private func genderDoneTapped() {
        let row = genderPickerView.selectedRow(inComponent: 0)
        genderLabelField.text = genderOptions[row]
        genderLabelField.resignFirstResponder()
    }

    // MARK: - Stage Picker

    private func configureStagePicker() {
        stagePickerView.delegate   = self
        stagePickerView.dataSource = self
        stagePickerView.tag        = 1

        stageLabelField.inputView          = stagePickerView
        stageLabelField.inputAccessoryView = makeToolbar(doneAction: #selector(stageDoneTapped))
        stageLabelField.tintColor          = .clear
        stageLabelField.placeholder        = "Select Stage"
    }

    @objc private func stageDoneTapped() {
        let row = stagePickerView.selectedRow(inComponent: 0)
        stageLabelField.text = stageOptions[row]
        stageLabelField.resignFirstResponder()
    }

    // MARK: - Date Picker (Inline scroll wheel)

    private func configureDatePicker() {
        // Wheel style gives the classic iOS scroll drum
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode           = .date
        datePicker.maximumDate              = Calendar.current.date(
                                                byAdding: .year, value: -1,
                                                to: Date())   // must be at least 1 yr old

        dateOfBirthTextField.inputView          = datePicker
        dateOfBirthTextField.inputAccessoryView = makeToolbar(doneAction: #selector(dateDoneTapped))
        dateOfBirthTextField.tintColor          = .clear
        dateOfBirthTextField.placeholder        = "Select Date of Birth"
    }

    @objc private func dateDoneTapped() {
        let formatter        = DateFormatter()
        formatter.dateStyle  = .long          // e.g. "March 25, 2026"
        formatter.timeStyle  = .none
        dateOfBirthTextField.text = formatter.string(from: datePicker.date)
        dateOfBirthTextField.resignFirstResponder()
    }

    // MARK: - UIPickerView DataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        pickerView.tag == 0 ? genderOptions.count : stageOptions.count
    }

    // MARK: - UIPickerView Delegate

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        pickerView.tag == 0 ? genderOptions[row] : stageOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        if pickerView.tag == 0 {
            genderLabelField.text = genderOptions[row]
        } else {
            stageLabelField.text  = stageOptions[row]
        }
    }

    // MARK: - Text Field Setup

    private func configureTextFields() {
        nameTextField.delegate        = self
        genderLabelField.delegate     = self
        stageLabelField.delegate      = self
        dateOfBirthTextField.delegate = self
        nameTextField.returnKeyType   = .done
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // Block manual typing in picker-backed fields
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let readonlyFields = [genderLabelField, stageLabelField, dateOfBirthTextField]
        return !readonlyFields.contains(textField)
    }

    // MARK: - Keyboard Dismiss

    private func configureKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Toolbar Helper

    /// Reusable toolbar with a right-aligned Done button
    private func makeToolbar(doneAction: Selector) -> UIToolbar {
        let toolbar    = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace  = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                         target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                         target: self, action: doneAction)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        return toolbar
    }

    // MARK: - Next Button

    @IBAction func nextButtonTapped(_ sender: Any) {
        let name           = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let selectedGender = genderLabelField.text ?? ""
        let stageText      = stageLabelField.text ?? ""
        let stageNumber    = Int(stageText.components(separatedBy: " ").last ?? "")

        let defaults = UserDefaults.standard
        defaults.set(name,           forKey: "userName")
        defaults.set(stageNumber,    forKey: "diseaseStage")
        defaults.set(selectedGender, forKey: "userGender")
        defaults.set(datePicker.date, forKey: "userDOB")   // always save the picker's date
        defaults.set(true,           forKey: "hasCompletedOnboarding")

        NotificationCenter.default.post(
            name: NSNotification.Name("UserProfileUpdated"), object: nil)

        navigateToHome()
    }

    // MARK: - Navigation

    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let tabBarVC   = storyboard.instantiateViewController(withIdentifier: "HomeTabBar")

        let windowScene = UIApplication.shared.connectedScenes
            .compactMap  { $0 as? UIWindowScene }
            .first       { $0.activationState == .foregroundActive }
            ?? UIApplication.shared.connectedScenes.first as? UIWindowScene

        if let sceneDelegate = windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarVC
            sceneDelegate.window?.makeKeyAndVisible()
            return
        }

        windowScene?.windows.first?.rootViewController = tabBarVC
        windowScene?.windows.first?.makeKeyAndVisible()
    }
}
