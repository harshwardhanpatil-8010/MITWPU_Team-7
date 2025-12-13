import Foundation

enum DoseStatus: String, Codable {
    case none, taken, skipped
}

struct MedicationDose: Codable, Identifiable {
    let id: UUID
    var time: Date         // we'll store a full Date but treat it as time-of-day
    var status: DoseStatus
    var medicationID: UUID
}

enum RepeatRule: Codable {
    case everyday
    case weekly([Int]) // weekday numbers 1...7 (Sun...Sat)
    case none

    private enum CodingKeys: String, CodingKey { case type, days }

    private enum RepeatType: String, Codable {
        case everyday, weekly, none
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(RepeatType.self, forKey: .type)
        switch type {
        case .everyday: self = .everyday
        case .none: self = .none
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

struct Medication : Codable{
    let id: UUID
    var name: String
    var form: String
    var unit: String        // ← ADD THIS
    var strength: Int?      // ← OPTIONAL
    var iconName: String
    var schedule: RepeatRule
    var doses: [MedicationDose]
    let createdAt: Date
}

extension RepeatRule {
    var weekdayNumbers: [Int] {
            switch self {
            case .weekly(let days): return days
            default: return []
            }
        }
    func displayString() -> String {
        switch self {
        case .everyday:
            return "Everyday"

        case .none:
            return "None"

        case .weekly(let days):
            let formatter = DateFormatter()
            let weekdays = formatter.shortWeekdaySymbols!  // always exists (Sun, Mon, ...)

            let names = days.compactMap { day -> String? in
                guard day >= 1 && day <= weekdays.count else { return nil }
                return weekdays[day - 1]
            }

            return names.joined(separator: ", ")
        }
    }
}


