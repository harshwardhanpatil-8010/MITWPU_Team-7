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

    func celebrationResultTitle() -> String {
        Bool.random() ? "Good Job!" : "Well Done!"
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
        navigationItem.largeTitleDisplayMode = .never
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 43, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        if let symbolName = symbolName {
            let symbolImageView = UIImageView(
                image: UIImage(systemName: symbolName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 100, weight: .semibold))
            )
            symbolImageView.tintColor = UIColor(red: 0.94, green: 0.71, blue: 0.45, alpha: 1)
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
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        let statsCard = UIView()
        statsCard.backgroundColor = .systemBackground
        statsCard.layer.cornerRadius = 18
        statsCard.layer.masksToBounds = false
        statsCard.layer.shadowColor = UIColor.black.cgColor
        statsCard.layer.shadowOpacity = 0.09
        statsCard.layer.shadowRadius = 4
        statsCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        statsCard.translatesAutoresizingMaskIntoConstraints = false

        let statColumns = stats.map { stat -> UIStackView in
            let colTitleLabel = UILabel()
            colTitleLabel.text = stat.0
            colTitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
            colTitleLabel.textColor = .black
            colTitleLabel.textAlignment = .center

            let colValueLabel = UILabel()
            colValueLabel.text = stat.1
            colValueLabel.font = .systemFont(ofSize: 22, weight: .bold)
            colValueLabel.textColor = .black
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

        let contentStack = UIStackView(arrangedSubviews: [iconContainer, messageLabel, statsCard])
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStack)
        view.addSubview(finishButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            contentStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -12),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            contentStack.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 24),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: finishButton.topAnchor, constant: -32),

            iconContainer.heightAnchor.constraint(equalToConstant: 142),
            iconContainer.widthAnchor.constraint(equalToConstant: 200),

            messageLabel.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -12),

            statsCard.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            statsCard.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            
            statsStack.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 18),
            statsStack.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -18),
            statsStack.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -16),

            finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35),
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
