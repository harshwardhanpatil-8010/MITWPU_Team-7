//
//  SkippedTakenViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class SkippedTakenViewController: UIViewController {

    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var uiview: UIView!
    @IBOutlet weak var skippedButton: UIButton!
    @IBOutlet weak var takenButton: UIButton!
    var selectedDose: MedicationDose?
    var receivedTitle: String?
    var receivedSubtitle: String?
    var receivedIconName: String?
    weak var delegate: SkippedTakenDelegate?

    var selectedStatus: DoseStatus = .none   // ← keeps track of which button is selected

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d MMM"   // Saturday, 13 Dec
            self.title = formatter.string(from: Date())
        navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(handleBack)
            )

//        guard let dose = selectedDose else { return }
        print("receivedTitle \(receivedTitle ?? " ")")
        titleLabel.text = receivedTitle
            subtitleLabel.text = receivedSubtitle
            iconImageView.image = UIImage(named: receivedIconName ?? "")
        uiview.layer.cornerRadius = 16
        uiview.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
    @objc func handleBack() {
        dismiss(animated: true)
    }

    @IBAction func skippedButtonTapped(_ sender: UIButton) {
        selectedStatus = .skipped
        updateButtonUI()
    }

    @IBAction func takenButtonTapped(_ sender: UIButton) {
        selectedStatus = .taken
        updateButtonUI()
    }
    func updateButtonUI() {

        // Base configs
        var skippedConfig: UIButton.Configuration
        var takenConfig: UIButton.Configuration

        if selectedStatus == .skipped {
            // Skipped = selected
            skippedConfig = .filled()
            takenConfig = .tinted()
        } else if selectedStatus == .taken {
            // Taken = selected
            takenConfig = .filled()
            skippedConfig = .tinted()
        } else {
            // None selected
            skippedConfig = .tinted()
            takenConfig = .tinted()
        }

        // Titles
        skippedConfig.title = "Skipped"
        takenConfig.title = "Taken"

        // Make both capsule ALWAYS
        skippedConfig.cornerStyle = .capsule
        takenConfig.cornerStyle = .capsule

        // Apply back to buttons
        skippedButton.configuration = skippedConfig
        takenButton.configuration = takenConfig
        
        
        // Enable tick button only if user selected something
        if selectedStatus == .none {
            tickButton.isEnabled = false
            
        } else {
            tickButton.isEnabled = true
            
        }

    }





//    @IBAction func tickButtonTapped(_ sender: UIButton) {
//        guard let dose = selectedDose else { return }
//
//        // update model
//        dose.status = selectedStatus
//
//        // notify the landing page
//        delegate?.didUpdateDoseStatus(dose, status: selectedStatus)
//
//        dismiss(animated: true)
//    }

    @IBAction func tickButtonTapped(_ sender: UIButton) {
        guard let dose = selectedDose else { return }

            // update model
            

            // notify the landing page
            delegate?.didUpdateDoseStatus(dose, status: selectedStatus)

            dismiss(animated: true)
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
protocol SkippedTakenDelegate: AnyObject {
    func didUpdateDoseStatus(_ dose: MedicationDose, status: DoseStatus)
}
