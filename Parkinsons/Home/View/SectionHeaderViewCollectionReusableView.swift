import UIKit

class SectionHeaderView: UICollectionReusableView {

    static let reuseIdentifier = "HeaderView"
    let titleLabel = UILabel()
    private let actionsStackView = UIStackView()
    private var titleTrailingToContainerConstraint: NSLayoutConstraint!
    private var titleTrailingToActionsConstraint: NSLayoutConstraint!
    let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.setTitleColor(.systemBlue, for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let infoButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let image = UIImage(systemName: "info.circle", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var onInfoTap: (() -> Void)?
    var onToggleTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(actionsStackView)

        actionsStackView.axis = .horizontal
        actionsStackView.alignment = .center
        actionsStackView.spacing = 8
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.addArrangedSubview(toggleButton)
        actionsStackView.addArrangedSubview(infoButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleTrailingToContainerConstraint = titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        titleTrailingToActionsConstraint = titleLabel.trailingAnchor.constraint(equalTo: actionsStackView.leadingAnchor, constant: -8)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleTrailingToContainerConstraint,
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            actionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            actionsStackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            toggleButton.heightAnchor.constraint(equalToConstant: 30),

            infoButton.widthAnchor.constraint(equalToConstant: 30),
            infoButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
    }

    @objc private func infoButtonTapped() {
        onInfoTap?()
    }

    @objc private func toggleButtonTapped() {
        onToggleTap?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, showInfoIcon: Bool = false, toggleTitle: String? = nil) {
        titleLabel.text = title
        infoButton.isHidden = !showInfoIcon
        toggleButton.setTitle(toggleTitle, for: .normal)
        toggleButton.isHidden = toggleTitle == nil
        let showsActions = showInfoIcon || toggleTitle != nil
        titleTrailingToContainerConstraint.isActive = false
        titleTrailingToActionsConstraint.isActive = false
        titleTrailingToContainerConstraint.isActive = !showsActions
        titleTrailingToActionsConstraint.isActive = showsActions

    }

    func setTitleAlignment(_ alignment: NSTextAlignment) {
        titleLabel.textAlignment = alignment
    }

    func setFont(size: CGFloat, weight: UIFont.Weight) {
        titleLabel.font = UIFont.systemFont(ofSize: size, weight: weight)
    }
}
