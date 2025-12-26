////
////  exercise.swift
////  Parkinson's App
////
////  Created by SDC-USER on 25/11/25.
////
//
//import Foundation
//
//struct ExerciseStoreItem: Codable {
//    let id: UUID
//    let name: String
//    let videoID: String
//    let category: String
//    let reps: Int
//    let minReps: Int
//    let maxReps: Int
//    let skipCount: Int
//    let isSuppressed: Bool
//    let suppressedUntil: Date
//    let description: String
//    let Benefits: String
//    let stepsToPerform: String
//}


import Foundation

enum ExerciseCategory: String, Codable, CaseIterable {
    case warmup     // Neuro-Primer
    case balance    // Coordination
    case aerobic    // The Peak (BDNF)
    case strength   // Functional
    case stretch    // Reset
}

struct Exercise: Codable, Identifiable {
    let id: UUID
    let name: String
    let category: ExerciseCategory
    let videoID: String
    let seatedVideoID: String?      // For "Off" Medication status
    let metronomeBPM: Int           // Audio Stimulation (approx 100-110)
    let cognitiveTask: String?      // Dual-Task Factor
    
    // Performance Tracking
    var reps: Int
    let minReps: Int
    let maxReps: Int
    var isSuppressed: Bool = false  // For "Post-Session Recovery" logic
    
    // UI Content
    let description: String
    let benefits: String
    let steps: String
}
