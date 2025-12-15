//
// medicationSummary.swift
// Parkinsons
//
// Created by SDC-USER on 15/12/25.
//


import UIKit

class MedicationSummaryCell: UICollectionViewCell {
    
    // Connect these outlets from your XIB:
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amPmLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel! // Used for the checkmark/status text
    @IBOutlet weak var medicationIconImageView: UIImageView!
    
    // Outlet for the main background card (for styling)
    @IBOutlet weak var backgroundCardView: UIView!
    
    static let reuseIdentifier = "MedicationSummaryCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Ensure clipping is disabled on the cell and contentView to allow the shadow to show
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        // ⭐️ STEP 1: Apply Shadow and Corner Radius ⭐️
        setupCardStyle()
        
        // Style the icon area (assuming it's a circle)
        medicationIconImageView.layer.cornerRadius = medicationIconImageView.frame.height / 2.0
        medicationIconImageView.clipsToBounds = true
    }

    // ⭐️ NEW: Function to apply consistent card styling (Shadow and Corner Radius) ⭐️
    func setupCardStyle() {
        let cornerRadius: CGFloat = 12 // Matches the radius you previously set
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.1 // A lighter shadow looks modern
        let shadowRadius: CGFloat = 8 // Softness of the shadow
        let shadowOffset: CGSize = .init(width: 0, height: 4) // Vertical drop shadow

        // Apply Corner Radius
        backgroundCardView.layer.cornerRadius = cornerRadius

        // Disable clipping on the background view layer itself
        // This is crucial for displaying the shadow
        backgroundCardView.layer.masksToBounds = false

        // Apply Shadow properties
        backgroundCardView.layer.shadowColor = shadowColor.cgColor
        backgroundCardView.layer.shadowOpacity = shadowOpacity
        backgroundCardView.layer.shadowRadius = shadowRadius
        backgroundCardView.layer.shadowOffset = shadowOffset
    }

    // Ensure circularity and shadow path are maintained when layout changes
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // ⭐️ IMPORTANT: Update the shadow path for performance and accuracy ⭐️
        backgroundCardView.layer.shadowPath = UIBezierPath(
            roundedRect: backgroundCardView.bounds,
            cornerRadius: backgroundCardView.layer.cornerRadius
        ).cgPath
        
        medicationIconImageView.layer.cornerRadius = medicationIconImageView.frame.height / 2.0
    }
    
    // Configuration function (using the existing model for now)
    func configure(with model: MedicationModel, totalTaken: Int, totalScheduled: Int) {
            
            let timeParts = model.time.split(separator: " ")
            timeLabel.text = String(timeParts.first ?? "9:00")
            amPmLabel.text = String(timeParts.last ?? "AM")
            
            nameLabel.text = model.name
            detailLabel.text = model.detail
            
            // ⭐️ FIX 1: Load custom image from Assets ⭐️
            medicationIconImageView.image = UIImage(named: model.iconName)
            medicationIconImageView.backgroundColor = .systemBlue
            medicationIconImageView.tintColor = .white
            
            let totalRemaining = totalScheduled - totalTaken
            
            // ⭐️ FIX 2: Implement icon for 'Completed' status ⭐️
            if totalScheduled == 0 {
                statusLabel.text = "No meds scheduled"
                statusLabel.textColor = .systemGray
            } else if totalTaken == totalScheduled {
                // Use SF Symbol for checkmark
                let checkmarkImage = UIImage(systemName: "checkmark.circle.fill")
                let checkmarkAttachment = NSTextAttachment(image: checkmarkImage!)
                
                // Optional: Adjust the size/baseline of the checkmark to align with text
                // checkmarkAttachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
                
                let attributedString = NSMutableAttributedString(string: "")
                attributedString.append(NSAttributedString(attachment: checkmarkAttachment))
                attributedString.append(NSAttributedString(string: " Completed")) // Add "Completed" text next to the icon
                
                statusLabel.attributedText = attributedString
                statusLabel.textColor = .systemGreen
                
            } else if totalTaken > 0 {
                // Example: "1 / 2 taken"
                statusLabel.attributedText = nil // Clear attributed text for regular string
                statusLabel.text = "\(totalTaken) / \(totalScheduled) taken"
                statusLabel.textColor = .systemOrange
            } else {
                // Example: "2 remaining"
                statusLabel.attributedText = nil
                statusLabel.text = "\(totalScheduled) remaining"
                statusLabel.textColor = .systemRed
            }
        }
    }
