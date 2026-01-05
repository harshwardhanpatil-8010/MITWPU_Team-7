//
//  //WorkoutManager.swift
//  //Parkinsons
//
//  //Created by Unnatti Gogna on 25/12/25.
//
//
//import Foundation
//
//struct WorkoutExercise: Identifiable {
//    let id = UUID()
//    let name: String
//    let reps: Int
//    let videoID: String?
//    let description: String
//    let benefits: [String]
//    let stepsToPerform: [String]
//}
//
//class WorkoutManager {
//    static let shared = WorkoutManager()
//    
//    var exercises: [WorkoutExercise] = []
//    var completedToday: [UUID] = []
//    var SkippedToday: [UUID] = []
//    
//    private init() {
//        loadBaseExercises()
//    }
//    
//    private func loadBaseExercises() {
//        self.exercises = [
//            // 1. FLOOR TO CEILING (Stretch & Amplitude)
//            WorkoutExercise(
//                name: "Floor to Ceiling",
//                reps: 8,
//                videoID: "jyOk-2DmVnU",
//                description: "A full-body reach from the floor to the sky.",
//                benefits: ["Improves posture", "Reduces trunk rigidity"],
//                stepsToPerform: ["Sit on the edge of a chair", "Reach down and touch the floor", "Explode upward and reach for the ceiling"]
//            ),
//            // 2. SIDE TO SIDE (Lateral Balance)
//            WorkoutExercise(
//                name: "Side to Side Reach",
//                reps: 10,
//                videoID: "jyOk-2DmVnU",
//                description: "Large reaches across the body.",
//                benefits: ["Improves lateral stability", "Reduces risk of falls"],
//                stepsToPerform: ["Spread arms wide", "Reach across your body to the left", "Reach across your body to the right"]
//            ),
//            // 3. FORWARD STEP (Gait Training)
//            WorkoutExercise(
//                name: "BIG Forward Step",
//                reps: 10,
//                videoID: "jyOk-2DmVnU",
//                description: "Intentional, large steps forward.",
//                benefits: ["Increases stride length", "Prevents shuffling"],
//                stepsToPerform: ["Stand with feet together", "Take a giant step forward", "Swing arms high as you step"]
//            ),
//            // 4. SIDE STEP (Hip Mobility)
//            WorkoutExercise(
//                name: "BIG Side Step",
//                reps: 10,
//                videoID: "jyOk-2DmVnU",
//                description: "Exaggerated steps to the side.",
//                benefits: ["Strengthens hip abductors", "Improves balance"],
//                stepsToPerform: ["Stand tall", "Take a wide step to the side", "Bring your other foot to meet it with a 'BIG' motion"]
//            ),
//            // 5. BACKWARD STEP (Safety Training)
//            WorkoutExercise(
//                name: "Backward Step",
//                reps: 8,
//                videoID: "jyOk-2DmVnU",
//                description: "Stepping backward with intention.",
//                benefits: ["Prevents retropulsion (falling backward)"],
//                stepsToPerform: ["Hold a chair if needed", "Step back with a wide, high foot", "Focus on landing flat-footed"]
//            ),
//            // 6. TRUNK ROTATION (Flexibility)
//            WorkoutExercise(
//                name: "Twist & Reach",
//                reps: 12,
//                videoID: "jyOk-2DmVnU",
//                description: "Rotating the torso to look behind.",
//                benefits: ["Improves core mobility", "Helps with getting out of bed"],
//                stepsToPerform: ["Sit or stand tall", "Rotate your chest to the left", "Push your palms open and look back"]
//            ),
//            // 7. POWER UPS (Functional Strength)
//            WorkoutExercise(
//                name: "Sit to Stand",
//                reps: 10,
//                videoID: "jyOk-2DmVnU",
//                description: "Rising from a chair using power.",
//                benefits: ["Strengthens legs", "Improves functional independence"],
//                stepsToPerform: ["Nose over toes", "Push through your heels", "Stand up as tall and fast as possible"]
//            )
//        ]
//    }
//
//
//
//    func getTodayWorkout() -> [WorkoutExercise] {
//        return exercises
//    }
//    
//    func resetDailyProgress() {
//        completedToday.removeAll()
//        SkippedToday.removeAll()
//    }
//    
//    func resetAllExercises() {
//        resetDailyProgress()
//    }
//}
//import Foundation
//
//
//
//class WorkoutManager {
//    static let shared = WorkoutManager()
//    
//    var allMedsTaken: Bool = false
//    var lastFeedback: String?
//    
//    var completedToday: [UUID] = []
//    var SkippedToday: [UUID] = []
//    
//    private var allExercises: [WorkoutExercise] = []
//    
//    private init() {
//        loadExerciseLibrary()
//    }
//    
//    // MARK: - Algorithm Logic
//    
//    func getTodayWorkout() -> [WorkoutExercise] {
//        // FLOWCHART: Off Day -> Seated exercises; On Day -> Standing exercises
//        let preferredPosition: ExercisePosition = allMedsTaken ? .standing : .seated
//        
//        var dailySet: [WorkoutExercise] = []
//        
//        for category in ExerciseCategory.allCases {
//            let matches = allExercises.filter {
//                $0.category == category && $0.position == preferredPosition
//            }
//            
//            if let baseExercise = matches.randomElement() {
//                dailySet.append(applyAlgorithmAdjustments(to: baseExercise))
//            }
//        }
//        return dailySet
//    }
//    
//    private func applyAlgorithmAdjustments(to exercise: WorkoutExercise) -> WorkoutExercise {
//        var modified = exercise
//        
//        // If it's an OFF DAY, we force "Moderate" logic and seated position
//        let feedback = allMedsTaken ? (lastFeedback ?? "Moderate") : "Moderate"
//        
//        if modified.category == .warmup || modified.category == .cooldown {
//            switch feedback {
//            case "Easy":     modified.reps = 60
//            case "Moderate": modified.reps = 50
//            case "Hard":     modified.reps = 30 
//            default:         modified.reps = 40
//            }
//        } else {
//            let currentReps = modified.reps
//            switch feedback {
//            case "Easy":
//                modified.reps = min(15, currentReps + 2)
//            case "Moderate":
//                modified.reps = min(15, currentReps + 1)
//            case "Hard":
//                modified.reps = max(8, currentReps - 1)
//            default: break
//            }
//        }
//        return modified
//    }
//    
//    private func loadExerciseLibrary() {
//        self.allExercises = [
//            WorkoutExercise(name: "Seated Neck Tilts", reps: 12, videoID: "...", description: "Gentle neck stretch.", category: .warmup, position: .seated, targetJoints: ["Neck"]),
//            WorkoutExercise(name: "Seated Shoulder Rolls", reps: 12, videoID: "...", description: "Circular shoulder motion.", category: .warmup, position: .seated, targetJoints: ["Shoulder"]),
//            WorkoutExercise(name: "Seated Leg Extensions", reps: 12, videoID: "...", description: "Straighten knee.", category: .strength, position: .seated, targetJoints: ["Knee"]),
//            WorkoutExercise(name: "Seated Marching", reps: 12, videoID: "...", description: "Lift knees high.", category: .aerobic, position: .seated, targetJoints: ["Hip"]),
//            WorkoutExercise(name: "Seated Side Reaches", reps: 12, videoID: "...", description: "Reach for the floor.", category: .balance, position: .seated, targetJoints: ["Trunk"]),
//            WorkoutExercise(name: "Seated Deep Breathing", reps: 12, videoID: "...", description: "Slow controlled breaths.", category: .cooldown, position: .seated, targetJoints: ["Lungs"]),
//            WorkoutExercise(name: "Seated Hand Squeezes", reps: 12, videoID: "...", description: "Clench and release.", category: .cooldown, position: .seated, targetJoints: ["Wrist"]),
//
//            
//            WorkoutExercise(name: "Standing Big Reach", reps: 12, videoID: "...", description: "Floor to ceiling.", category: .warmup, position: .standing, targetJoints: ["Shoulder"]),
//            WorkoutExercise(name: "Standing Torso Twist", reps: 12, videoID: "...", description: "Rotate gently.", category: .warmup, position: .standing, targetJoints: ["Spine"]),
//            WorkoutExercise(name: "Wall Push-ups", reps: 12, videoID: "...", description: "Strength push.", category: .strength, position: .standing, targetJoints: ["Elbow"]),
//            WorkoutExercise(name: "High Knee March", reps: 12, videoID: "...", description: "Fast pace.", category: .aerobic, position: .standing, targetJoints: ["Knee"]),
//            WorkoutExercise(name: "Standing Side Step", reps: 12, videoID: "...", description: "Wide steps.", category: .balance, position: .standing, targetJoints: ["Ankle"]),
//            WorkoutExercise(name: "Standing Calf Stretch", reps: 12, videoID: "...", description: "Lean against wall.", category: .cooldown, position: .standing, targetJoints: ["Ankle"]),
//            WorkoutExercise(name: "Arm Circles", reps: 12, videoID: "...", description: "Slow rotations.", category: .cooldown, position: .standing, targetJoints: ["Shoulder"])
//        ]
//    }








