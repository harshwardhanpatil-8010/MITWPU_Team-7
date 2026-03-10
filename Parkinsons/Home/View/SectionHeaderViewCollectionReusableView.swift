import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "HeaderView"
    let titleLabel = UILabel()
    
    // 1. Add the info button
    let infoButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let image = UIImage(systemName: "info.circle", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.isHidden = true // Hidden by default, only shown for specific sections
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Callback for the tap action
    var onInfoTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(infoButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Pin label to the leading edge
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            // Pin label to the trailing edge (important for text alignment to work)
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            infoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            infoButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 30),
            infoButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }
    
    @objc private func infoButtonTapped() {
        onInfoTap?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, showInfoIcon: Bool = false) {
        titleLabel.text = title
        infoButton.isHidden = !showInfoIcon
        
        // If we are showing the icon, we might need a slight offset
        // to keep the TEXT itself perfectly centered.
        // However, the constraints above usually handle this well.
    }

    func setTitleAlignment(_ alignment: NSTextAlignment) {
        titleLabel.textAlignment = alignment
    }

    func setFont(size: CGFloat, weight: UIFont.Weight) {
        titleLabel.font = UIFont.systemFont(ofSize: size, weight: weight)
    }
}
