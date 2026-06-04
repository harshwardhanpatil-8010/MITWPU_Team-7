//
//  UI view related.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
import UIKit

extension UIView {

    func applyCardStyle() {
        let cornerRadius: CGFloat = 30
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.15

        let shadowRadius: CGFloat = 3
        let shadowOffset: CGSize = .init(width: 0, height: 1)

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
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 40, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        if let symbolName = symbolName {
            let symbolImageView = UIImageView(
                image: UIImage(systemName: symbolName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 100, weight: .semibold))
            )
            symbolImageView.tintColor = themeColor
            symbolImageView.contentMode = .scaleAspectFit
            symbolImageView.translatesAutoresizingMaskIntoConstraints = false
            iconContainer.addSubview(symbolImageView)
            NSLayoutConstraint.activate([
                symbolImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                symbolImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                symbolImageView.widthAnchor.constraint(equalTo: iconContainer.widthAnchor),
                symbolImageView.heightAnchor.constraint(equalTo: iconContainer.heightAnchor)
            ])
        } else if let emojiText = emojiText {
            let emojiLabel = UILabel()
            emojiLabel.text = emojiText
            emojiLabel.font = .systemFont(ofSize: 100)
            emojiLabel.textAlignment = .center
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            iconContainer.addSubview(emojiLabel)
            NSLayoutConstraint.activate([
                emojiLabel.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                emojiLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                emojiLabel.widthAnchor.constraint(equalTo: iconContainer.widthAnchor),
                emojiLabel.heightAnchor.constraint(equalTo: iconContainer.heightAnchor)
            ])
        }

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 20, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        let statsCard = UIView()
        statsCard.backgroundColor = .secondarySystemBackground
        statsCard.layer.cornerRadius = 24
        statsCard.translatesAutoresizingMaskIntoConstraints = false

        let statColumns = stats.map { stat -> UIStackView in
            let colTitleLabel = UILabel()
            colTitleLabel.text = stat.0
            colTitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
            colTitleLabel.textColor = .secondaryLabel
            colTitleLabel.textAlignment = .center

            let colValueLabel = UILabel()
            colValueLabel.text = stat.1
            colValueLabel.font = .systemFont(ofSize: 22, weight: .bold)
            colValueLabel.textColor = themeColor
            colValueLabel.textAlignment = .center

            let stack = UIStackView(arrangedSubviews: [colTitleLabel, colValueLabel])
            stack.axis = .vertical
            stack.spacing = 6
            stack.alignment = .center
            stack.distribution = .fill
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }

        let dividerView: () -> UIView = {
            let view = UIView()
            view.backgroundColor = .separator
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: 1).isActive = true
            return view
        }

        let statViews = statColumns.enumerated().flatMap { index, column -> [UIView] in
            index == 0 ? [column] : [dividerView(), column]
        }

        let statsStack = UIStackView(arrangedSubviews: statViews)
        statsStack.axis = .horizontal
        statsStack.alignment = .fill
        statsStack.distribution = .fill
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsCard.addSubview(statsStack)

        var config = UIButton.Configuration.filled()
        config.title = "Finish"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule

        let finishButton = UIButton(type: .system)
        finishButton.configuration = config
        finishButton.addTarget(self, action: finishAction, for: .touchUpInside)
        finishButton.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, iconContainer, messageLabel, statsCard, finishButton])
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            iconContainer.heightAnchor.constraint(equalToConstant: 120),
            iconContainer.widthAnchor.constraint(equalToConstant: 120),

            messageLabel.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -12),

            statsCard.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            statsCard.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            
            statsStack.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 18),
            statsStack.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -18),
            statsStack.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -16),

            finishButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 180),
            finishButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])

        if let firstColumn = statColumns.first {
            NSLayoutConstraint.activate(statColumns.dropFirst().map {
                $0.widthAnchor.constraint(equalTo: firstColumn.widthAnchor)
            })
        }
    }
}
