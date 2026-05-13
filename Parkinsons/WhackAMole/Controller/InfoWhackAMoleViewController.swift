import UIKit

class InfoWhackAMoleViewController: UIViewController {

    private var isMuted = false
    private var muteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTopBar()
        setupContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !self.isMuted {
                SpeechManager.shared.speak(self.collectSpeechText(from: self.view))
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SpeechManager.shared.stop()
    }

    // MARK: - Top Bar (X left, speaker right — matches screenshot exactly)

    private func setupTopBar() {

        let closeBtn = UIButton(type: .system)
        closeBtn.setImage(UIImage(systemName: "xmark",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        closeBtn.tintColor = .label
        closeBtn.backgroundColor = UIColor.systemGray5
        closeBtn.layer.cornerRadius = 16
        closeBtn.clipsToBounds = true
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeBtn)


        muteButton = UIButton(type: .system)
        muteButton.setImage(UIImage(systemName: "speaker.wave.2.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        muteButton.tintColor = .label
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(muteButton)

        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeBtn.widthAnchor.constraint(equalToConstant: 32),
            closeBtn.heightAnchor.constraint(equalToConstant: 32),

            muteButton.centerYAnchor.constraint(equalTo: closeBtn.centerYAnchor),
            muteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Content (numbered lists with divider — matches screenshot)

    private func setupContent() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])


        let heading = makeLabel("How to Play ?", size: 20, weight: .bold)
        stack.addArrangedSubview(heading)
        stack.setCustomSpacing(12, after: heading)


        let instructions = [
            "Moles will pop up from holes on the screen.",
            "Tap on a mole to whack it and earn 10 points.",
            "Some moles carry a bomb on their head — do NOT tap those!",
            "If you tap a bomb mole, the game ends immediately.",
            "Keep whacking moles until the timer runs out.",
            "Your score depends on how many moles you whack in time.",
        ]
        for (i, text) in instructions.enumerated() {
            let lbl = makeLabel("\(i + 1). \(text)", size: 16, weight: .regular)
            stack.addArrangedSubview(lbl)
        }


        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        stack.addArrangedSubview(divider)
        divider.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        stack.setCustomSpacing(16, after: instructions.last != nil ? stack.arrangedSubviews[stack.arrangedSubviews.count - 2] : heading)
        stack.setCustomSpacing(16, after: divider)

        
        let dailyHeading = makeLabel("Daily challenges", size: 20, weight: .bold)
        stack.addArrangedSubview(dailyHeading)
        stack.setCustomSpacing(12, after: dailyHeading)

        let dailyItems = [
            "Every day brings a new challenge with a random difficulty.",
            "Difficulty affects the time limit, number of holes, and bomb frequency.",
            "You can play past days' challenges but not future ones.",
            "Complete the daily set to track your progress and improve reaction time.",
        ]
        for (i, text) in dailyItems.enumerated() {
            let lbl = makeLabel("\(i + 1). \(text)", size: 16, weight: .regular)
            stack.addArrangedSubview(lbl)
        }
    }

    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: size, weight: weight)
        lbl.textColor = .label
        lbl.numberOfLines = 0
        return lbl
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        SpeechManager.shared.stop()
        dismiss(animated: true)
    }

    @objc private func muteTapped() {
        isMuted.toggle()
        let img = isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
        muteButton.setImage(UIImage(systemName: img,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        if isMuted {
            SpeechManager.shared.stop()
        } else {
            SpeechManager.shared.speak(collectSpeechText(from: view))
        }
    }

    private func collectSpeechText(from rootView: UIView) -> String {
        var texts: [String] = []
        func extract(from view: UIView) {
            for sub in view.subviews {
                if let label = sub as? UILabel,
                   let text = label.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !text.isEmpty, !label.isHidden, label.alpha > 0 {
                    texts.append(text)
                }
                extract(from: sub)
            }
        }
        extract(from: rootView)
        return texts.joined(separator: ". ")
    }
}
