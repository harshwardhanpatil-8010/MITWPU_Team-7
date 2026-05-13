//
//  GaitSummaryInfoViewController.swift
//  Parkinsons
//
//  Created by harshwardhan patil on 10/01/26.
//

import UIKit

class GaitSummaryInfoViewController: UIViewController {

    private var muteBarButtonItem: UIBarButtonItem?
    private var isMuted: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Gait Summary"

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !self.isMuted {
                let combinedText = self.collectAllLabelText(from: self.view)
                SpeechManager.shared.speak(combinedText)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SpeechManager.shared.stop()
    }

    private func setupNavigationBar() {

        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )

        let muteButton = UIBarButtonItem(
            image: UIImage(systemName: "speaker.wave.2.fill"),
            style: .plain,
            target: self,
            action: #selector(muteButtonTapped)
        )

        muteBarButtonItem = muteButton

        if let navBar = view.subviews.first(where: { $0 is UINavigationBar }) as? UINavigationBar {
            navBar.topItem?.leftBarButtonItem  = closeButton
            navBar.topItem?.rightBarButtonItem = muteButton
        }
    }

    @objc private func closeButtonTapped() {
        SpeechManager.shared.stop()
        dismiss(animated: true)
    }

    @objc private func muteButtonTapped() {

        isMuted.toggle()

        let imageName = isMuted
            ? "speaker.slash.fill"
            : "speaker.wave.2.fill"

        muteBarButtonItem?.image = UIImage(systemName: imageName)

        if isMuted {
            SpeechManager.shared.stop()
        } else {
            let combinedText = collectAllLabelText(from: view)
            SpeechManager.shared.speak(combinedText)
        }
    }

    private func collectAllLabelText(from rootView: UIView) -> String {

        var texts: [String] = []

        func extractLabels(from view: UIView) {

            let sortedSubviews = view.subviews.sorted {
                $0.frame.minY < $1.frame.minY
            }

            for subview in sortedSubviews {

                if let label = subview as? UILabel {

                    let text = label.text?
                        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                    if !text.isEmpty &&
                        !label.isHidden &&
                        label.alpha > 0 {

                        texts.append(text)
                    }
                }

                extractLabels(from: subview)
            }
        }

        extractLabels(from: rootView)

        return texts.joined(separator: ". ")
    }
}
