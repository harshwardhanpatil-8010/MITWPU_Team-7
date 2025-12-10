// SectionHeaderView.swift

import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "HeaderView" // Consistent with the string used in HomeViewController
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Basic setup for the label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold) // Set font style
        titleLabel.textColor = .black
        addSubview(titleLabel)
        
        // Add constraints to pin the label inside the header view
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8), // Align with section inset
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Function to set the title text
    func configure(title: String) {
        titleLabel.text = title
    }
    func setTitleAlignment(_ alignment: NSTextAlignment) {
        titleLabel.textAlignment = alignment
    }
}
