
import UIKit

class MatchTheCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var frontLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!

    private var showingFront = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        resetAppearance()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetAppearance()
    }

    private func setupUI() {
        let cornerRadius: CGFloat = 15
        contentContainer.layer.cornerRadius = cornerRadius
        contentContainer.clipsToBounds = true

        frontLabel.layer.cornerRadius = cornerRadius
        frontLabel.clipsToBounds = true

        backImageView.layer.cornerRadius = cornerRadius
        backImageView.clipsToBounds = true
    }

    func configure(with card: Card) {
        resetAppearance()
        frontLabel.text = card.content

        if card.isMatched {
            frontLabel.isHidden = false
            backImageView.isHidden = true
            alpha = 0.3
            return
        }
        updateBorder(isFlipped: card.isFlipped)
        frontLabel.isHidden = !card.isFlipped
        backImageView.isHidden = card.isFlipped
        showingFront = card.isFlipped
    }

    func flip(toFront: Bool, animated: Bool) {
        guard showingFront != toFront else { return }
        showingFront = toFront

        let options: UIView.AnimationOptions = toFront ? .transitionFlipFromRight : .transitionFlipFromLeft
        let duration: TimeInterval = animated ? 0.32 : 0.0

        UIView.transition(
            with: contentContainer,
            duration: duration,
            options: options
        ) {
            self.frontLabel.isHidden = !toFront
            self.backImageView.isHidden = toFront
            self.updateBorder(isFlipped: toFront)
        }
    }
    private func updateBorder(isFlipped: Bool) {
        if isFlipped {
            contentContainer.layer.borderWidth = 0.5
            contentContainer.layer.borderColor = UIColor.orange.cgColor
        } else {
            contentContainer.layer.borderWidth = 0.5
            contentContainer.layer.borderColor = UIColor.systemGray5.cgColor
        }
    }

    private func resetAppearance() {
        alpha = 1.0
        isUserInteractionEnabled = true
        showingFront = false

        contentContainer.isHidden = false
        contentContainer.backgroundColor = .clear
        
        updateBorder(isFlipped: false)

        frontLabel.isHidden = true
        backImageView.isHidden = false
    }
    func showEmpty() {
        resetAppearance()
        frontLabel.isHidden = true
        backImageView.isHidden = true
        contentContainer.layer.borderWidth = 0
        alpha = 0.15
        isUserInteractionEnabled = false
    }
    func revealForHint() {
        UIView.animate(withDuration: 0.25, animations: {
            self.contentContainer.transform =
                CGAffineTransform(scaleX: 0.92, y: 0.92)
            self.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.25) {
                self.contentContainer.transform = .identity
                self.alpha = 1.0
            }
        }
    }
}
