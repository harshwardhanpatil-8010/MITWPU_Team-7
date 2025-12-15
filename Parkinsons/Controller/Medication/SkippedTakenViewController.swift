//
//  SkippedTakenViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

// MARK: - Dose Status Update
protocol SkippedTakenDelegate: AnyObject {
    func didUpdateDoseStatus(_ dose: MedicationDose, status: DoseStatus)
}

// MARK: - Skipped / Taken Screen
class SkippedTakenViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var uiview: UIView!
    @IBOutlet weak var skippedButton: UIButton!
    @IBOutlet weak var takenButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Properties
    var selectedDose: MedicationDose?
    var receivedTitle: String?
    var receivedSubtitle: String?
    var receivedIconName: String?
    weak var delegate: SkippedTakenDelegate?
    var selectedStatus: DoseStatus = .none      // Track selected state

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set screen title
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        self.title = formatter.string(from: Date())

        // Add close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(handleBack)
        )

        // Setup UI content
        titleLabel.text = receivedTitle
        subtitleLabel.text = receivedSubtitle
        iconImageView.image = UIImage(named: receivedIconName ?? "")

        // Rounded container
        uiview.layer.cornerRadius = 16
        uiview.layer.masksToBounds = true
    }

    // MARK: - Navigation
    @objc func handleBack() {      // Close screen
        dismiss(animated: true)
    }

    // MARK: - Button Actions
    @IBAction func skippedButtonTapped(_ sender: UIButton) {    // Select skipped
        selectedStatus = .skipped
        updateButtonUI()
    }

    @IBAction func takenButtonTapped(_ sender: UIButton) {      // Select taken
        selectedStatus = .taken
        updateButtonUI()
    }

    @IBAction func tickButtonTapped(_ sender: UIButton) {       // Confirm update
        guard let dose = selectedDose else { return }

        delegate?.didUpdateDoseStatus(dose, status: selectedStatus)
        dismiss(animated: true)
    }

    // MARK: - UI Updates
    func updateButtonUI() {     // Update selection UI

        var skippedConfig: UIButton.Configuration
        var takenConfig: UIButton.Configuration

        switch selectedStatus {
        case .skipped:
            skippedConfig = .filled()
            takenConfig = .tinted()
        case .taken:
            takenConfig = .filled()
            skippedConfig = .tinted()
        case .none:
            skippedConfig = .tinted()
            takenConfig = .tinted()
        }

        // Set titles
        skippedConfig.title = "Skipped"
        takenConfig.title = "Taken"

        // Capsule style buttons
        skippedConfig.cornerStyle = .capsule
        takenConfig.cornerStyle = .capsule

        // Apply configs
        skippedButton.configuration = skippedConfig
        takenButton.configuration = takenConfig

        // Enable tick ONLY when selected
        tickButton.isEnabled = (selectedStatus != .none)
    }
}
