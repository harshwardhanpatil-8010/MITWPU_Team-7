//
//  exercise.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import Foundation

struct ExerciseStoreItem: Codable {
    let id: UUID
    let name: String
    let videoID: String
    let category: String
    let reps: Int
    let minReps: Int
    let maxReps: Int
    let skipCount: Int
    let isSuppressed: Bool
    let suppressedUntil: Date
    let description: String
    let Benefits: String
    let stepsToPerform: String
}
