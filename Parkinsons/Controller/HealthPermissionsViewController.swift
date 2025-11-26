//
//  HealthPermissionsViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class HealthPermissionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var healthAppicon: UIImageView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HealthPermissionsTableViewCell", for: indexPath)
        
        return cell
    }
   
    

    @IBOutlet weak var permissionTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        permissionTableView.backgroundColor = UIColor.systemGray6
        permissionTableView.layer.cornerRadius = 25
        permissionTableView.clipsToBounds = true
        healthAppicon.layer.borderWidth = 1
        healthAppicon.layer.borderColor = UIColor.lightGray.cgColor
        healthAppicon.layer.cornerRadius = 20
        healthAppicon.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
