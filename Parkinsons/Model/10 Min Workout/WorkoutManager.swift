//
//  WorkoutManager.swift
//  Parkinsons
//
//  Created by Unnatti Gogna on 25/12/25.
//

import Foundation

struct WorkoutExercise: Identifiable {
    let id = UUID()
    let name: String
    let reps: Int
    let videoID: String?
    let description: String
    let benefits: [String]
    let stepsToPerform: [String]
}

class WorkoutManager {
    static let shared = WorkoutManager()
    
    var exercises: [WorkoutExercise] = []
    var completedToday: [UUID] = []
    var SkippedToday: [UUID] = []
    
    private init() {
        loadBaseExercises()
    }
    
    private func loadBaseExercises() {
        self.exercises = [
            // 1. FLOOR TO CEILING (Stretch & Amplitude)
            WorkoutExercise(
                name: "Floor to Ceiling",
                reps: 8,
                videoID: "jyOk-2DmVnU",
                description: "A full-body reach from the floor to the sky.",
                benefits: ["Improves posture", "Reduces trunk rigidity"],
                stepsToPerform: ["Sit on the edge of a chair", "Reach down and touch the floor", "Explode upward and reach for the ceiling"]
            ),
            // 2. SIDE TO SIDE (Lateral Balance)
            WorkoutExercise(
                name: "Side to Side Reach",
                reps: 10,
                videoID: "jyOk-2DmVnU",
                description: "Large reaches across the body.",
                benefits: ["Improves lateral stability", "Reduces risk of falls"],
                stepsToPerform: ["Spread arms wide", "Reach across your body to the left", "Reach across your body to the right"]
            ),
            // 3. FORWARD STEP (Gait Training)
            WorkoutExercise(
                name: "BIG Forward Step",
                reps: 10,
                videoID: "jyOk-2DmVnU",
                description: "Intentional, large steps forward.",
                benefits: ["Increases stride length", "Prevents shuffling"],
                stepsToPerform: ["Stand with feet together", "Take a giant step forward", "Swing arms high as you step"]
            ),
            // 4. SIDE STEP (Hip Mobility)
            WorkoutExercise(
                name: "BIG Side Step",
                reps: 10,
                videoID: "jyOk-2DmVnU",
                description: "Exaggerated steps to the side.",
                benefits: ["Strengthens hip abductors", "Improves balance"],
                stepsToPerform: ["Stand tall", "Take a wide step to the side", "Bring your other foot to meet it with a 'BIG' motion"]
            ),
            // 5. BACKWARD STEP (Safety Training)
            WorkoutExercise(
                name: "Backward Step",
                reps: 8,
                videoID: "jyOk-2DmVnU",
                description: "Stepping backward with intention.",
                benefits: ["Prevents retropulsion (falling backward)"],
                stepsToPerform: ["Hold a chair if needed", "Step back with a wide, high foot", "Focus on landing flat-footed"]
            ),
            // 6. TRUNK ROTATION (Flexibility)
            WorkoutExercise(
                name: "Twist & Reach",
                reps: 12,
                videoID: "jyOk-2DmVnU",
                description: "Rotating the torso to look behind.",
                benefits: ["Improves core mobility", "Helps with getting out of bed"],
                stepsToPerform: ["Sit or stand tall", "Rotate your chest to the left", "Push your palms open and look back"]
            ),
            // 7. POWER UPS (Functional Strength)
            WorkoutExercise(
                name: "Sit to Stand",
                reps: 10,
                videoID: "jyOk-2DmVnU",
                description: "Rising from a chair using power.",
                benefits: ["Strengthens legs", "Improves functional independence"],
                stepsToPerform: ["Nose over toes", "Push through your heels", "Stand up as tall and fast as possible"]
            )
        ]
    }
    
    func getTodayWorkout() -> [WorkoutExercise] {
        return exercises
    }
    
    func resetDailyProgress() {
        completedToday.removeAll()
        SkippedToday.removeAll()
    }
    
    func resetAllExercises() {
        resetDailyProgress()
    }
}