//import Foundation
//
//class WorkoutManager {
//    static let shared = WorkoutManager()
//    
//    // Logic state
//    var allMedsTaken: Bool = false
//    var lastFeedback: String = "Moderate"
//    
//    // UI expects these
//    var exercises: [WorkoutExercise] = []
//    var completedToday: [UUID] = []
//    var SkippedToday: [UUID] = []
//    
//    private init() {}
//
//    func generateDailyWorkout() {
//        // Flowchart Logic: If meds not taken -> Seated exercises
//        let preferredPosition: ExercisePosition = allMedsTaken ? .standing : .seated
//        
//        var dailySet: [WorkoutExercise] = []
//        let library = getFullLibrary()
//        
//        for category in ExerciseCategory.allCases {
//            let matches = library.filter { $0.category == category && $0.position == preferredPosition }
//            if let baseExercise = matches.randomElement() {
//                dailySet.append(applyAlgorithm(to: baseExercise))
//            }
//        }
//        self.exercises = dailySet
//    }
//    
//    private func applyAlgorithm(to exercise: WorkoutExercise) -> WorkoutExercise {
//        var modified = exercise
//        let feedback = allMedsTaken ? lastFeedback : "Moderate"
//        
//        if exercise.category == .warmup || exercise.category == .cooldown {
//            // Algorithm: Easy (60s), Moderate (50s), Hard (30s)
//            switch feedback {
//            case "Easy":     modified.reps = 60
//            case "Moderate": modified.reps = 50
//            case "Hard":     modified.reps = 30
//            default:         modified.reps = 40
//            }
//        } else {
//            // Algorithm: Range 8-15 reps based on feedback
//            switch feedback {
//            case "Easy":     modified.reps = min(15, 12 + 2)
//            case "Moderate": modified.reps = min(15, 12 + 1)
//            case "Hard":     modified.reps = max(8, 12 - 1)
//            default:         modified.reps = 12
//            }
//        }
//        return modified
//    }
//
//    private func getFullLibrary() -> [WorkoutExercise] {
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
//    }
//    func resetDailyProgress() {
//        completedToday.removeAll()
//        SkippedToday.removeAll()
//    }
//    func resetAllExercises() {
//        resetDailyProgress()
//    }
//    
//}
  




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
            case "Moderate": modified.reps = 50
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


