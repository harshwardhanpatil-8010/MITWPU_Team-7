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
// Each dose belongs to a medication and tracks:
// - ID
// - Time of day
// - Whether it was taken or skipped
// - The parent medication's ID
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
// This describes how often a medication repeats:
// - everyday
// - weekly (selected weekdays 1...7)
// - none (one-time)
// Also conforms to Codable for saving
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
// Represents a full medication entry:
// - ID
// - Name
// - Form (tablet, capsule, etc.)
// - Unit and strength
// - Icon name for UI display
// - Repeat schedule
// - All doses for that medication
// - Creation timestamp
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

    // Returns weekday numbers only if .weekly
    var weekdayNumbers: [Int] {
        switch self {
        case .weekly(let days):
            return days
        default:
            return []
        }
    }

    // Display friendly string: "Everyday", "Sun, Mon", etc.
    func displayString() -> String {
        switch self {

        case .everyday:
            return "Everyday"

        case .none:
            return "None"

        case .weekly(let days):
            let formatter = DateFormatter()
            let weekdays = formatter.shortWeekdaySymbols! // Sun, Mon, Tue...

            let names = days.compactMap { index -> String? in
                guard index >= 1, index <= weekdays.count else { return nil }
                return weekdays[index - 1]
            }

            return names.joined(separator: ", ")
        }
    }
}
