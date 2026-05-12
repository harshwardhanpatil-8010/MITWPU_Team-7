// StillSphereInfoViewController.swift
// Parkinsons

import UIKit

class StillSphereInfoViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var infoStackView: UIStackView!

    private var isMuted = false
    private var muteBarButtonItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        populateInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Automatic speech on appearance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !self.isMuted {
                self.startNarration()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SpeechManager.shared.stop()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavigationBar() {
        self.title = ""
        
        // Close (X) Button on the LEFT
        let closeImage = UIImage(systemName: "xmark")
        let closeButton = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(dismissInfoAction))
        closeButton.tintColor = UIColor.label
        navigationItem.leftBarButtonItem = closeButton
        
        // Mute/Speaker Button on the RIGHT
        let speakerImage = UIImage(systemName: "speaker.wave.2.fill")
        let speakerButton = UIBarButtonItem(image: speakerImage, style: .plain, target: self, action: #selector(muteButtonTapped))
        speakerButton.tintColor = UIColor.label
        self.muteBarButtonItem = speakerButton
        navigationItem.rightBarButtonItem = speakerButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func populateInfo() {
        titleLabel.text = "How to Play StillSphere"
        descriptionLabel.text = "Follow these steps to improve hand control and steadiness."
        
        let instructions = [
            ("Preparation", "Hold your phone comfortably with both hands or one steady hand.", "hand.raised.fill"),
            ("Control", "Tilt your phone gently to move the glowing sphere.", "iphone.radiowaves.left.and.right"),
            ("Objective", "Guide the sphere along the path toward the glowing target circle.", "scope"),
            ("Technique", "Move slowly and steadily for better control.", "slowmo"),
            ("Correction", "Avoid sudden fast tilts — smooth movements work best. If the sphere starts drifting, gently correct the direction.", "arrow.triangle.2.circlepath"),
            ("Completion", "Reach the glowing calm zone to complete the session.", "checkmark.circle.fill"),
            ("Daily Challenge", "Complete daily sessions to improve steadiness and track your progress over time.", "calendar.badge.clock")
        ]
        
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (title, desc, icon) in instructions {
            let row = createInfoRow(title: title, desc: desc, icon: icon)
            infoStackView.addArrangedSubview(row)
        }
    }
    
    private func createInfoRow(title: String, desc: String, icon: String) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 16
        container.alignment = .top
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemGreen
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .boldSystemFont(ofSize: 17)
        
        let descLbl = UILabel()
        descLbl.text = desc
        descLbl.font = .systemFont(ofSize: 15)
        descLbl.textColor = .secondaryLabel
        descLbl.numberOfLines = 0
        
        textStack.addArrangedSubview(titleLbl)
        textStack.addArrangedSubview(descLbl)
        
        container.addArrangedSubview(iconView)
        container.addArrangedSubview(textStack)
        
        return container
    }

    @objc private func muteButtonTapped() {
        isMuted.toggle()
        let imageName = isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
        muteBarButtonItem?.image = UIImage(systemName: imageName)
        
        if isMuted {
            SpeechManager.shared.stop()
        } else {
            startNarration()
        }
    }
    
    private func startNarration() {
        let combinedText = collectSpeechText(from: self.view)
        SpeechManager.shared.speak(combinedText)
    }
    
    private func collectSpeechText(from rootView: UIView) -> String {
        var texts: [String] = []
        
        func extract(from view: UIView) {
            // Sort subviews by vertical position to ensure logical reading order
            let sortedSubviews = view.subviews.sorted { $0.frame.minY < $1.frame.minY }
            
            for subview in sortedSubviews {
                if let label = subview as? UILabel {
                    let text = label.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    if !text.isEmpty && !label.isHidden && label.alpha > 0 {
                        texts.append(text)
                    }
                }
                extract(from: subview)
            }
        }
        
        extract(from: rootView)
        return texts.joined(separator: ". ")
    }

    @objc private func dismissInfoAction() {
        SpeechManager.shared.stop()
        dismiss(animated: true)
    }
}
