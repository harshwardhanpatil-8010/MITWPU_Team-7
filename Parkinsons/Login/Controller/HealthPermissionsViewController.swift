//
//  HealthPermissionsViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit


class HealthPermissionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var completionHandler: ((_ granted: Bool) -> Void)?

    var permissions: [HealthPermissionSetting] = [
        HealthPermissionSetting(iconName: "heart.fill", labelText: "Tremor data", isEnabled: false,iconColor: .systemRed),
        HealthPermissionSetting(iconName: "figure.walk", labelText: "Walking Speed", isEnabled: false,iconColor: .systemYellow),
        HealthPermissionSetting(iconName: "figure.walk", labelText: "Walking Step Length", isEnabled: false, iconColor: .systemYellow),
        HealthPermissionSetting(iconName: "figure.walk", labelText: "Walking Asymmetry", isEnabled: false, iconColor: .systemYellow),
        HealthPermissionSetting(iconName: "figure.walk", labelText: "Walking Steadiness", isEnabled: false, iconColor: .systemYellow)
    ]
    
    @IBOutlet weak var healthAppicon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
   
    @IBOutlet weak var allowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        tableView.backgroundColor = UIColor.systemGray6
        tableView.layer.cornerRadius = 25
        tableView.clipsToBounds = true
        tableView.delegate = self
        tableView.dataSource = self

        healthAppicon.layer.borderWidth = 1
        healthAppicon.layer.borderColor = UIColor.lightGray.cgColor
        healthAppicon.layer.cornerRadius = 20
        healthAppicon.clipsToBounds = true
    
        updateAllowButtonState()
    }
    
    // MARK: - Button Actions
    
   
    @IBAction func allowButton(_ sender: UIButton) {
    navigateToNextScreen()
    }
    
    @IBAction func dontAllowButton(_ sender: UIButton) {
      navigateToNextScreen()
    }
    
    func navigateToNextScreen() {
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        guard let mainTabBarController = homeStoryboard.instantiateInitialViewController() else{
            return
        }
        if let window = view.window {
            window.rootViewController = mainTabBarController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }

    
    @IBAction func turnOnAllButtonTapped(_ sender: UIButton) {
     
        for i in 0..<permissions.count {
            permissions[i].isEnabled = true
        }
        
        tableView.reloadData()
        updateAllowButtonState()
    }
    
    
    // MARK: - Validation Logic
    
    private func updateAllowButtonState() {
    
        let isAnyPermissionGranted = permissions.contains(where: { $0.isEnabled })
        
    
        allowButton.isEnabled = isAnyPermissionGranted
        
      
        allowButton.alpha = isAnyPermissionGranted ? 1.0 : 0.5
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return permissions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HealthPermissionsTableViewCell", for: indexPath) as? HealthPermissionTableViewCell else {
            fatalError("Could not dequeue HealthPermissionsTableViewCell or wrong cell type.")
        }
        
        let permissionData = permissions[indexPath.row]
           cell.delegate = self
        cell.configure(with: permissionData)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate (Optional: Add cell height)
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}


// MARK: - HealthPermissionCellDelegate Extension


extension HealthPermissionsViewController: HealthPermissionCellDelegate {
    func switchStateDidChange(cell: HealthPermissionTableViewCell, isOn: Bool) {
  
        if let indexPath = tableView.indexPath(for: cell) {
            permissions[indexPath.row].isEnabled = isOn
            updateAllowButtonState()
        }
    }
}
