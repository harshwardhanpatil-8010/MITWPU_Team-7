import UIKit

final class WalkingSteadinessSetupViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Walking Steadiness"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "figure.walk.circle.fill")
        iv.tintColor = .systemOrange
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "To get the most accurate tracking, we recommend enabling Walking Steadiness in Apple Health."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let instructionsTitle: UILabel = {
        let label = UILabel()
        label.text = "SETUP INSTRUCTIONS:"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()

    private let instructionsLabel: UILabel = {
        let label = UILabel()
        let text = """
        1. Open the Apple Health app on your iPhone.
        2. Tap the Browse tab at the bottom right.
        3. Tap Mobility, then select Walking Steadiness.
        4. Scroll down and tap Set Up or Enable.
        """
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let fallbackTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "CUSTOM FALLBACK ALGORITHM:"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()

    private let fallbackDescLabel: UILabel = {
        let label = UILabel()
        label.text = "ParkyCare will automatically sync with Apple Health whenever it is enabled. If it is disabled or unavailable, we will automatically analyze your walking steadiness using our built-in motion algorithm."
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let openHealthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Health App", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()

    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Got it, thanks!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        button.setTitleColor(.systemOrange, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        // Add views
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        let divider1 = UIView()
        divider1.backgroundColor = .separator
        stackView.addArrangedSubview(divider1)
        
        stackView.addArrangedSubview(instructionsTitle)
        stackView.addArrangedSubview(instructionsLabel)
        
        let divider2 = UIView()
        divider2.backgroundColor = .separator
        stackView.addArrangedSubview(divider2)
        
        stackView.addArrangedSubview(fallbackTitleLabel)
        stackView.addArrangedSubview(fallbackDescLabel)
        
        let spacer = UIView()
        stackView.addArrangedSubview(spacer)
        
        stackView.addArrangedSubview(openHealthButton)
        stackView.addArrangedSubview(dismissButton)

        openHealthButton.addTarget(self, action: #selector(openHealthApp), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            openHealthButton.heightAnchor.constraint(equalToConstant: 50),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),
            
            divider1.heightAnchor.constraint(equalToConstant: 1),
            divider2.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    @objc private func openHealthApp() {
        if let url = URL(string: "x-apple-health://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let alert = UIAlertController(
                    title: "Cannot Open Health",
                    message: "Apple Health app is not available on this device or could not be opened.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }

    @objc private func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
}
