import UIKit

class InfoMimicTheEmojiViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

            let combinedText = self.collectSpeechText(from: self.view)

            SpeechManager.shared.speak(combinedText)
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
