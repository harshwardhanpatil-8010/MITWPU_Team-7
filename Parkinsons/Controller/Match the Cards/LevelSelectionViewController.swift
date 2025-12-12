//
//  LevelSelectionViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class LevelSelectionViewController: UIViewController {

    
    @IBOutlet weak var datePickerUIView: UIView!
    
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerUIView.applyCardStyle()
        datePickerOutlet.maximumDate = Date()
        datePickerOutlet.preferredDatePickerStyle = .wheels
        datePickerOutlet.datePickerMode = .date
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        let selected = datePickerOutlet.date
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
