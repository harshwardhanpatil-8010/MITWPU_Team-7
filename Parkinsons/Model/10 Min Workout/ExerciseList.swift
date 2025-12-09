//
//  ExerciseList.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation

class ExerciseStore {
    static let shared = ExerciseStore()
    private let key = "exercise_store"
    private(set) var exercises: [ExerciseStoreItem] = []

    private init() {
        load()
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ExerciseStoreItem].self, from: data) {
            exercises = decoded
        } else {
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
    }

    private func defaultExercises() -> [ExerciseStoreItem] {
        return [
            ExerciseStoreItem(
                id: UUID(),
                name: "Neck Stretches",
                videoID: "uOljoOvycuo",  // Power for Parkinson's - Gentle Neck Stretches
                category: "stretch",
                reps: 10,
                minReps: 5,
                maxReps: 15,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
                
            ),

            ExerciseStoreItem(
                id: UUID(),
                name: "Shoulder Rolls",
                videoID: "VQJ6KFlUBAI",  // Shoulder Stretches for Parkinson's
                category: "stretch",
                reps: 10,
                minReps: 5,
                maxReps: 15,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
            ),

            ExerciseStoreItem(
                id: UUID(),
                name: "Seated Chest Stretch",
                videoID: "_iomTrSv_N0",  // Stretching exercises for Parkinson's
                category: "stretch",
                reps: 8,
                minReps: 5,
                maxReps: 12,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
            ),

            ExerciseStoreItem(
                id: UUID(),
                name: "Hamstring Stretch",
                videoID: "Gh8cZ_W2vR4",  // Seated Hamstring Stretch for Parkinson's
                category: "stretch",
                reps: 8,
                minReps: 5,
                maxReps: 12,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
            ),

            ExerciseStoreItem(
                id: UUID(),
                name: "Full Body Stretching",
                videoID: "WRyPQO_u_qE",  // Gentle Stretching Routine
                category: "stretch",
                reps: 10,
                minReps: 5,
                maxReps: 15,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
            ),

            // STRENGTH EXERCISES (5)
            ExerciseStoreItem(
                id: UUID(),
                name: "Seated Arm Raises",
                videoID: "TB_CtNHtMUA",  // Upper Body Strength for Parkinson's
                category: "strength",
                reps: 10,
                minReps: 5,
                maxReps: 15,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
            ),

            ExerciseStoreItem(
                id: UUID(),
                name: "Leg Strengthening",
                videoID: "SbGL0J5qh9s",  // Lower Body Strength Exercises
                category: "strength",
                reps: 10,
                minReps: 5,
                maxReps: 15,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
            ),

            ExerciseStoreItem(
                id: UUID(),
                name: "Core Strengthening",
                videoID: "KQJrM2-oGY4",  // Core Exercises for Parkinson's
                category: "strength",
                reps: 10,
                minReps: 5,
                maxReps: 15,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
            ),

            ExerciseStoreItem(
                id: UUID(),
                name: "Resistance Band Exercises",
                videoID: "95seVUPTcEg",  // Resistance Training
                category: "strength",
                reps: 12,
                minReps: 8,
                maxReps: 15,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
            ),

            ExerciseStoreItem(
                id: UUID(),
                name: "Chair Exercises",
                videoID: "zIFtb-R24Ec",  // Seated Strength Workout
                category: "strength",
                reps: 10,
                minReps: 5,
                maxReps: 15,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
            ),

            // BALANCE EXERCISES (5)
            ExerciseStoreItem(
                id: UUID(),
                name: "Standing Balance",
                videoID: "Wz5IXboB7zM",  // Balance Training for Parkinson's
                category: "balance",
                reps: 8,
                minReps: 5,
                maxReps: 12,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
            ),

            ExerciseStoreItem(
                id: UUID(),
                name: "Tandem Walking",
                videoID: "zWUvZPWhT-w",  // Gait and Balance Exercises
                category: "balance",
                reps: 10,
                minReps: 5,
                maxReps: 15,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast,
                description: "A simple aerobic exercise where you lift your knees alternately as if walking or marching, either in place or moving forward.",
                Benefits: "Improves leg strength and coordination.Boosts heart rate and cardiovascular fitness.Enhances balance and posture.Aids joint mobility—especially beneficial for seniors or people with Parkinson’s.Can be done anywhere, no equipment needed.",
                stepsToPerform: "Stand upright with feet hip-width apart. Lift one knee to hip level while swinging the opposite arm. Lower it and repeat with the other leg. Continue at a steady rhythm; you can increase speed or lift height for intensity."
            )
            ]
    }
}
