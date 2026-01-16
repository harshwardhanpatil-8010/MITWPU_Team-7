import UIKit

class profileViewController: UIViewController {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var logoBackground: UIView!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var nameBellowLogoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emergencyNoLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emergencyNoTextField: UITextField!
    @IBOutlet weak var dateOfBirthSelector: UIDatePicker!
    @IBOutlet weak var sexsSelector: UIButton!

    var isEditingMode: Bool = false
    
    var selectedSex: String = "Male" {
        didSet {
            sexsSelector.setTitle(selectedSex, for: .normal)
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
        logoBackground.backgroundColor = .systemGray4
        
        sexsSelector.setTitle(selectedSex, for: .normal)
        
        isEditingMode = false
        editButton.title = "Edit"
        editButton.image = nil
        
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
            
            if let newName = nameTextField.text, !newName.isEmpty {
                nameBellowLogoLabel.text = newName
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
            }
        }
        
        if !isEditing {
            view.endEditing(true)
        }
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
