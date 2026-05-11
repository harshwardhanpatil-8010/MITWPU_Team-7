

import Foundation

struct RhythmicSessionDTO: Codable, Identifiable {
    let id: UUID
    let sessionNumber: Int
    let startDate: Date
    var endDate: Date?
    var requestedDurationSeconds: Int
    var elapsedSeconds: Int
    var beat: String
    var pace: String
}

extension RhythmicSessionDTO {

    init(from managed: RhythmicSession, sessionNumber: Int) {
        let uid           = managed.id ?? UUID()
        self.id           = uid
        self.startDate    = managed.startDate ?? Date()
        self.endDate      = managed.endDate
        self.requestedDurationSeconds = Int(managed.requestedDuration)
        self.elapsedSeconds           = Int(managed.elapsedSeconds)
        self.sessionNumber            = sessionNumber

        let key  = uid.uuidString
        self.beat = UserDefaults.standard.string(forKey: "beat_\(key)") ?? "Click"
        self.pace = UserDefaults.standard.string(forKey: "pace_\(key)") ?? "Slow"
    }

    func saveExtras() {
        let key = id.uuidString
        UserDefaults.standard.set(beat, forKey: "beat_\(key)")
        UserDefaults.standard.set(pace, forKey: "pace_\(key)")
    }
}

enum PaceConfig {
    static func bpm(for pace: String) -> Int {
        switch pace {
        case "Slow":     return 80
        case "Moderate": return 100
        case "Fast":     return 120
        default:         return 80
        }
    }
}


struct GaitSummary {
    var steps: Int
    var distanceMeters: Double
    var speedKmH: Double
    var stepLengthMeters: Double
    var walkingAsymmetryPercent: Double
    var walkingSteadiness: String

    var stepLengthChangePercent: Double  = 0.0
    var asymmetryChangePercent: Double   = 0.0
    var steadinessChangePercent: Double  = 0.0
}
