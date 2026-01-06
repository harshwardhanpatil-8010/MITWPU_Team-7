////
////  exercise.swift
////  Parkinson's App
////
////  Created by SDC-USER on 25/11/25.
////

import Foundation

enum ExerciseCategory: String, CaseIterable {
    case warmup = "Warm Up / Stretching"
    case balance = "Balance / Agility"
    case aerobic = "Aerobic"
    case strength = "Strength"
    case cooldown = "Cool Down / Deep Breathing"
}

enum ExercisePosition {
    case seated
    case standing
}

struct WorkoutExercise: Identifiable {
    let id = UUID()
    let name: String
    var reps: Int
    let videoID: String?
    let description: String
    let category: ExerciseCategory
    let position: ExercisePosition
    let targetJoints: [String]
    
    let benefits: String
    let stepsToPerform: String
}
