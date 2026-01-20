import UIKit

// MARK: - Delegate Protocol (Place this in the cell file or a common file)
protocol HealthPermissionCellDelegate: AnyObject {
    func switchStateDidChange(cell: HealthPermissionTableViewCell, isOn: Bool)
}

class HealthPermissionTableViewCell: UITableViewCell {

    @IBOutlet weak var cellIcon: UIImageView!
    @IBOutlet weak var cellSwitch: UISwitch!
    @IBOutlet weak var cellLabel: UILabel!
    
    // 1. ADD: Delegate property
    weak var delegate: HealthPermissionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // 2. ADD: IBAction for the UISwitch
    @IBAction func switchValueDidChange(_ sender: UISwitch) {
        // This line sends the signal back to the View Controller
        delegate?.switchStateDidChange(cell: self, isOn: sender.isOn)
    }

    func configure(with setting: HealthPermissionSetting) {
        cellIcon.image = UIImage(systemName: setting.iconName)
        cellLabel.text = setting.labelText
        
        // Apply optional icon tint color
        if let color = setting.iconColor {
            cellIcon.tintColor = color
        } else {
            cellIcon.tintColor = .label // sensible default
        }
        
        // 3. Important: Use setOn to prevent infinite loops during cell reuse
        cellSwitch.setOn(setting.isEnabled, animated: false)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
