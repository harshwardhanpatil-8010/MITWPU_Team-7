import UIKit

class RhythmicInfoViewController: UIViewController {

    private var isMuted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    private var muteBarButtonItem: UIBarButtonItem?

    private func setupNavigationBar() {
        let muteButton = UIBarButtonItem(
            image: UIImage(systemName: "speaker.wave.2.fill"),
            style: .plain,
            target: self,
            action: #selector(muteButtonTapped)
        )
        self.muteBarButtonItem = muteButton

        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )

        if let navBar = view.subviews.first(where: { $0 is UINavigationBar }) as? UINavigationBar {
            navBar.topItem?.leftBarButtonItem = closeButton
            navBar.topItem?.rightBarButtonItem = muteButton
        }
    }

    @objc private func closeButtonTapped() {
        SpeechManager.shared.stop()
        dismiss(animated: true)
    }

    @objc private func muteButtonTapped() {
        isMuted.toggle()
        let imageName = isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
        muteBarButtonItem?.image = UIImage(systemName: imageName)

        if isMuted {
            SpeechManager.shared.stop()
        } else {
            let combinedText = self.collectAllLabelText(from: self.view)
            SpeechManager.shared.speak(combinedText)
        }
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

    @IBAction func cancelButtonTapped(_ sender: Any) {
        SpeechManager.shared.stop()
        dismiss(animated: true)
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
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ) ?? ""

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
