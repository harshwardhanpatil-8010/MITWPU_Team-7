// StillSphereResultViewController.swift
// Parkinsons

import UIKit

class StillSphereResultViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var steadinessValueLabel: UILabel!
    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    var steadinessScore: Double = 0
    var duration: TimeInterval = 0
    private let themeColor = UIColor.systemYellow

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    private func setupUI() {
        navigationItem.hidesBackButton = true
        
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let durationText = String(format: "%02d:%02d", minutes, seconds)

        buildUnifiedResultScreen(
            title: celebrationResultTitle(),
            symbolName: "hands.clap.fill",
            emojiText: nil,
            message: "You are improving your steady movement control.",
            stats: [
                ("Steadiness", String(format: "%.0f%%", steadinessScore)),
                ("Time", durationText)
            ],
            themeColor: themeColor,
            finishAction: #selector(doneTapped(_:))
        )

        showUniformConfetti()
    }

    @IBAction func doneTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}
