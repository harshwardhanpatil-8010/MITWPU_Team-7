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

struct RhythmicSession: Codable, Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date?
    var requestedDurationSeconds: Int
    var elapsedSeconds: Int
    var beat: String
    var pace: String
    var steps: Int
    var distanceMeters: Double
    var speedKmH: Double {
        guard elapsedSeconds > 0 else { return 0 }
        return (distanceMeters / Double(elapsedSeconds)) * 3.6
    }

    var gaitSummary: GaitSummary?
    
    init(durationSeconds: Int, beat: String, pace: String) {
        self.id = UUID()
        self.startDate = Date()
        self.requestedDurationSeconds = requestedDurationSeconds
        self.elapsedSeconds = 0
        self.beat = beat
        self.pace = pace
        self.steps = 0
        self.distanceMeters = 0
        self.gaitSummary = nil
        self.endDate = nil
    }
}
