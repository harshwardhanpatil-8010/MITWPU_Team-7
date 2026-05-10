import UIKit

class profileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!

    @IBOutlet weak var logoBackground: UIView!
    @IBOutlet weak var logoLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateOfBirthSelector: UIDatePicker!

    @IBOutlet weak var sexsSelector: UIButton!
    @IBOutlet weak var stageSelector: UIButton!

    @IBOutlet weak var stackViewBackground: UIStackView!
    @IBOutlet weak var uiViewProfile: UIView!

    @IBOutlet weak var profileNameLabel: UILabel!

    private let genderOptions = [
        "Male",
        "Female",
        "Other",
        "Prefer not to say"
    ]

    private let stageOptions = [
        "Stage 1",
        "Stage 2",
        "Stage 3",
        "Stage 4",
        "Stage 5",
        "Not Known"
    ]

    var isEditingMode: Bool = false

    var selectedSex: String = "Male" {

        didSet {

            sexsSelector.setTitle(
                selectedSex,
                for: .normal
            )

            if #available(iOS 15.0, *) {

                var config = sexsSelector.configuration

                config?.title = selectedSex

                sexsSelector.configuration = config
            }
        }
    }

    var selectedStage: String = "Not Known" {

        didSet {

            stageSelector.setTitle(
                selectedStage,
                for: .normal
            )

            if #available(iOS 15.0, *) {

                var config = stageSelector.configuration

                config?.title = selectedStage

                stageSelector.configuration = config
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserData()

        setupInitialUI()

        configureTextFields()

        configureKeyboardDismissGesture()

        configureDropdownMenus()

        nameTextField.addTarget(
            self,
            action: #selector(nameTextChanged),
            for: .editingChanged
        )

        uiViewProfile.applyCardStyle()
    }

    private func configureTextFields() {

        nameTextField.delegate = self

        nameTextField.returnKeyType = .done
    }

    private func configureKeyboardDismissGesture() {

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tapGesture.cancelsTouchesInView = false

        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {

        view.endEditing(true)
    }

    @objc private func nameTextChanged() {

        let currentText = nameTextField.text ?? ""

        profileNameLabel.text = currentText

        let firstName = currentText
            .split(whereSeparator: { $0.isWhitespace })
            .first
            .map(String.init) ?? ""

        logoLabel.text = String(firstName.prefix(1))
    }

    private func configureDropdownMenus() {

        configureGenderMenu()

        configureStageMenu()
    }

    private func configureGenderMenu() {

        let actions = genderOptions.map { gender in

            UIAction(
                title: gender,
                state: selectedSex == gender
                ? .on
                : .off
            ) { [weak self] _ in

                guard let self = self else {
                    return
                }

                guard self.isEditingMode else {
                    return
                }

                self.selectedSex = gender

                self.configureGenderMenu()
            }
        }

        sexsSelector.menu = UIMenu(
            title: "",
            options: .singleSelection,
            children: actions
        )

        sexsSelector.showsMenuAsPrimaryAction = true
    }

    private func configureStageMenu() {

        let actions = stageOptions.map { stage in

            UIAction(
                title: stage,
                state: selectedStage == stage
                ? .on
                : .off
            ) { [weak self] _ in

                guard let self = self else {
                    return
                }

                guard self.isEditingMode else {
                    return
                }

                self.selectedStage = stage

                self.configureStageMenu()
            }
        }

        stageSelector.menu = UIMenu(
            title: "",
            options: .singleSelection,
            children: actions
        )

        stageSelector.showsMenuAsPrimaryAction = true
    }

    func loadUserData() {

        let defaults = UserDefaults.standard

        let fullName = defaults.string(
            forKey: "userName"
        ) ?? ""

        let firstName = fullName
            .split(whereSeparator: { $0.isWhitespace })
            .first
            .map(String.init) ?? "User"

        nameTextField.text = fullName

        logoLabel.text = String(firstName.prefix(1))

        profileNameLabel.text = fullName

        let gender = defaults.string(
            forKey: "userGender"
        ) ?? "Male"

        selectedSex = gender

        let savedStage = defaults.string(
            forKey: "diseaseStage"
        ) ?? "Not Known"

        selectedStage = savedStage

        if let dob = defaults.object(
            forKey: "userDOB"
        ) as? Date {

            dateOfBirthSelector.date = dob
        }
    }

    private func setupInitialUI() {

        logoBackground.layer.cornerRadius =
            logoBackground.frame.size.height / 2

        logoBackground.clipsToBounds = true

        sexsSelector.setTitle(
            selectedSex,
            for: .normal
        )

        stageSelector.setTitle(
            selectedStage,
            for: .normal
        )

        stackViewBackground.layer.cornerRadius = 25

        stackViewBackground.clipsToBounds = true

        isEditingMode = false

        editButton.title = "Edit"

        updateUI(forEditing: false)
    }

    @IBAction func editButtonTapped(
        _ sender: UIBarButtonItem
    ) {

        isEditingMode.toggle()

        if isEditingMode {

            let config = UIImage.SymbolConfiguration(
                weight: .bold
            )

            editButton.image = UIImage(
                systemName: "checkmark",
                withConfiguration: config
            )

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

        let name = nameTextField.text?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

        defaults.set(
            name,
            forKey: "userName"
        )

        defaults.set(
            selectedSex,
            forKey: "userGender"
        )

        defaults.set(
            dateOfBirthSelector.date,
            forKey: "userDOB"
        )

        defaults.set(
            selectedStage,
            forKey: "diseaseStage"
        )

        NotificationCenter.default.post(
            name: NSNotification.Name(
                "UserProfileUpdated"
            ),
            object: nil
        )
    }

    @IBAction func backButtonTapped(
        _ sender: UIBarButtonItem
    ) {

        if isEditingMode {

            let alert = UIAlertController(
                title: "Discard Changes?",
                message: "You have unsaved changes. Are you sure you want to go back?",
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(
                    title: "Stay",
                    style: .cancel
                )
            )

            alert.addAction(
                UIAlertAction(
                    title: "Discard",
                    style: .destructive
                ) { [weak self] _ in

                    self?.dismiss(animated: true)
                }
            )

            present(alert, animated: true)

        } else {

            dismiss(animated: true)
        }
    }

    func updateUI(forEditing isEditing: Bool) {

        let editableFields: [UIView] = [
            nameTextField,
            dateOfBirthSelector,
            sexsSelector,
            stageSelector
        ]

        for field in editableFields {

            field.isUserInteractionEnabled = isEditing

            if let textField = field as? UITextField {

                textField.borderStyle =
                    isEditing ? .roundedRect : .none

                textField.textAlignment = .right

                textField.textColor =
                    isEditing
                    ? .systemBlue
                    : .label
            }

            if let picker = field as? UIDatePicker {

                picker.tintColor =
                    isEditing
                    ? .systemBlue
                    : .label
            }

            if let button = field as? UIButton {

                button.setTitleColor(
                    isEditing
                    ? .systemBlue
                    : .label,
                    for: .normal
                )
            }
        }

        if !isEditing {

            view.endEditing(true)
        }
    }

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {

        textField.resignFirstResponder()

        return true
    }
}
