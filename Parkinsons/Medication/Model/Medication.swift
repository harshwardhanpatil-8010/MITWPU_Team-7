import Foundation
import UIKit
struct MedicationDose: Codable, Identifiable {
    let id: UUID 
    var time: Date
    var status: DoseStatus
    var medicationID: UUID // foreign key
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
            if days.count == 7 { return "Everyday" }
            
            // Uses the system's localized "Short" symbols (Mon, Tue, etc.)
            let symbols = Calendar.current.shortWeekdaySymbols
            return days
                .sorted()
                .compactMap { dayIndex in
                    // Adjusting for 1-based index (Sun=1) to 0-based array
                    return symbols[safe: dayIndex - 1]
                }
                .joined(separator: ", ")
        }
    }
}

// Helper to prevent crashes if an invalid Int is passed
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
