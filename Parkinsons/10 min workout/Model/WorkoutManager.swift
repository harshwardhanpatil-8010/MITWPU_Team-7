
//
//import Foundation
//
//class WorkoutManager {
//    static let shared = WorkoutManager()
//    
//    // Algorithm State
//    var allMedsTaken: Bool = false
//    var lastFeedback: String = "Moderate"
//    
//    // UI Data - The Landing Page reads from here
//    var exercises: [WorkoutExercise] = []
//    var completedToday: [UUID] = []
//    var SkippedToday: [UUID] = []
//    
//    private init() {}
//
//    // MARK: - Logic to generate the 5-category workout
//    func generateDailyWorkout() {
//        // Flowchart Logic: If meds not taken -> Seated exercises
//        let preferredPosition: ExercisePosition = allMedsTaken ? .standing : .seated
//        
//        var dailySet: [WorkoutExercise] = []
//        let library = getFullLibrary()
//        
//        // Loop through all 5 categories to ensure a full-body workout
//        for category in ExerciseCategory.allCases {
//            let matches = library.filter { $0.category == category && $0.position == preferredPosition }
//            if let baseExercise = matches.randomElement() {
//                dailySet.append(applyAlgorithm(to: baseExercise))
//            }
//        }
//        self.exercises = dailySet
//    }
//    
//    
//    private func applyAlgorithm(to exercise: WorkoutExercise) -> WorkoutExercise {
//        var modified = exercise
//        let feedback = allMedsTaken ? lastFeedback : "Moderate"
//        
//        if exercise.category == .warmup || exercise.category == .cooldown {
//            switch feedback {
//            case "Easy":     modified.reps = 60
//            case "Moderate": modified.reps = 50
//            case "Hard":     modified.reps = 30
//            default:         modified.reps = 40
//            }
//        } else {
//            switch feedback {
//            case "Easy":     modified.reps = 14
//            case "Moderate": modified.reps = 12
//            case "Hard":     modified.reps = 8
//            default:         modified.reps = 12
//            }
//        }
//        return modified
//    }
//
//    func resetDailyProgress() {
//        completedToday.removeAll()
//        SkippedToday.removeAll()
//    }
//
//    private func getFullLibrary() -> [WorkoutExercise] {
//        // ... (Insert the full library of 20 exercises provided in the previous step)
//        return [
//            // --- WARM UP (2 Seated, 2 Standing) ---
//            WorkoutExercise(name: "Seated Trunk Rotations", reps: 12, videoID: "uOljoOvycuo", description: "Deliberate torso rotations.", category: .warmup, position: .seated, targetJoints: ["Spine"], benefits: "Reduces rigidity.", stepsToPerform: "Rotate torso slowly left to right."),
//            WorkoutExercise(name: "Seated Neck Tilts", reps: 12, videoID: "jyOk-2DmVnU", description: "Gentle neck stretching.", category: .warmup, position: .seated, targetJoints: ["Neck"], benefits: "Relieves neck tension.", stepsToPerform: "Tilt head side to side slowly."),
//            WorkoutExercise(name: "Standing Big Reach", reps: 12, videoID: "uOljoOvycuo", description: "Full body reach.", category: .warmup, position: .standing, targetJoints: ["Shoulder"], benefits: "Improves posture.", stepsToPerform: "Reach for the floor then the sky."),
//            WorkoutExercise(name: "Standing Side Stretch", reps: 12, videoID: "uOljoOvycuo", description: "Lateral rib stretch.", category: .warmup, position: .standing, targetJoints: ["Spine"], benefits: "Increases breathing capacity.", stepsToPerform: "Reach one arm over your head to the side."),
//
//            // --- BALANCE (2 Seated, 2 Standing) ---
//            WorkoutExercise(name: "Seated Side Reach", reps: 12, videoID: "Wz5IXboB7zM", description: "Off-center reaching.", category: .balance, position: .seated, targetJoints: ["Trunk"], benefits: "Improves seated stability.", stepsToPerform: "Reach out to the side as far as safe."),
//            WorkoutExercise(name: "Seated Leg Hover", reps: 12, videoID: "Wz5IXboB7zM", description: "Core-based leg lifting.", category: .balance, position: .seated, targetJoints: ["Hip"], benefits: "Strengthens core balance.", stepsToPerform: "Lift one foot and hold without leaning back."),
//            WorkoutExercise(name: "Weight Shifts", reps: 12, videoID: "Wz5IXboB7zM", description: "Shifting center of gravity.", category: .balance, position: .standing, targetJoints: ["Ankle"], benefits: "Reduces fall risk.", stepsToPerform: "Slowly move weight from left foot to right."),
//            WorkoutExercise(name: "Tandem Stance", reps: 12, videoID: "Wz5IXboB7zM", description: "Heel-to-toe balance.", category: .balance, position: .standing, targetJoints: ["Ankle"], benefits: "Enhances gait stability.", stepsToPerform: "Place one foot directly in front of the other."),
//
//            // --- AEROBIC (2 Seated, 2 Standing) ---
//            WorkoutExercise(name: "Seated Marching", reps: 12, videoID: "March_ID", description: "Fast seated marching.", category: .aerobic, position: .seated, targetJoints: ["Hip"], benefits: "Boosts heart rate.", stepsToPerform: "Lift knees high and fast while seated."),
//            WorkoutExercise(name: "Seated Boxing", reps: 12, videoID: "March_ID", description: "Air punches with intent.", category: .aerobic, position: .seated, targetJoints: ["Shoulder"], benefits: "Improves coordination.", stepsToPerform: "Punch forward with large 'BIG' movements."),
//            WorkoutExercise(name: "High Knee March", reps: 12, videoID: "March_ID", description: "Vigorous standing march.", category: .aerobic, position: .standing, targetJoints: ["Knee"], benefits: "Triggers neuroplasticity (BDNF).", stepsToPerform: "March in place with high knees and arm swings."),
//            WorkoutExercise(name: "Standing Jumping Jacks", reps: 12, videoID: "March_ID", description: "Modified arm/leg jacks.", category: .aerobic, position: .standing, targetJoints: ["Shoulder", "Ankle"], benefits: "Whole body aerobic blast.", stepsToPerform: "Step side to side while swinging arms high."),
//
//            // --- STRENGTH (2 Seated, 2 Standing) ---
//            WorkoutExercise(name: "Seated Leg Extension", reps: 12, videoID: "zIFtb-R24Ec", description: "Knee straightening.", category: .strength, position: .seated, targetJoints: ["Knee"], benefits: "Strengthens quads.", stepsToPerform: "Straighten leg fully and squeeze thigh."),
//            WorkoutExercise(name: "Seated Bicep Curls", reps: 12, videoID: "zIFtb-R24Ec", description: "Arm strengthening.", category: .strength, position: .seated, targetJoints: ["Elbow"], benefits: "Improves arm function.", stepsToPerform: "Curl hands to shoulders with tension."),
//            WorkoutExercise(name: "Sit-to-Stand", reps: 12, videoID: "zIFtb-R24Ec", description: "Chair squats.", category: .strength, position: .standing, targetJoints: ["Knee", "Hip"], benefits: "Functional independence.", stepsToPerform: "Stand up from chair using legs only."),
//            WorkoutExercise(name: "Wall Push-ups", reps: 12, videoID: "zIFtb-R24Ec", description: "Vertical push-ups.", category: .strength, position: .standing, targetJoints: ["Shoulder", "Elbow"], benefits: "Upper body power.", stepsToPerform: "Push against a wall with controlled motion."),
//
//            // --- COOL DOWN (2 Seated, 2 Standing) ---
//            WorkoutExercise(name: "Box Breathing", reps: 12, videoID: "WRyPQO_u_qE", description: "Rhythmic breathing.", category: .cooldown, position: .seated, targetJoints: ["Lungs"], benefits: "Resets nervous system.", stepsToPerform: "Inhale 4s, Hold 4s, Exhale 4s, Hold 4s."),
//            WorkoutExercise(name: "Seated Wrist Stretch", reps: 12, videoID: "WRyPQO_u_qE", description: "Forearm release.", category: .cooldown, position: .seated, targetJoints: ["Wrist"], benefits: "Reduces hand tremors/rigidity.", stepsToPerform: "Gently pull fingers back toward forearm."),
//            WorkoutExercise(name: "Standing Calf Stretch", reps: 12, videoID: "WRyPQO_u_qE", description: "Wall-assisted stretch.", category: .cooldown, position: .standing, targetJoints: ["Ankle"], benefits: "Improves stride length.", stepsToPerform: "Lean against wall with one heel back."),
//            WorkoutExercise(name: "Standing Chest Opener", reps: 12, videoID: "WRyPQO_u_qE", description: "Heart opening stretch.", category: .cooldown, position: .standing, targetJoints: ["Shoulder"], benefits: "Corrects forward-leaning posture.", stepsToPerform: "Clasp hands behind back and look up.")
//        ]
//        
//    }
//    func resetAllExercises() {
//        resetDailyProgress()
//    }
//}



