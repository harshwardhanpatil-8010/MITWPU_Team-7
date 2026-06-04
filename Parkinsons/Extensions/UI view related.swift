//
//  UI view related.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
import UIKit

// MARK: - Adaptive layout (iPhone SE → Pro Max)

enum AdaptiveCardLayout {

    static func applyFlexibleText(_ labels: UILabel...) {
        labels.forEach { label in
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingTail
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
    }

    static func applyFixedChrome(_ views: UIView...) {
        views.forEach { view in
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
            view.setContentHuggingPriority(.required, for: .horizontal)
        }
    }

    static func applyActionControls(_ views: UIView...) {
        views.forEach { view in
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
            view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }
    }

    static func configureCompactActionButton(_ button: UIButton) {
        var config = button.configuration ?? UIButton.Configuration.filled()
        config.titleLineBreakMode = .byTruncatingTail
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
        if config.titleTextAttributesTransformer == nil {
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
                return outgoing
            }
        }
        button.configuration = config
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.75
        applyActionControls(button)
    }

    /// Deactivates equal-width constraints that assume a fixed device width in Interface Builder.
    static func relaxRigidEqualWidths(in root: UIView, minimumConstant: CGFloat = 72) {
        func visit(_ view: UIView) {
            view.constraints.forEach { constraint in
                guard constraint.isActive,
                      constraint.relation == .equal,
                      constraint.secondItem == nil,
                      constraint.firstItem === view,
                      constraint.firstAttribute == .width,
                      constraint.constant >= minimumConstant else { return }
                constraint.isActive = false
            }
            view.subviews.forEach(visit)
        }
        visit(root)
    }

    static func ensureTrailingPin(
        child: UIView,
        to parent: UIView,
        inset: CGFloat,
        replacingLessThanOrEqual: Bool = true
    ) {
        parent.constraints.forEach { constraint in
            guard replacingLessThanOrEqual,
                  constraint.relation == .lessThanOrEqual,
                  (constraint.firstItem as? UIView) === parent || (constraint.secondItem as? UIView) === parent,
                  (constraint.firstItem as? UIView) === child || (constraint.secondItem as? UIView) === child,
                  constraint.firstAttribute == .trailing || constraint.secondAttribute == .trailing else { return }
            constraint.isActive = false
        }
        if !parent.constraints.contains(where: { c in
            c.isActive && c.relation == .equal &&
            ((c.firstItem as? UIView) === child && c.firstAttribute == .trailing && (c.secondItem as? UIView) === parent) ||
             ((c.secondItem as? UIView) === child && c.secondAttribute == .trailing && (c.firstItem as? UIView) === parent)
        }) {
            child.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -inset)
            ])
        }
    }
}

extension UIView {

    func applyCardStyle() {
        let cornerRadius: CGFloat = 30
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.09

        let shadowRadius: CGFloat = 4
        let shadowOffset: CGSize = .init(width: 0, height: 2)

        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false

        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
    }
}

extension UIViewController {
    
