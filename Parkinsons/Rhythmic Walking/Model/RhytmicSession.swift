//
//  RhytmicSession.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import Foundation


struct GaitSummary: Codable {
    var stepLengthMeters: Double
    var walkingAsymmetryPercent: Double
    var walkingSteadiness: String
    
    var stepLengthChangePercent: Double?
    var asymmetryChangePercent: Double?
    var steadinessChangePercent: Double?
}

var gaitDemoInfo: GaitSummary = .init(stepLengthMeters: 0.8, walkingAsymmetryPercent: 0.1, walkingSteadiness: "Good")

struct RhythmicSession: Codable, Identifiable {
    let id: UUID
    let startDate: Date
    var endDate: Date?
    var requestedDurationSeconds: Int
    var elapsedSeconds: Int
    var beat: String
    var pace: String
    var steps: Int
    var distanceKMeters: Double
    var speedKmH: Double {
        guard elapsedSeconds > 0 else { return 0 }
        return (distanceKMeters / Double(elapsedSeconds)) * 3.6
    }


//    var gaitSummary: GaitSummary?
//    
//    init(durationSeconds: Int, beat: String, pace: String) {
//        self.id = UUID()
//        self.startDate = Date()
//        self.requestedDurationSeconds = 0
//        self.elapsedSeconds = 0
//        self.beat = beat
//        self.pace = pace
//        self.steps = 2431
//        self.distanceKMeters = 2.6
//        self.gaitSummary = nil
//        self.endDate = nil
//        
//    }
}
var WalkingSessionDemo: RhythmicSession = .init(id: UUID(), startDate: Date(), endDate: nil, requestedDurationSeconds: 0, elapsedSeconds: 0, beat: "4/4", pace: "Slow", steps: 2431, distanceKMeters: 2.6)

