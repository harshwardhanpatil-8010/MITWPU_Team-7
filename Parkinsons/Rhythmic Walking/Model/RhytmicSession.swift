////
////  RhytmicSession.swift
////  Parkinson's App
////
////  Created by SDC-USER on 25/11/25.
////
//
//import Foundation
//
//
////struct GaitSummary: Codable {
////    var stepLengthMeters: Double
////    var walkingAsymmetryPercent: Double
////    var walkingSteadiness: String
////    
////    var stepLengthChangePercent: Double?
////    var asymmetryChangePercent: Double?
////    var steadinessChangePercent: Double?
////}
//
//struct GaitSummary: Codable {
//    var steps: Int
//    var distanceMeters: Double
//    var speedKmH: Double
//    var stepLengthMeters: Double
//    var walkingAsymmetryPercent: Double
//    var walkingSteadiness: String
//    
//    // Percentages for the secondary labels
//    var stepLengthChangePercent: Double = 0.0
//    var asymmetryChangePercent: Double = 0.0
//    var steadinessChangePercent: Double = 0.0
//}
//
//struct RhythmicSession: Codable, Identifiable {
//    let id: UUID
//    let sessionNumber: Int
//    let startDate: Date
//    var endDate: Date?
//    var requestedDurationSeconds: Int
//    var elapsedSeconds: Int
//    var beat: String
//    var pace: String
//
//}
//
//enum PaceConfig {
//    static func bpm(for pace: String) -> Int {
//        switch pace {
//        case "Slow":     return 80
//        case "Moderate": return 120
//        case "Fast":     return 140
//        default:         return 100
//        }
//    }
//}
//
import Foundation

// RhythmicSessionDTO.swift  ← rename from RhythmicSession
struct RhythmicSessionDTO: Codable, Identifiable {
    let id: UUID
    let sessionNumber: Int       // NOT in Core Data → stored in UserDefaults or computed
    let startDate: Date
    var endDate: Date?
    var requestedDurationSeconds: Int
    var elapsedSeconds: Int
    var beat: String             // NOT in Core Data → stored in UserDefaults or passed in memory
    var pace: String             // NOT in Core Data → stored in UserDefaults or passed in memory
}

extension RhythmicSessionDTO {
    
    init(from managed: RhythmicSession, sessionNumber: Int) {
        self.id                       = managed.id ?? UUID()
        self.startDate                = managed.startDate ?? Date()
        self.endDate                  = managed.endDate
        self.requestedDurationSeconds = Int(managed.requestedDuration)
        self.elapsedSeconds           = Int(managed.elapsedSeconds)
        self.sessionNumber            = sessionNumber
        
        let key = (managed.id ?? UUID()).uuidString
        self.beat = UserDefaults.standard.string(forKey: "beat_\(key)") ?? "Clock"
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
        case "Moderate": return 120
        case "Fast":     return 140
        default:         return 100
        }
    }
}


struct GaitSummary {
    var steps: Int
    var distanceMeters: Double
    var speedKmH: Double
    var stepLengthMeters: Double
    var walkingAsymmetryPercent: Double
    var walkingSteadiness: String        // "OK", "Low", "Very Low"
    
    var stepLengthChangePercent: Double = 0.0
    var asymmetryChangePercent: Double = 0.0
    var steadinessChangePercent: Double = 0.0
}
