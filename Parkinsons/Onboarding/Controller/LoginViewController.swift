//
//  LoginViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 13/02/26.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var logoView: UIImageView!
        override func viewDidLoad() {
            super.viewDidLoad()
            logoView.layer.cornerRadius = 100
            logoView.clipsToBounds = true
            
        }



}
