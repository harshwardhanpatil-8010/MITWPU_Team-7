import Foundation

// ---------------------------------------------------------
// MARK: - Dose Status (Taken / Skipped / None)
// ---------------------------------------------------------
enum DoseStatus: String, Codable {
    case none
    case taken
    case skipped
}

// ---------------------------------------------------------
// MARK: - A Single Medication Dose Entry
// ---------------------------------------------------------

struct MedicationDose: Codable, Identifiable {
    let id: UUID
    var time: Date            // stored as a Date, but used mainly for time-of-day
    var status: DoseStatus
    var medicationID: UUID
}

// ---------------------------------------------------------
// MARK: - Medication Repeat Rule
// ---------------------------------------------------------

enum RepeatRule: Codable {
    case everyday
    case weekly([Int])        // 1 = Sunday ... 7 = Saturday
    case none

    private enum CodingKeys: String, CodingKey {
        case type
        case days
    }

    private enum RepeatType: String, Codable {
        case everyday
        case weekly
        case none
    }

    // Custom decoding for enum with associated values
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

    // Custom encoding for enum with associated values
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

// ---------------------------------------------------------
// MARK: - Medication Model
// ---------------------------------------------------------

struct Medication: Codable {
    let id: UUID
    var name: String
    var form: String
    var unit: String          // e.g., mg / ml
    var strength: Int?        // optional
    var iconName: String
    var schedule: RepeatRule
    var doses: [MedicationDose]
    let createdAt: Date
}

// ---------------------------------------------------------
// MARK: - RepeatRule Helpers
// ---------------------------------------------------------
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
                let fmt = DateFormatter()
                fmt.locale = Locale(identifier: "en_US")
                let weekdayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                return days.map { weekdayNames[$0 - 1] }.joined(separator: ", ")
            }
        }
    }
}
