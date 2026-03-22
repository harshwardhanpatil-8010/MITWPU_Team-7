import UIKit

class profileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var StageInfo: UITextField!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var logoBackground: UIView!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emergencyNoLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emergencyNoTextField: UITextField!
    @IBOutlet weak var dateOfBirthSelector: UIDatePicker!
    @IBOutlet weak var sexsSelector: UIButton!
    
    @IBOutlet weak var stackViewBackground: UIStackView!
    
    @IBOutlet weak var symptomButton: UIButton!
    @IBOutlet weak var medicationButton: UIButton!
    var isEditingMode: Bool = false
    
    var selectedSex: String = "Male" {
        didSet {
            sexsSelector.setTitle(selectedSex, for: .normal)
            
            if #available(iOS 15.0, *) {
                var config = sexsSelector.configuration
                config?.title = selectedSex
                sexsSelector.configuration = config
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserData()
        setupInitialUI()
        configureTextFields()
        configureKeyboardDismissGesture()
    }

    private func configureTextFields() {
        nameTextField.delegate = self
        emergencyNoTextField.delegate = self
        StageInfo.delegate = self
        nameTextField.returnKeyType = .done
        emergencyNoTextField.returnKeyType = .done
        StageInfo.returnKeyType = .done
    }

    private func configureKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func loadUserData() {

        let defaults = UserDefaults.standard

        let fullName = defaults.string(forKey: "userName") ?? ""
        let firstName = fullName
            .split(whereSeparator: { $0.isWhitespace })
            .first
            .map(String.init) ?? "User"

        nameTextField.text = fullName
        logoLabel.text = String(firstName.prefix(1))

        let emergency = defaults.string(forKey: "emergencyContact") ?? ""
        emergencyNoTextField.text = emergency

        let gender = defaults.string(forKey: "userGender") ?? "Male"
        selectedSex = gender

        let savedStage = defaults.integer(forKey: "diseaseStage")
        StageInfo.text = savedStage > 0 ? "Stage \(savedStage)" : "Not Set"

        if let dob = defaults.object(forKey: "userDOB") as? Date {
            dateOfBirthSelector.date = dob
        }
    }


    @IBAction func pastSymptomRecordsNavigation(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Symptom", bundle: nil)
        
        if let symptomVC = storyboard.instantiateViewController(withIdentifier: "symptom") as? SymptomViewController {
            
            symptomVC.modalPresentationStyle = .pageSheet
            self.present(symptomVC, animated: true, completion: nil)
        }
    }

    @IBAction func medicationNavigation(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        
        if let medicationVC = storyboard.instantiateViewController(withIdentifier: "MainMedicationVC") as? MainMedicationViewController {
            
            // 1. Tell the destination it's coming from Profile
            medicationVC.isPresentedFromProfile = true
            
            // 2. Wrap in Navigation Controller to enable the "X" button
            let navController = UINavigationController(rootViewController: medicationVC)
            navController.modalPresentationStyle = .pageSheet
            
            self.present(navController, animated: true, completion: nil)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoBackground.layer.cornerRadius = logoBackground.frame.size.height / 2
    }
    
    private func setupInitialUI() {
        logoBackground.layer.cornerRadius = logoBackground.frame.size.height / 2
        logoBackground.clipsToBounds = true
        sexsSelector.setTitle(selectedSex, for: .normal)
        stackViewBackground.layer.cornerRadius = 25
        stackViewBackground.clipsToBounds = true
        
        isEditingMode = false
        editButton.title = "Edit"
        emergencyNoTextField.borderStyle = .none

        updateUI(forEditing: false)
    }
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        isEditingMode.toggle()

        if isEditingMode {
            let config = UIImage.SymbolConfiguration(weight: .bold)
            editButton.image = UIImage(systemName: "checkmark", withConfiguration: config)
            editButton.title = nil
            editButton.style = .prominent

            updateUI(forEditing: true)

        } else {

            saveUserData()

            editButton.image = nil
            editButton.title = "Edit"
            editButton.style = .plain


            updateUI(forEditing: false)

            loadUserData()

        }
    }

    func saveUserData() {

        let defaults = UserDefaults.standard

        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let emergency = emergencyNoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        defaults.set(name, forKey: "userName")
        defaults.set(emergency, forKey: "emergencyContact")
        defaults.set(selectedSex, forKey: "userGender")
        defaults.set(dateOfBirthSelector.date, forKey: "userDOB")
        if let stageText = StageInfo.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           let stageNumber = Int(stageText.components(separatedBy: " ").last ?? "") {
            defaults.set(stageNumber, forKey: "diseaseStage")
        }
        NotificationCenter.default.post(name: NSNotification.Name("UserProfileUpdated"), object: nil)
    }


    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        if isEditingMode {
            let alert = UIAlertController(
                title: "Discard Changes?",
                message: "You have unsaved changes. Are you sure you want to go back?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Stay", style: .cancel))
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            
            present(alert, animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

    func updateUI(forEditing isEditing: Bool) {
        let editableFields: [UIView] = [
            nameTextField,
            emergencyNoTextField,
            dateOfBirthSelector,
            sexsSelector,
            StageInfo
        ]
        
        for field in editableFields {
            field.isUserInteractionEnabled = isEditing
            
            if let textField = field as? UITextField {
                textField.borderStyle = isEditing ? .roundedRect : .none
                textField.textAlignment = .right
                if isEditing {
                    textField.textColor = .systemBlue
                }
                else {
                    textField.textColor = .label
                }
            }
            if let picker = field as? UIDatePicker {
                        picker.tintColor = isEditing ? .systemBlue : .label
                    }
            
            if let button = field as? UIButton {
                button.setTitleColor(isEditing ? .systemBlue : .label, for: .normal)
            }
        }
        
        if !isEditing {
            view.endEditing(true)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    @IBAction func sexSelectorTapped(_ sender: UIButton) {
        guard isEditingMode else { return }
        
        let actionSheet = UIAlertController(title: "Select Sex", message: nil, preferredStyle: .actionSheet)
        let sexes = ["Male", "Female", "Other", "Prefer not to say"]
        
        for sex in sexes {
            let action = UIAlertAction(title: sex, style: .default) { [weak self] _ in
                self?.selectedSex = sex
            }
            actionSheet.addAction(action)
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(actionSheet, animated: true)
    }
}
