//
//  ExerciseList.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation

// MARK: - Exercise Store Item Model
struct ExerciseStoreItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let videoID: String
    let category: String
    var reps: Int
    let minReps: Int
    let maxReps: Int
    var skipCount: Int
    var isSuppressed: Bool
    var suppressedUntil: Date
    let description: String
    let Benefits: String
    let stepsToPerform: String
}

// MARK: - Exercise Store Manager
class ExerciseStore {
    static let shared = ExerciseStore()
    private let key = "exercise_store_v2" // Versioned key to prevent decoding errors
    private(set) var exercises: [ExerciseStoreItem] = []

    private init() {
        load()
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ExerciseStoreItem].self, from: data) {
            exercises = decoded
        } else {
            // First time setup
            exercises = defaultExercises()
            save()
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func replaceExercises(with items: [ExerciseStoreItem]) {
        exercises = items
        save()
    }

    // MARK: - Clinical Default List
    func defaultExercises() -> [ExerciseStoreItem] {
        return [
            // 1. NEURO-PRIMER (Warmup)
            ExerciseStoreItem(
                id: UUID(), name: "Big Trunk Rotations",
                videoID: "uOljoOvycuo", category: "warmup",
                reps: 10, minReps: 5, maxReps: 15,
                skipCount: 0, isSuppressed: false, suppressedUntil: .distantPast,
                description: "Large, deliberate torso rotations to loosen the spine.",
                Benefits: "Reduces rigidity and improves spinal mobility.",
                stepsToPerform: "Sit or stand tall. Rotate your shoulders and torso slowly from left to right, reaching back with your eyes."
            ),

            // 2. COORDINATION (Balance)
            ExerciseStoreItem(
                id: UUID(), name: "Weight Shifts",
                videoID: "Wz5IXboB7zM", category: "balance",
                reps: 12, minReps: 6, maxReps: 18,
                skipCount: 0, isSuppressed: false, suppressedUntil: .distantPast,
                description: "Shifting center of gravity safely between legs.",
                Benefits: "Enhances stability and reduces the risk of falls.",
                stepsToPerform: "Stand with feet hip-width apart. Slowly move your weight to the left foot, hold for 2 seconds, then shift to the right."
            ),

            // 3. THE PEAK (Aerobic - BDNF Release)
            ExerciseStoreItem(
                id: UUID(), name: "High Knee March",
                videoID: "March_ID", category: "aerobic",
                reps: 20, minReps: 10, maxReps: 40,
                skipCount: 0, isSuppressed: false, suppressedUntil: .distantPast,
                description: "Vigorous marching in place with exaggerated arm swings.",
                Benefits: "Boosts heart rate and triggers Neuroplasticity (BDNF).",
                stepsToPerform: "March in place, lifting knees as high as possible. Swing opposite arms high to encourage 'Big' movement."
            ),

            // 4. FUNCTIONAL STRENGTH
            ExerciseStoreItem(
                id: UUID(), name: "Sit-to-Stand",
                videoID: "zIFtb-R24Ec", category: "strength",
                reps: 10, minReps: 5, maxReps: 15,
                skipCount: 0, isSuppressed: false, suppressedUntil: .distantPast,
                description: "Standard chair squats focused on leg power.",
                Benefits: "Strengthens quads and glutes for independent living.",
                stepsToPerform: "Start seated. Lean forward slightly and stand up using leg strength. Sit back down slowly and with control."
            ),

            // 5. THE RESET (Stretch/Mindfulness)
            ExerciseStoreItem(
                id: UUID(), name: "Box Breathing",
                videoID: "WRyPQO_u_qE", category: "stretch",
                reps: 5, minReps: 3, maxReps: 10,
                skipCount: 0, isSuppressed: false, suppressedUntil: .distantPast,
                description: "A rhythmic breathing pattern to calm the nervous system.",
                Benefits: "Reduces anxiety and resets the Central Nervous System.",
                stepsToPerform: "Inhale for 4 seconds, hold for 4, exhale for 4, and hold empty for 4. Repeat."
            )
        ]
    }
}
