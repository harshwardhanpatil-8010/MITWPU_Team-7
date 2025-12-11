// SymptomLogHistoryCell.swift

import UIKit

class SymptomLogHistoryCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    // Static reusable identifier
    static let reuseIdentifier = "SymptomLogHistoryCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .disclosureIndicator
    }
    
    // MARK: - Configuration Method
    
    func configure(with entry: SymptomLogEntry) {
        // 1. Format the Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateLabel.text = dateFormatter.string(from: entry.date)
        
        // 2. Generate the Symptom Summary
        // Filter out symptoms marked as .notPresent
        let presentSymptoms = entry.ratings.filter { $0.selectedIntensity != .notPresent }
        
        if presentSymptoms.isEmpty {
            summaryLabel.text = "No symptoms logged today."
            summaryLabel.textColor = .systemGray
        } else {
            // Map the names of the present symptoms and join them into a string
            let symptomNames = presentSymptoms.map { $0.name }
            summaryLabel.text = symptomNames.joined(separator: ", ")
            summaryLabel.textColor = .systemGray
            summaryLabel.numberOfLines = 2 // Allow wrapping if the summary is long
        }
    }
}
