//
//  OnboardingInfoViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 13/02/26.
//

import UIKit

class OnboardingInfoViewController: UIViewController {


       @IBOutlet weak var stageLabelButton: UIButton!
       @IBOutlet weak var genderLabelButton: UIButton!

    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var emergencyTextField: UITextField!
    
       let genderOptions = ["Male", "Female", "Other"]
       let stageOptions = ["Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5"]

       override func viewDidLoad() {
           super.viewDidLoad()

           navigationItem.hidesBackButton = true
           navigationController?.interactivePopGestureRecognizer?.isEnabled = false

           configureGenderPickerMenu()
           configureStagePickerMenu()
           
           genderLabelButton.setTitle("", for: .normal)
           genderLabelButton.setTitleColor(.systemBlue, for: .normal)
           stageLabelButton.setTitle("", for: .normal)
           stageLabelButton.setTitleColor(.systemBlue, for: .normal)
       }
       
       // MARK: - Picker Configurations (UIMenu)
       
       private func configureGenderPickerMenu() {
           let menuActions = genderOptions.map { gender in
               return UIAction(title: gender) { [weak self] action in
                   self?.genderLabelButton.setTitle(action.title, for: .normal)
               }
           }
           
           let genderMenu = UIMenu(title: "Select your gender", children: menuActions)
           genderLabelButton.menu = genderMenu
           genderLabelButton.showsMenuAsPrimaryAction = true
       }
       
    private func configureStagePickerMenu() {
        
        let menuActions = stageOptions.map { stage in
            return UIAction(title: stage) { [weak self] action in
                self?.stageLabelButton.setTitle(action.title, for: .normal)
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
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {

        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let emergencyContact = emergencyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let selectedGender = genderLabelButton.title(for: .normal) ?? ""
        let stageText = stageLabelButton.title(for: .normal) ?? ""

              let stageNumber = Int(stageText.components(separatedBy: " ").last ?? "")

        let defaults = UserDefaults.standard
        defaults.set(name, forKey: "userName")
        defaults.set(emergencyContact, forKey: "emergencyContact")
        defaults.set(stageNumber, forKey: "diseaseStage")
        defaults.set(selectedGender, forKey: "userGender")
        defaults.set(true, forKey: "hasCompletedOnboarding")

        navigateToHome()
    }

    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let tabBarVC = storyboard.instantiateViewController(withIdentifier: "HomeTabBar")

        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            ?? UIApplication.shared.connectedScenes.first as? UIWindowScene

        if let sceneDelegate = windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarVC
            sceneDelegate.window?.makeKeyAndVisible()
            return
        }


        if let window = windowScene?.windows.first {
            window.rootViewController = tabBarVC
            window.makeKeyAndVisible()
        }
    }

   }
