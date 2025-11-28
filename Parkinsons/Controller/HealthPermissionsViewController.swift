//
//  HealthPermissionsViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

// (Assuming the HealthPermissionSetting struct and HealthPermissionCellDelegate protocol are defined above or in separate files)

class HealthPermissionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var completionHandler: ((_ granted: Bool) -> Void)?
    // Data Model Array
    var permissions: [HealthPermissionSetting] = [
        HealthPermissionSetting(iconName: "heart.fill", labelText: "Tremor data", isEnabled: false,iconColor: .systemRed),
        HealthPermissionSetting(iconName: "figure.walk", labelText: "Walking Speed", isEnabled: false,iconColor: .systemYellow),
        HealthPermissionSetting(iconName: "figure.walk", labelText: "Walking Step Length", isEnabled: false, iconColor: .systemYellow),
        HealthPermissionSetting(iconName: "figure.walk", labelText: "Walking Asymmetry", isEnabled: false, iconColor: .systemYellow),
        HealthPermissionSetting(iconName: "figure.walk", labelText: "Walking Steadiness", isEnabled: false, iconColor: .systemYellow)
    ]
    
    @IBOutlet weak var healthAppicon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    // NEW: Outlet for the "Allow" button (Connect this in Storyboard)
    @IBOutlet weak var allowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up table view
        tableView.backgroundColor = UIColor.systemGray6
        tableView.layer.cornerRadius = 25
        tableView.clipsToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setting up health icon
        healthAppicon.layer.borderWidth = 1
        healthAppicon.layer.borderColor = UIColor.lightGray.cgColor
        healthAppicon.layer.cornerRadius = 20
        healthAppicon.clipsToBounds = true
        
        // Initial state check for the Allow button
        updateAllowButtonState()
    }
    
    // MARK: - Button Actions
    
    // NEW: Action for the "Turn On All" button (Connect this in Storyboard)
    @IBAction func allowButton(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
                    // 2. Call the handler, indicating permissions were *granted*
                    // This runs AFTER the dismiss animation completes.
                    self?.completionHandler?(true)
                }
    }
    
    @IBAction func dontAllowButton(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
                    // 2. Call the handler, indicating permissions were *not granted*
                    self?.completionHandler?(true)
                }
    }
    
    @IBAction func turnOnAllButtonTapped(_ sender: UIButton) {
        // 1. Update the data model: Set isEnabled to true for all items
        for i in 0..<permissions.count {
            permissions[i].isEnabled = true
        }
        
        // 2. Reload the table view to reflect the switch changes
        tableView.reloadData()
        
        // 3. Update the "Allow" button state (will enable it)
        updateAllowButtonState()
    }
    
    
    // MARK: - Validation Logic
    
    private func updateAllowButtonState() {
        // Check if AT LEAST ONE permission is granted
        let isAnyPermissionGranted = permissions.contains(where: { $0.isEnabled })
        
        // Disable the "Allow" button if no permissions are granted
        allowButton.isEnabled = isAnyPermissionGranted
        
        // Optional: Change appearance when disabled
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
        
        // Set the cell's delegate to the View Controller so we can track switch changes
        cell.delegate = self
        
        // Configure the cell content
        cell.configure(with: permissionData)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate (Optional: Add cell height)
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}


// MARK: - HealthPermissionCellDelegate Extension

// Extend the View Controller to implement the delegate method
extension HealthPermissionsViewController: HealthPermissionCellDelegate {
    func switchStateDidChange(cell: HealthPermissionTableViewCell, isOn: Bool) {
        // 1. Find the index path of the cell that changed
        if let indexPath = tableView.indexPath(for: cell) {
            
            // 2. Update the data model at that specific index
            permissions[indexPath.row].isEnabled = isOn
            
            // 3. Re-run the validation check to update the "Allow" button
            updateAllowButtonState()
        }
    }
}
