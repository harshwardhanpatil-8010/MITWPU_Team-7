//
//  LoginViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class LoginViewController: UIViewController  {
    

    @IBOutlet weak var logoView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        logoView.layer.cornerRadius = 100
        logoView.clipsToBounds = true
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
