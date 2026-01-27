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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID() 
        self.name = try container.decode(String.self, forKey: .name)
        self.reps = try container.decode(Int.self, forKey: .reps)
        self.videoID = try container.decodeIfPresent(String.self, forKey: .videoID)
        self.description = try container.decode(String.self, forKey: .description)
        self.category = try container.decode(ExerciseCategory.self, forKey: .category)
        self.position = try container.decode(ExercisePosition.self, forKey: .position)
        self.targetJoints = try container.decode([String].self, forKey: .targetJoints)
        self.benefits = try container.decode(String.self, forKey: .benefits)
        self.stepsToPerform = try container.decode(String.self, forKey: .stepsToPerform)
    }
}

