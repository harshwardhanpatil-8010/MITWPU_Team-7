import UIKit

class InfoMimicTheEmojiViewController: UIViewController {

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

        if let navBar = view.subviews.first(where: { $0 is UINavigationBar }) as? UINavigationBar {
            navBar.topItem?.rightBarButtonItem = muteButton
        }
    }

    @objc private func muteButtonTapped() {
        isMuted.toggle()
        let imageName = isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
        muteBarButtonItem?.image = UIImage(systemName: imageName)

        if isMuted {
            SpeechManager.shared.stop()
        } else {
            let combinedText = self.collectSpeechText(from: self.view)
            SpeechManager.shared.speak(combinedText)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !self.isMuted {
                let combinedText = self.collectSpeechText(from: self.view)
                SpeechManager.shared.speak(combinedText)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SpeechManager.shared.stop()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        SpeechManager.shared.stop()
        dismiss(animated: true)
    }

    private func collectSpeechText(from rootView: UIView) -> String {

        var texts: [String] = []

        func extract(from view: UIView) {

            for subview in view.subviews {

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

                extract(from: subview)
            }
        }

        extract(from: rootView)

        return texts.joined(separator: ". ")
    }
}
