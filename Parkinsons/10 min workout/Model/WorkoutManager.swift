
import Foundation

enum MedicationEffect {
    case optimal    // Taken within 3 hours
    case wearingOff // Taken 3-6 hours ago
    case offPeriod  // Taken > 6 hours ago or not taken
}

class WorkoutManager {
    static let shared = WorkoutManager()
    var hasCheckedSafetyThisSession = false
    
    var allMedsTaken: Bool {
        let logs = DoseLogDataStore.shared.logs(for: Date())
        // If there are logs, and all scheduled so far are taken
        let taken = logs.filter { $0.status == .taken }.count
        return taken > 0 
    }
    
    var lastFeedback: String {
        get { UserDefaults.standard.string(forKey: "workout_last_feedback") ?? "Moderate" }
        set { UserDefaults.standard.set(newValue, forKey: "workout_last_feedback") }
    }
    
    var userWantsToPushLimits: Bool {
        get { UserDefaults.standard.bool(forKey: "workout_push_limits") }
        set { UserDefaults.standard.set(newValue, forKey: "workout_push_limits") }
    }
    
    var workoutStreak: Int {
        get { UserDefaults.standard.integer(forKey: "workout_streak") }
        set { UserDefaults.standard.set(newValue, forKey: "workout_streak") }
    }
    
