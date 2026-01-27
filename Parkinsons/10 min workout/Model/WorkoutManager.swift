
import Foundation

class WorkoutManager {
    static let shared = WorkoutManager()
    var hasCheckedSafetyThisSession = false
    
    var allMedsTaken: Bool = false
    var lastFeedback: String = "Moderate"

    var userWantsToPushLimits: Bool = false
    
    var exercises: [WorkoutExercise] = []
    var completedToday: [UUID] = []
    var skippedToday: [UUID] = []
    
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
        skippedToday.removeAll()
    }

    func resetAllExercises() {
        resetDailyProgress()
        generateDailyWorkout()
    }

    private func getFullLibrary() -> [WorkoutExercise] {
        guard let url = Bundle.main.url(forResource: "workout_exercises", withExtension: "json") else {
          
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let exercises = try JSONDecoder().decode([WorkoutExercise].self, from: data)
            return exercises
        } catch {
        
            return []
        }
    }

}


