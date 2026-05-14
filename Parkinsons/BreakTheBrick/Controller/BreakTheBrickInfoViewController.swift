// BreakTheBrickInfoViewController.swift
// Parkinsons

import UIKit

class BreakTheBrickInfoViewController: UIViewController {
    private var isMuted = false
    private var muteBarButtonItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        if let navBar = view.subviews.first(where: { $0 is UINavigationBar }) as? UINavigationBar {
            let speakerImage = UIImage(systemName: "speaker.wave.2.fill")
            let speakerButton = UIBarButtonItem(image: speakerImage, style: .plain, target: self, action: #selector(muteButtonTapped))
            speakerButton.tintColor = UIColor.label
            self.muteBarButtonItem = speakerButton
            navBar.topItem?.rightBarButtonItem = speakerButton
        }
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

    @objc @IBAction func dismissInfoAction() {
        SpeechManager.shared.stop()
        dismiss(animated: true)
    }
}
