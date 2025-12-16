import UIKit

class MedicationSummaryCell: UICollectionViewCell {
    
    // Connect these outlets from your XIB:
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amPmLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var medicationIconImageView: UIImageView!
    
    // Outlet for the main background card (for styling)
    @IBOutlet weak var backgroundCardView: UIView!
    
    static let reuseIdentifier = "MedicationSummaryCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        let cornerRadius: CGFloat = 12
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.1
        let shadowRadius: CGFloat = 8
        let shadowOffset: CGSize = .init(width: 0, height: 4)

        // Apply Corner Radius
        backgroundCardView.layer.cornerRadius = cornerRadius

        // Disable clipping on the background view layer itself
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
            
            // MARK: - Updated Status Label Logic (Checkmark or Xmark)
            
            if totalScheduled == 0 {
                statusLabel.attributedText = nil
                statusLabel.text = "No schedule"
                statusLabel.textColor = .systemGray
            } else if totalTaken == totalScheduled {
                // Status: Taken (Green Checkmark)
                let checkmarkImage = UIImage(systemName: "checkmark.circle.fill")
                let checkmarkAttachment = NSTextAttachment(image: checkmarkImage!.withTintColor(.systemGreen))
                
                let attributedString = NSMutableAttributedString(string: "")
                attributedString.append(NSAttributedString(attachment: checkmarkAttachment))
                attributedString.append(NSAttributedString(string: " Taken"))
                
                statusLabel.attributedText = attributedString
                statusLabel.textColor = .systemGreen
                
            } else {
                // Status: Not Taken or Partially Taken (Red Xmark)
                let xmarkImage = UIImage(systemName: "xmark.circle.fill")
                let xmarkAttachment = NSTextAttachment(image: xmarkImage!.withTintColor(.systemRed))

                let attributedString = NSMutableAttributedString(string: "")
                attributedString.append(NSAttributedString(attachment: xmarkAttachment))
                
                let statusText: String
                if totalTaken > 0 {
                    statusText = " \(totalTaken)/\(totalScheduled) Partial"
                } else {
                    statusText = " Not Taken"
                }
                
                attributedString.append(NSAttributedString(string: statusText))
                
                statusLabel.attributedText = attributedString
                statusLabel.textColor = .systemRed
            }
        }
    }