import Foundation

class WorkoutManager {
    static let shared = WorkoutManager()

    var allMedsTaken: Bool = false
    var lastFeedback: String = "Moderate"

    var userWantsToPushLimits: Bool = false
    
    var exercises: [WorkoutExercise] = []
    var completedToday: [UUID] = []
    var SkippedToday: [UUID] = []
    
    private init() {}

    func generateDailyWorkout() {

        let preferredPosition: ExercisePosition = userWantsToPushLimits ? .standing : .seated
        
        var dailySet: [WorkoutExercise] = []
        let library = getFullLibrary()
        
        let warmups = library.filter { $0.category == .warmup && $0.position == preferredPosition }
        dailySet.append(contentsOf: warmups.shuffled().prefix(2).map { applyAlgorithm(to: $0) })
        
        if let balance = library.filter({ $0.category == .balance && $0.position == preferredPosition }).randomElement() {
            dailySet.append(applyAlgorithm(to: balance))
        }
        
        if let aerobic = library.filter({ $0.category == .aerobic && $0.position == preferredPosition }).randomElement() {
            dailySet.append(applyAlgorithm(to: aerobic))
        }
        
        if let strength = library.filter({ $0.category == .strength && $0.position == preferredPosition }).randomElement() {
            dailySet.append(applyAlgorithm(to: strength))
        }
        
        let cooldowns = library.filter { $0.category == .cooldown && $0.position == preferredPosition }
        dailySet.append(contentsOf: cooldowns.shuffled().prefix(2).map { applyAlgorithm(to: $0) })
        
        self.exercises = dailySet
    }

