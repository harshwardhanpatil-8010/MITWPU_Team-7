//
//  InfoViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class InfoViewController: UIViewController {

    // IBOutlets
    // Note: Based on your outlets, stageLabelButton is the element that needs its text updated.
    @IBOutlet weak var stageLabel: UILabel!        // Text above the stage picker (e.g., "Parkinson's Stage")
    @IBOutlet weak var stageLabelButton: UIButton! // The actual button/label that shows the selected stage
    @IBOutlet weak var genderLabelButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!       // Label that shows the selected gender

    // Data for the Pickers
    let genderOptions = ["Male", "Female", "Other"]
    let stageOptions = ["Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5"] // Added more stages for completeness

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the Gender Picker
        configureGenderPickerMenu()
        
        // Configure the Stage Picker
        configureStagePickerMenu()
        
        // Initial setup
        genderLabel.text = "Select your gender"
        stageLabelButton.setTitle("", for: .normal)
        stageLabelButton.setTitleColor(.systemBlue, for: .normal) // Ensure it looks like a selectable button
    }
    
    // MARK: - Picker Configurations (UIMenu)
    
    private func configureGenderPickerMenu() {
        let menuActions = genderOptions.map { gender in
            return UIAction(title: gender) { [weak self] action in
                // Update the genderLabel
                self?.genderLabel.text = action.title
            }
        }
        
        let genderMenu = UIMenu(title: "Select your gender", children: menuActions)
        genderLabelButton.menu = genderMenu
        genderLabelButton.showsMenuAsPrimaryAction = true
    }
    
    private func configureStagePickerMenu() {
        
        let menuActions = stageOptions.map { stage in
            return UIAction(title: stage) { [weak self] action in
                // 1. Update the stageLabelButton's title with the selected stage
//                self?.stageLabelButton.setTitle(action.title, for: .normal)
                
                // Optional: Change text color to black or gray after selection
                self?.stageLabel.text = action.title
            }
        }
        
        let stageMenu = UIMenu(title: "Select Stage", children: menuActions)
        
        // Assign the menu to the button
        stageLabelButton.menu = stageMenu
        
        // This makes the menu appear when the button is tapped
        stageLabelButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - IBAction (Maintained for clarity, though not strictly required for UIMenu)
    
    @IBAction func genderPicker(_ sender: Any) {
        // UIMenu handles the action, so this is mostly empty.
    }
    
    @IBAction func stagePicker(_ sender: Any) {
        // UIMenu handles the action, so this is mostly empty.
    }
    
    // MARK: - Date Picker (Implementation placeholder)
    
    // You will need an action for the date picker (27 Nov 2025) which typically
    // uses a UIDatePicker view shown modally or inline.
    
    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // ...
    }
    */
}
