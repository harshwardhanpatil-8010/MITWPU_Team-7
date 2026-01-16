import Foundation
import UIKit
struct MedicationDose: Codable, Identifiable {
    let id: UUID
    var time: Date
    var status: DoseStatus
    var medicationID: UUID
}

enum RepeatRule: Codable, Equatable {
    case everyday
    case weekly([Int])
    case none

    private enum CodingKeys: String, CodingKey {
        case type, days
    }

    private enum RepeatType: String, Codable {
        case everyday, weekly, none
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(RepeatType.self, forKey: .type)

        switch type {
        case .everyday:
            self = .everyday
        case .none:
            self = .none
        case .weekly:
            let days = try container.decode([Int].self, forKey: .days)
            self = .weekly(days)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .everyday:
            try container.encode(RepeatType.everyday, forKey: .type)
        case .none:
            try container.encode(RepeatType.none, forKey: .type)
        case .weekly(let days):
            try container.encode(RepeatType.weekly, forKey: .type)
            try container.encode(days, forKey: .days)
        }
    }
}

struct Medication: Codable {
    let id: UUID
    var name: String
    var form: String
    var unit: String
    var strength: Int?
    var iconName: String
    var schedule: RepeatRule
    var doses: [MedicationDose]
    let createdAt: Date
}

extension RepeatRule {
    func displayString() -> String {
        switch self {
        case .everyday:
            return "Everyday"
        case .none:
            return "None"
        case .weekly(let days):
            if Set(days) == Set([1,2,3,4,5,6,7]) {
                return "Everyday"
            } else {
                let weekdayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                return days
                    .sorted()
                    .map { weekdayNames[$0 - 1] }
                    .joined(separator: ", ")
            }
        }
    }
    
    func weekdayAttributedString(
            selectedColor: UIColor = .systemBlue,
            unselectedColor: UIColor = .systemGray3,
            font: UIFont = .systemFont(ofSize: 13, weight: .semibold)
        ) -> NSAttributedString {

            // Display order: Mon → Sun
            let display: [(label: String, dayIndex: Int)] = [
                ("M", 2),
                ("T", 3),
                ("W", 4),
                ("T", 5),
                ("F", 6),
                ("S", 7),
                ("S", 1)
            ]

            let result = NSMutableAttributedString()

            guard case .weekly(let days) = self else {
                return result
            }

            for item in display {
                let isSelected = days.contains(item.dayIndex)
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: isSelected ? selectedColor : unselectedColor,
                    .font: font
                ]
                result.append(NSAttributedString(string: item.label, attributes: attributes))
            }

            return result
        }
}
