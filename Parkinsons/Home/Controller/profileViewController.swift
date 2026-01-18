import UIKit

class profileViewController: UIViewController {

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
        
        setupInitialUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoBackground.layer.cornerRadius = logoBackground.frame.size.height / 2
    }
    
    private func setupInitialUI() {
        logoBackground.layer.cornerRadius = logoBackground.frame.size.height / 2
        logoBackground.clipsToBounds = true
        
        sexsSelector.setTitle(selectedSex, for: .normal)
        stackViewBackground.layer.cornerRadius = 20
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
            editButton.image = nil
            editButton.title = "Edit"
            editButton.style = .plain
            
            updateUI(forEditing: false)
            
            UIView.animate(withDuration: 0.3) {
                self.updateUI(forEditing: self.isEditingMode)
            }
        }
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
            sexsSelector
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
//    func updateUI(forEditing isEditing: Bool) {
//        let editableFields: [UIView] = [
//            nameTextField,
//            emergencyNoTextField,
//            dateOfBirthSelector,
//            sexsSelector
//        ]
//        
//        // Define your colors
//        let activeColor = UIColor.systemGray6 // A soft light gray for editing mode
//        let inactiveColor = UIColor.clear      // Transparent when just viewing
//        
//        for field in editableFields {
//            field.isUserInteractionEnabled = isEditing
//            if let textField = field as? UITextField {
//                textField.borderStyle = isEditing ? .roundedRect : .none
//                textField.backgroundColor = isEditing ? activeColor : inactiveColor
//                textField.textAlignment = .right
//                if isEditing {
//                    textField.textColor = .systemBlue
//                }
//                else {
//                    textField.textColor = .label
//                }
//                
//            }
//            if let button = field as? UIButton {
//                button.backgroundColor = isEditing ? activeColor : inactiveColor
//                button.layer.cornerRadius = 5
//                button.setTitleColor(isEditing ? .systemBlue : .label, for: .normal)
//            }
//        }
//        
//        if !isEditing {
//            view.endEditing(true)
//        }
//    }
    
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
