//
//  LoginInfoViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 19/01/26.
//

import UIKit

class LoginInfoViewController: UIViewController {
    
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var stageLabelButton: UIButton!
    @IBOutlet weak var genderLabelButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    let genderOptions = ["Male", "Female", "Other"]
    let stageOptions = ["Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5"]

    override func viewDidLoad() {
        super.viewDidLoad()

 
        configureGenderPickerMenu()
        
       
        configureStagePickerMenu()
        
        
        genderLabel.text = "Select your gender"
        stageLabelButton.setTitle("", for: .normal)
        stageLabelButton.setTitleColor(.systemBlue, for: .normal)
    }
    
    // MARK: - Picker Configurations (UIMenu)
    
    private func configureGenderPickerMenu() {
        let menuActions = genderOptions.map { gender in
            return UIAction(title: gender) { [weak self] action in
      
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
                
                self?.stageLabel.text = action.title
            }
        }
        
        let stageMenu = UIMenu(title: "Select Stage", children: menuActions)
        
       
        stageLabelButton.menu = stageMenu

        stageLabelButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - IBAction (Maintained for clarity, though not strictly required for UIMenu)
    
    @IBAction func genderPicker(_ sender: Any) {
       
    }
    
    @IBAction func stagePicker(_ sender: Any) {

    }
    
    


}
