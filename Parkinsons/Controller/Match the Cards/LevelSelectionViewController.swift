//
//  LevelSelectionViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class LevelSelectionViewController: UIViewController {

    
    @IBOutlet weak var datePickerUIView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerUIView.applyCardStyle()
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