    func showUniformConfetti() {
        // Remove any existing emitter layer to prevent duplicates
        view.layer.sublayers?.filter { $0 is CAEmitterLayer }.forEach { $0.removeFromSuperlayer() }
        
        let confettiLayer = CAEmitterLayer()
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: -20)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 2)

        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen,
            .systemOrange, .systemPurple, .systemYellow, .systemPink
        ]

        confettiLayer.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 8
            cell.lifetime = 6
            cell.velocity = 200
            cell.velocityRange = 80
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3.5
            cell.spinRange = 4
            cell.scale = 0.06
            cell.scaleRange = 0.04
            cell.color = color.cgColor
            cell.contents = uniformConfettiImage().cgImage
            return cell
        }

        view.layer.addSublayer(confettiLayer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confettiLayer.birthRate = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 9.5) {
            confettiLayer.removeFromSuperlayer()
        }
    }

    private func uniformConfettiImage() -> UIImage {
        let size = CGSize(width: 32, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let ctx = context.cgContext
            ctx.setFillColor(UIColor.white.cgColor)

            if Bool.random() {
                ctx.fill(CGRect(origin: .zero, size: size))
            } else {
                let radius = min(size.width, size.height) / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                ctx.addArc(
                    center: center,
                    radius: radius,
                    startAngle: 0,
                    endAngle: .pi * 2,
                    clockwise: false
                )
                ctx.fillPath()
            }
        }
    }
    
    func buildUnifiedResultScreen(
        title: String,
        symbolName: String?,
        emojiText: String?,
        message: String,
        stats: [(String, String)],
        themeColor: UIColor,
        finishAction: Selector
    ) {
        // Clear storyboard/existing views
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = .systemBackground

        // ── Title Label (large, centered, at the top) ──────────────────────
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // ── Icon Emoji (custom if provided, else 👏) ─────────────────────
        let iconLabel = UILabel()
        iconLabel.text = emojiText ?? "👏"
        iconLabel.font = .systemFont(ofSize: 100)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false

        // ── Message Label ──────────────────────────────────────────────────
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 17, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        // ── Stats Card ────────────────────────────────────────────────────
        let statsCard = UIView()
        statsCard.backgroundColor = .systemBackground
        statsCard.layer.cornerRadius = 24
        statsCard.layer.masksToBounds = false
        statsCard.layer.shadowColor = UIColor.black.cgColor
        statsCard.layer.shadowOpacity = 0.09
        statsCard.layer.shadowRadius = 4
        statsCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        statsCard.translatesAutoresizingMaskIntoConstraints = false

        let statColumns = stats.map { stat -> UIStackView in
            let colTitleLabel = UILabel()
            colTitleLabel.text = stat.0
            colTitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
            colTitleLabel.textColor = .black
            colTitleLabel.textAlignment = .center

            let colValueLabel = UILabel()
            colValueLabel.text = stat.1
            colValueLabel.font = .systemFont(ofSize: 24, weight: .bold)
            colValueLabel.textColor = .black
            colValueLabel.textAlignment = .center

            let stack = UIStackView(arrangedSubviews: [colValueLabel, colTitleLabel])
            stack.axis = .vertical
            stack.spacing = 4
            stack.alignment = .center
            stack.distribution = .fill
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }

        let makeDivider: () -> UIView = {
            let v = UIView()
            v.backgroundColor = UIColor.separator
            v.translatesAutoresizingMaskIntoConstraints = false
            v.widthAnchor.constraint(equalToConstant: 1).isActive = true
            return v
        }

        let statViews: [UIView] = statColumns.enumerated().flatMap { index, col -> [UIView] in
            index == 0 ? [col] : [makeDivider(), col]
        }

        let statsRowStack = UIStackView(arrangedSubviews: statViews)
        statsRowStack.axis = .horizontal
        statsRowStack.alignment = .fill
        statsRowStack.distribution = .fill
        statsRowStack.translatesAutoresizingMaskIntoConstraints = false
        statsCard.addSubview(statsRowStack)

        // ── Body stack (icon + message + stats card) centred on screen ─────
        let bodyStack = UIStackView(arrangedSubviews: [iconLabel, messageLabel, statsCard])
        bodyStack.axis = .vertical
        bodyStack.spacing = 20
        bodyStack.alignment = .center
        bodyStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bodyStack)

        // ── Finish Button (pinned to bottom safe area) ─────────────────────
        var config = UIButton.Configuration.filled()
        config.title = "Finish"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.buttonSize = .large

        let finishButton = UIButton(configuration: config)
        finishButton.addTarget(self, action: finishAction, for: .touchUpInside)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(finishButton)

        NSLayoutConstraint.activate([
            // Title: top of safe area, centred
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Body stack: centred vertically, shifted slightly up
            bodyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bodyStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            bodyStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bodyStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Icon
            iconLabel.widthAnchor.constraint(equalTo: bodyStack.widthAnchor),

            // Message
            messageLabel.leadingAnchor.constraint(equalTo: bodyStack.leadingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: bodyStack.trailingAnchor, constant: -8),

            // Stats card: full width
            statsCard.leadingAnchor.constraint(equalTo: bodyStack.leadingAnchor),
            statsCard.trailingAnchor.constraint(equalTo: bodyStack.trailingAnchor),

            // Stats row inside card
            statsRowStack.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 20),
            statsRowStack.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -20),
            statsRowStack.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 16),
            statsRowStack.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -16),

            // Finish button: pinned to bottom safe area
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            finishButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 54)
        ])

        // Equal widths for stat columns
        if let firstColumn = statColumns.first {
            NSLayoutConstraint.activate(statColumns.dropFirst().map {
                $0.widthAnchor.constraint(equalTo: firstColumn.widthAnchor)
            })
        }
    }
}
