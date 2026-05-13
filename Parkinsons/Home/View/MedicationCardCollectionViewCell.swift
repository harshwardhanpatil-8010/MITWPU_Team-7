protocol MedicationCardDelegate: AnyObject {
    func didTapTaken(for dose: TodayDoseItem, cell: MedicationCardCollectionViewCell)
    func didTapSkipped(for dose: TodayDoseItem, cell: MedicationCardCollectionViewCell)
}

import UIKit

class MedicationCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var BackgroundMedication: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var takenButton: UIButton!
    @IBOutlet weak var skippedButton: UIButton!

    weak var delegate: MedicationCardDelegate?
    private var currentDose: TodayDoseItem?

    // MARK: - Confirmation overlay

    private let confirmationOverlay: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 23
        v.layer.masksToBounds = true
        v.alpha = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let confirmationStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let confirmationIcon: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 28).isActive = true
        return iv
    }()

    private let confirmationLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return l
    }()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        BackgroundMedication.isUserInteractionEnabled = true
        clipsToBounds = false
        contentView.clipsToBounds = false

        setupCardStyle()
        setupConfirmationOverlay()

        takenButton.layer.cornerRadius = 18
        skippedButton.layer.cornerRadius = 18
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2.0
        iconImageView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        confirmationOverlay.alpha = 0
        contentView.alpha = 1
        contentView.transform = .identity
        isHidden = false
        takenButton.isUserInteractionEnabled = true
        skippedButton.isUserInteractionEnabled = true
        takenButton.transform = .identity
        skippedButton.transform = .identity
        // Restore card content visibility
        nameLabel.alpha = 1
        timeLabel.alpha = 1
        detailLabel.alpha = 1
        iconImageView.alpha = 1
        takenButton.alpha = 1
        skippedButton.alpha = 1
    }

    // MARK: - Setup

    private func setupConfirmationOverlay() {
        confirmationStack.addArrangedSubview(confirmationIcon)
        confirmationStack.addArrangedSubview(confirmationLabel)

        contentView.addSubview(confirmationOverlay)
        confirmationOverlay.addSubview(confirmationStack)

        NSLayoutConstraint.activate([
            confirmationOverlay.topAnchor.constraint(equalTo: BackgroundMedication.topAnchor),
            confirmationOverlay.leadingAnchor.constraint(equalTo: BackgroundMedication.leadingAnchor),
            confirmationOverlay.trailingAnchor.constraint(equalTo: BackgroundMedication.trailingAnchor),
            confirmationOverlay.bottomAnchor.constraint(equalTo: BackgroundMedication.bottomAnchor),

            confirmationStack.centerXAnchor.constraint(equalTo: confirmationOverlay.centerXAnchor),
            confirmationStack.centerYAnchor.constraint(equalTo: confirmationOverlay.centerYAnchor)
        ])
    }

    func setupCardStyle() {
        BackgroundMedication.layer.cornerRadius = 23
        BackgroundMedication.layer.masksToBounds = false
        BackgroundMedication.layer.shadowColor = UIColor.black.cgColor
        BackgroundMedication.layer.shadowOpacity = 0.15
        BackgroundMedication.layer.shadowRadius = 3
        BackgroundMedication.layer.shadowOffset = CGSize(width: 0, height: 1)
    }

    // MARK: - Configure

    func configure(with dose: TodayDoseItem) {
        currentDose = dose

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeLabel.text = formatter.string(from: dose.scheduledTime)
        nameLabel.text = dose.medicationName
        detailLabel.text = dose.medicationForm
        iconImageView.image = UIImage(named: dose.iconName)

        if dose.logStatus != .none {
            contentView.alpha = 0
            isHidden = true
        } else {
            contentView.alpha = 1
            isHidden = false
        }
    }

    // MARK: - Actions

    @IBAction func takenTapped(_ sender: Any) {
        guard let dose = currentDose else { return }
        delegate?.didTapTaken(for: dose, cell: self)
    }

    @IBAction func skippedTapped(_ sender: Any) {
        guard let dose = currentDose else { return }
        delegate?.didTapSkipped(for: dose, cell: self)
    }

    // MARK: - Animation

    func playAnimation(isTaken: Bool, completion: @escaping () -> Void) {
        takenButton.isUserInteractionEnabled = false
        skippedButton.isUserInteractionEnabled = false

        let tint = isTaken
            ? UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1)
            : UIColor(red: 1.00, green: 0.62, blue: 0.04, alpha: 1)
        confirmationOverlay.backgroundColor = tint
        confirmationIcon.image = UIImage(
            systemName: isTaken ? "checkmark.circle.fill" : "arrow.uturn.right.circle.fill"
        )
        confirmationLabel.text = isTaken ? "Logged as taken" : "Skipped for now"
        confirmationStack.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        let tappedButton = isTaken ? takenButton : skippedButton
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        UIView.animate(withDuration: 0.10, delay: 0, options: .curveEaseIn) {
            tappedButton?.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        } completion: { _ in
            UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseOut) {
                tappedButton?.transform = .identity
            }
        }

        UIView.animate(withDuration: 0.18, delay: 0.08, options: .curveEaseInOut) {
            self.nameLabel.alpha     = 0
            self.timeLabel.alpha     = 0
            self.detailLabel.alpha   = 0
            self.iconImageView.alpha = 0
            self.takenButton.alpha   = 0
            self.skippedButton.alpha = 0
            self.confirmationOverlay.alpha = 1
        }

        UIView.animate(
            withDuration: 0.30,
            delay: 0.14,
            usingSpringWithDamping: 0.60,
            initialSpringVelocity: 0.5,
            options: []
        ) {
            self.confirmationStack.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.80) {
            completion()
        }

        UIView.animate(
            withDuration: 0.24,
            delay: 0.90,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0,
            options: []
        ) {
            self.contentView.transform = CGAffineTransform(
                translationX: -self.contentView.bounds.width * 0.6, y: 0
            )
            self.contentView.alpha = 0
        }
    }
}
