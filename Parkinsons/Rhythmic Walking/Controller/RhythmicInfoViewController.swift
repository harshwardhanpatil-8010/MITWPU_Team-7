import UIKit

class RhythmicInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

            let combinedText = self.collectAllLabelText(from: self.view)

            SpeechManager.shared.speak(combinedText)
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