    var lastWorkoutDate: Date? {
        get { UserDefaults.standard.object(forKey: "last_workout_date") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "last_workout_date") }
    }
    
    var exercises: [WorkoutExercise] = []
    var completedToday: [UUID] = []
    var skippedToday: [UUID] = []
    
    private init() {}

    func getMedicationEffect() -> MedicationEffect {
        let logs = DoseLogDataStore.shared.logs(for: Date())
        let takenDoses = logs.filter { $0.status == .taken }.sorted(by: { $0.loggedAt > $1.loggedAt })
        
        guard let lastDose = takenDoses.first else {
            return .offPeriod
        }
        
        let hoursSinceDose = Date().timeIntervalSince(lastDose.loggedAt) / 3600
        
        if hoursSinceDose < 3 {
            return .optimal
        } else if hoursSinceDose < 6 {
            return .wearingOff
        } else {
            return .offPeriod
        }
    }


    func generateDailyWorkout() {
        let effect = getMedicationEffect()
        
        // Dynamic positioning: If medication is optimal, prefer standing. 
        // If off-period, strictly seated.
        var preferredPosition: ExercisePosition = .seated
        
        switch effect {
        case .optimal:
            preferredPosition = .standing
        case .wearingOff:
            preferredPosition = userWantsToPushLimits ? .standing : .seated
        case .offPeriod:
            preferredPosition = .seated
        }
        
        // Dynamic rest duration
        switch effect {
        case .optimal:    restDuration = 45
        case .wearingOff: restDuration = 60
        case .offPeriod:  restDuration = 90
        }
        
        var dailySet: [WorkoutExercise] = []
        let library = getFullLibrary()
        
        // 1. Warmups (2)
        let warmups = library.filter { $0.category == .warmup && $0.position == preferredPosition }
        dailySet.append(contentsOf: (warmups.isEmpty ? library.filter { $0.category == .warmup } : warmups).shuffled().prefix(2).map { applyAlgorithm(to: $0) })
        
        // 2. Balance (1)
        if let balance = library.filter({ $0.category == .balance && $0.position == preferredPosition }).randomElement() {
            dailySet.append(applyAlgorithm(to: balance))
        } else if let altBalance = library.filter({ $0.category == .balance }).randomElement() {
            dailySet.append(applyAlgorithm(to: altBalance))
        }
        
        // 3. Aerobic (1)
        if let aerobic = library.filter({ $0.category == .aerobic && $0.position == preferredPosition }).randomElement() {
            dailySet.append(applyAlgorithm(to: aerobic) )
        } else if let altAerobic = library.filter({ $0.category == .aerobic }).randomElement() {
            dailySet.append(applyAlgorithm(to: altAerobic))
        }
        
        // 4. Strength (1)
        if let strength = library.filter({ $0.category == .strength && $0.position == preferredPosition }).randomElement() {
            dailySet.append(applyAlgorithm(to: strength))
        } else if let altStrength = library.filter({ $0.category == .strength }).randomElement() {
            dailySet.append(applyAlgorithm(to: altStrength))
        }
        
        // 5. Cooldowns (2)
        let cooldowns = library.filter { $0.category == .cooldown && $0.position == preferredPosition }
        dailySet.append(contentsOf: (cooldowns.isEmpty ? library.filter { $0.category == .cooldown } : cooldowns).shuffled().prefix(2).map { applyAlgorithm(to: $0) })
        
        self.exercises = dailySet
    }

    func getTodayWorkout() -> [WorkoutExercise] {
        if exercises.isEmpty {
            generateDailyWorkout()
        }
        return exercises
    }
    
    func getAdherenceMultiplier() -> Double {
        let allLogs = DoseLogDataStore.shared.logs
        let calendar = Calendar.current
        let today = Date().startOfDay
        
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, of: today) ?? today
        let recentLogs = allLogs.filter { $0.day >= threeDaysAgo && $0.day < today }
        
        if recentLogs.isEmpty { return 1.0 }
        
        let taken = recentLogs.filter { $0.status == .taken }.count
        let total = recentLogs.count
        
        let ratio = total > 0 ? Double(taken) / Double(total) : 1.0
        
        if ratio < 0.5 {
            return 0.8
        } else if ratio < 0.8 {
            return 0.9
        } else {
            return 1.0
        }
    }

    func getStreakMultiplier() -> Double {
        // Increase difficulty by 2% for every day of the streak, up to 20%
        let bonus = Double(workoutStreak) * 0.02
        return 1.0 + min(0.2, bonus)
    }
    
    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastWorkoutDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            
            if Calendar.current.isDate(lastDay, inSameDayAs: today) {
                // Already updated today
                return
            }
            
            let components = Calendar.current.dateComponents([.day], from: lastDay, to: today)
            if let dayDiff = components.day, dayDiff == 1 {
                // Consecutive day
                workoutStreak += 1
            } else {
                // Missed day(s)
                workoutStreak = 1
            }
        } else {
            // First time
            workoutStreak = 1
        }
        
        lastWorkoutDate = today
    }

    private func applyAlgorithm(to exercise: WorkoutExercise) -> WorkoutExercise {
        var modified = exercise
        let effect = getMedicationEffect()
        let adherenceMultiplier = getAdherenceMultiplier()
        let streakMultiplier = getStreakMultiplier()
        
        // Base Reps Factor
        var multiplier: Double = 1.0 * adherenceMultiplier * streakMultiplier
        
        // Feedback adjustment
        switch lastFeedback {
        case "Easy":     multiplier += 0.2
        case "Hard":     multiplier -= 0.2
        default:         break
        }
        
        // Medication effect adjustment
        switch effect {
        case .optimal:    multiplier += 0.1
        case .wearingOff: multiplier -= 0.1
        case .offPeriod:  multiplier -= 0.3
        }
        
        // Ensure multiplier doesn't go too low or too high for safety
        multiplier = max(0.5, min(1.5, multiplier))
        
        let baseReps = Double(exercise.reps)
        let adjustedReps = Int(baseReps * multiplier)
        
        modified.reps = adjustedReps
        
        // For warmup/cooldown which are usually timed (seconds)
        if exercise.category == .warmup || exercise.category == .cooldown {
            // Keep it between 20s and 60s
            modified.reps = max(20, min(60, adjustedReps))
        } else {
            // Keep it between 5 and 20 reps
            modified.reps = max(5, min(20, adjustedReps))
        }
        
        return modified
    }

    func resetDailyProgress() {
        completedToday.removeAll()
        skippedToday.removeAll()
    }

    func resetAllExercises() {
        resetDailyProgress()
        generateDailyWorkout()
    }

    private func getFullLibrary() -> [WorkoutExercise] {
        return [
            // --- WARM UP (2 Seated, 2 Standing) ---
            WorkoutExercise(name: "Seated Trunk Rotations", reps: 40, videoID: "uOljoOvycuo", description: "Deliberate torso rotations.", category: .warmup, position: .seated, targetJoints: ["Spine"], benefits: "Reduces rigidity.", stepsToPerform: "Rotate torso slowly left to right."),
            WorkoutExercise(name: "Seated Neck Tilts", reps: 40, videoID: "jyOk-2DmVnU", description: "Gentle neck stretching.", category: .warmup, position: .seated, targetJoints: ["Neck"], benefits: "Relieves neck tension.", stepsToPerform: "Tilt head side to side slowly."),
            WorkoutExercise(name: "Standing Big Reach", reps: 40, videoID: "uOljoOvycuo", description: "Full body reach.", category: .warmup, position: .standing, targetJoints: ["Shoulder"], benefits: "Improves posture.", stepsToPerform: "Reach for the floor then the sky."),
            WorkoutExercise(name: "Standing Side Stretch", reps: 40, videoID: "uOljoOvycuo", description: "Lateral rib stretch.", category: .warmup, position: .standing, targetJoints: ["Spine"], benefits: "Increases breathing capacity.", stepsToPerform: "Reach one arm over your head to the side."),

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
            WorkoutExercise(name: "Box Breathing", reps: 40, videoID: "WRyPQO_u_qE", description: "Rhythmic breathing.", category: .cooldown, position: .seated, targetJoints: ["Lungs"], benefits: "Resets nervous system.", stepsToPerform: "Inhale 4s, Hold 4s, Exhale 4s, Hold 4s."),
            WorkoutExercise(name: "Seated Wrist Stretch", reps: 40, videoID: "WRyPQO_u_qE", description: "Forearm release.", category: .cooldown, position: .seated, targetJoints: ["Wrist"], benefits: "Reduces hand tremors/rigidity.", stepsToPerform: "Gently pull fingers back toward forearm."),
            WorkoutExercise(name: "Standing Calf Stretch", reps: 40, videoID: "WRyPQO_u_qE", description: "Wall-assisted stretch.", category: .cooldown, position: .standing, targetJoints: ["Ankle"], benefits: "Improves stride length.", stepsToPerform: "Lean against wall with one heel back."),
            WorkoutExercise(name: "Standing Chest Opener", reps: 40, videoID: "WRyPQO_u_qE", description: "Heart opening stretch.", category: .cooldown, position: .standing, targetJoints: ["Shoulder"], benefits: "Corrects forward-leaning posture.", stepsToPerform: "Clasp hands behind back and look up.")
        ]
    }
}


