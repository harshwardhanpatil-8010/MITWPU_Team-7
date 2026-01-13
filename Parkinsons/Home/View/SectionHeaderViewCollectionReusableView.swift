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
        
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0), // Align with section inset
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
                    
        ])
//        NSLayoutConstraint.activate([
//            // 1. Title Label Constraints (Top of the header)
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
//            // Removed titleLabel.bottomAnchor to bottomAnchor to allow the arrow to sit below it
//
//            // 2. Arrow Image Constraints (Centered and Larger)
//            arrowImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
//            arrowImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            
//            // Increased size here
//            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
//            arrowImageView.heightAnchor.constraint(equalToConstant: 20),
//            
//            // 3. Bottom Constraint (Pins everything together)
//            arrowImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2)
//        ])
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
