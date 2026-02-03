////
////  exercise.swift
////  Parkinson's App
////
////  Created by SDC-USER on 25/11/25.
////
import Foundation

enum ExerciseCategory: String, CaseIterable, Codable {
    case warmup
    case balance
    case aerobic
    case strength
    case cooldown
}


enum ExercisePosition: String, Codable {
    case seated
    case standing
}

enum MedicationEffect {
    case optimal
    case wearingOff
    case offPeriod 
}

struct WorkoutExercise: Codable, Identifiable {
    let id: UUID
    let name: String
    var reps: Int
    let videoID: String?
    let description: String
    let category: ExerciseCategory
    let position: ExercisePosition
    let targetJoints: [String]
    let benefits: String
    let stepsToPerform: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case reps
        case videoID
        case description
        case category
        case position
        case targetJoints
        case benefits
        case stepsToPerform
    }
}