    func getTodayWorkout() -> [WorkoutExercise] {
        if exercises.isEmpty {
            generateDailyWorkout()
        }
        return exercises
    }
    
    private func applyAlgorithm(to exercise: WorkoutExercise) -> WorkoutExercise {
        var modified = exercise
        
        let feedback = allMedsTaken ? lastFeedback : "Moderate"
        
        if exercise.category == .warmup || exercise.category == .cooldown {
            switch feedback {
            case "Easy":     modified.reps = 60
            case "Moderate": modified.reps = 40
            case "Hard":     modified.reps = 30
            default:         modified.reps = 40
            }
        } else {
            switch feedback {
            case "Easy":     modified.reps = 14
            case "Moderate": modified.reps = 12
            case "Hard":     modified.reps = 8
            default:         modified.reps = 12
            }
        }
        return modified
    }

    func resetDailyProgress() {
        completedToday.removeAll()
        SkippedToday.removeAll()
    }

    func resetAllExercises() {
        resetDailyProgress()
        generateDailyWorkout()
    }

    private func getFullLibrary() -> [WorkoutExercise] {
        return [
            // --- WARM UP (2 Seated, 2 Standing) ---
            WorkoutExercise(name: "Seated Trunk Rotations", reps: 12, videoID: "uOljoOvycuo", description: "Deliberate torso rotations.", category: .warmup, position: .seated, targetJoints: ["Spine"], benefits: "Reduces rigidity.", stepsToPerform: "Rotate torso slowly left to right."),
            WorkoutExercise(name: "Seated Neck Tilts", reps: 12, videoID: "jyOk-2DmVnU", description: "Gentle neck stretching.", category: .warmup, position: .seated, targetJoints: ["Neck"], benefits: "Relieves neck tension.", stepsToPerform: "Tilt head side to side slowly."),
            WorkoutExercise(name: "Standing Big Reach", reps: 12, videoID: "uOljoOvycuo", description: "Full body reach.", category: .warmup, position: .standing, targetJoints: ["Shoulder"], benefits: "Improves posture.", stepsToPerform: "Reach for the floor then the sky."),
            WorkoutExercise(name: "Standing Side Stretch", reps: 12, videoID: "uOljoOvycuo", description: "Lateral rib stretch.", category: .warmup, position: .standing, targetJoints: ["Spine"], benefits: "Increases breathing capacity.", stepsToPerform: "Reach one arm over your head to the side."),

            // --- BALANCE (2 Seated, 2 Standing) ---
            WorkoutExercise(name: "Seated Side Reach", reps: 12, videoID: "Wz5IXboB7zM", description: "Off-center reaching.", category: .balance, position: .seated, targetJoints: ["Trunk"], benefits: "Improves seated stability.", stepsToPerform: "Reach out to the side as far as safe."),
            WorkoutExercise(name: "Seated Leg Hover", reps: 12, videoID: "Wz5IXboB7zM", description: "Core-based leg lifting.", category: .balance, position: .seated, targetJoints: ["Hip"], benefits: "Strengthens core balance.", stepsToPerform: "Lift one foot and hold without leaning back."),
            WorkoutExercise(name: "Weight Shifts", reps: 12, videoID: "Wz5IXboB7zM", description: "Shifting center of gravity.", category: .balance, position: .standing, targetJoints: ["Ankle"], benefits: "Reduces fall risk.", stepsToPerform: "Slowly move weight from left foot to right."),
            WorkoutExercise(name: "Tandem Stance", reps: 12, videoID: "Wz5IXboB7zM", description: "Heel-to-toe balance.", category: .balance, position: .standing, targetJoints: ["Ankle"], benefits: "Enhances gait stability.", stepsToPerform: "Place one foot directly in front of the other."),

            // --- AEROBIC (2 Seated, 2 Standing) ---
            WorkoutExercise(name: "Seated Marching", reps: 12, videoID: "March_ID", description: "Fast seated marching.", category: .aerobic, position: .seated, targetJoints: ["Hip"], benefits: "Boosts heart rate.", stepsToPerform: "Lift knees high and fast while seated."),
            WorkoutExercise(name: "Seated Boxing", reps: 12, videoID: "March_ID", description: "Air punches with intent.", category: .aerobic, position: .seated, targetJoints: ["Shoulder"], benefits: "Improves coordination.", stepsToPerform: "Punch forward with large 'BIG' movements."),
            WorkoutExercise(name: "High Knee March", reps: 12, videoID: "March_ID", description: "Vigorous standing march.", category: .aerobic, position: .standing, targetJoints: ["Knee"], benefits: "Triggers neuroplasticity (BDNF).", stepsToPerform: "March in place with high knees and arm swings."),
            WorkoutExercise(name: "Standing Jumping Jacks", reps: 12, videoID: "March_ID", description: "Modified arm/leg jacks.", category: .aerobic, position: .standing, targetJoints: ["Shoulder", "Ankle"], benefits: "Whole body aerobic blast.", stepsToPerform: "Step side to side while swinging arms high."),

            // --- STRENGTH (2 Seated, 2 Standing) ---
            WorkoutExercise(name: "Seated Leg Extension", reps: 12, videoID: "zIFtb-R24Ec", description: "Knee straightening.", category: .strength, position: .seated, targetJoints: ["Knee"], benefits: "Strengthens quads.", stepsToPerform: "Straighten leg fully and squeeze thigh."),
            WorkoutExercise(name: "Seated Bicep Curls", reps: 12, videoID: "zIFtb-R24Ec", description: "Arm strengthening.", category: .strength, position: .seated, targetJoints: ["Elbow"], benefits: "Improves arm function.", stepsToPerform: "Curl hands to shoulders with tension."),
            WorkoutExercise(name: "Sit-to-Stand", reps: 12, videoID: "zIFtb-R24Ec", description: "Chair squats.", category: .strength, position: .standing, targetJoints: ["Knee", "Hip"], benefits: "Functional independence.", stepsToPerform: "Stand up from chair using legs only."),
            WorkoutExercise(name: "Wall Push-ups", reps: 12, videoID: "zIFtb-R24Ec", description: "Vertical push-ups.", category: .strength, position: .standing, targetJoints: ["Shoulder", "Elbow"], benefits: "Upper body power.", stepsToPerform: "Push against a wall with controlled motion."),

            // --- COOL DOWN (2 Seated, 2 Standing) ---
            WorkoutExercise(name: "Box Breathing", reps: 12, videoID: "WRyPQO_u_qE", description: "Rhythmic breathing.", category: .cooldown, position: .seated, targetJoints: ["Lungs"], benefits: "Resets nervous system.", stepsToPerform: "Inhale 4s, Hold 4s, Exhale 4s, Hold 4s."),
            WorkoutExercise(name: "Seated Wrist Stretch", reps: 12, videoID: "WRyPQO_u_qE", description: "Forearm release.", category: .cooldown, position: .seated, targetJoints: ["Wrist"], benefits: "Reduces hand tremors/rigidity.", stepsToPerform: "Gently pull fingers back toward forearm."),
            WorkoutExercise(name: "Standing Calf Stretch", reps: 12, videoID: "WRyPQO_u_qE", description: "Wall-assisted stretch.", category: .cooldown, position: .standing, targetJoints: ["Ankle"], benefits: "Improves stride length.", stepsToPerform: "Lean against wall with one heel back."),
            WorkoutExercise(name: "Standing Chest Opener", reps: 12, videoID: "WRyPQO_u_qE", description: "Heart opening stretch.", category: .cooldown, position: .standing, targetJoints: ["Shoulder"], benefits: "Corrects forward-leaning posture.", stepsToPerform: "Clasp hands behind back and look up.")
        ]
    }
}


