//
//  profileViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class profileViewController: UIViewController {

    // MARK: - Navigation Bar Outlet
    @IBOutlet weak var editButton: UIBarButtonItem! // Your connected Edit/Save button
    
    // MARK: - Header Outlets (Top Section)
    @IBOutlet weak var logoBackground: UIView!
    @IBOutlet weak var logoLabel: UILabel!       // "JD" label
    @IBOutlet weak var nameBellowLogoLabel: UILabel! // "John Doe" title below the logo

    // MARK: - Detail Row Key Labels (Static text)
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emergencyNoLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!

    // MARK: - Editable/Interactive Fields (The values that change)
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emergencyNoTextField: UITextField!
    @IBOutlet weak var dateOfBirthSelector: UIDatePicker!
    @IBOutlet weak var sexsSelector: UIButton!

    // MARK: - Action Buttons (Outlets needed for the My Medication and Past Symptoms buttons)
    // ⭐️ You will need to connect these if you want to implement the navigation actions ⭐️
//    @IBOutlet weak var myMedicationButton: UIButton!
//    @IBOutlet weak var pastSymptomsButton: UIButton!
    
    // MARK: - State Management
    var isEditingMode: Bool = false
    
    // Stored property for current sex selection (Default value)
    var selectedSex: String = "Male" {
        didSet {
            // Update the button title whenever the selection changes
            sexsSelector.setTitle(selectedSex, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Initial Header Styling (Circle shape)
        // Ensure the layout has been calculated for the height/width to be correct
        logoBackground.layer.cornerRadius = logoBackground.frame.size.height / 2
        logoBackground.clipsToBounds = true
        logoBackground.backgroundColor = .systemGray4
        
        // 2. Set Initial Sex Button Title and State
        sexsSelector.setTitle(selectedSex, for: .normal)
        
        // 3. Set Initial UI State (View Mode)
        updateUI(forEditing: false)
    }

    // This ensures the logo background size is correct even if layout changes occur
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoBackground.layer.cornerRadius = logoBackground.frame.size.height / 2
    }

    // MARK: - Edit/Save Action
    // ⭐️ Connect this action to your editButton UIBarButtonItem in Storyboard ⭐️
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        isEditingMode.toggle()
        
        if isEditingMode {
            // --- EDIT MODE ---
            // 1. Change button icon to checkmark (Save)
            editButton.image = UIImage(systemName: "checkmark.circle.fill")
            
            // 2. Enable editing for all fields
            updateUI(forEditing: true)
            
        } else {
            // --- SAVE MODE ---
            // 1. Change button icon back to pencil (Edit)
            editButton.image = UIImage(systemName: "pencil")
            
            // 2. Disable editing for all fields
            updateUI(forEditing: false)
            
            // 3. Update the Name Label below the logo
            if let newName = nameTextField.text, !newName.isEmpty {
                nameBellowLogoLabel.text = newName
            }
            
            // TODO: Implement your data saving logic here
        }
    }
    
    // MARK: - UI State Toggle Function
    
    func updateUI(forEditing isEditing: Bool) {
        // Collect all fields that should toggle editability
        let editableFields: [UIView] = [
            nameTextField,
            emergencyNoTextField,
            dateOfBirthSelector,
            sexsSelector
        ]
        
        for field in editableFields {
            field.isUserInteractionEnabled = isEditing
            
            // Apply border style only to the TextFields
            if let textField = field as? UITextField {
                textField.borderStyle = isEditing ? .roundedRect : .none
                textField.textAlignment = .right
            }
            
            if !isEditing {
                // Dismiss keyboard when switching to view mode
                view.endEditing(true)
            }
        }
    }
    
    // MARK: - Action Implementations
    
    // ⭐️ Connect this action to the 'sexsSelector' Button in Storyboard ⭐️
    @IBAction func sexSelectorTapped(_ sender: UIButton) {
        guard isEditingMode else { return }
        
        let actionSheet = UIAlertController(title: "Select Sex", message: nil, preferredStyle: .actionSheet)
        
        let sexes = ["Male", "Female", "Other", "Prefer not to say"]
        
        for sex in sexes {
            let action = UIAlertAction(title: sex, style: .default) { [weak self] _ in
                self?.selectedSex = sex // Updates the button title
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
    
    // ⭐️ Connect this action to the 'My Medication' Button in Storyboard ⭐️
//    @IBAction func myMedicationButtonTapped(_ sender: UIButton) {
//        print("Navigating to My Medication Screen...")
//        // Example Placeholder: To be replaced with navigation/segue logic
//    }
//    
//    // ⭐️ Connect this action to the 'Past symptom records' Button in Storyboard ⭐️
//    @IBAction func pastSymptomsButtonTapped(_ sender: UIButton) {
//        print("Navigating to Past Symptom Records Screen...")
//        // Example Placeholder: To be replaced with navigation/segue logic
//    }
}
