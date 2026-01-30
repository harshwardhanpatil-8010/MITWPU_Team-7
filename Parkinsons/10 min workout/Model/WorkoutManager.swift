import Foundation

class WorkoutManager {
    static let shared = WorkoutManager()
    var hasCheckedSafetyThisSession = false
    
    var lastFeedback: String = "Moderate"
    
    var userWantsToPushLimits: Bool = false
    
    var exercises: [WorkoutExercise] = []
    var completedToday: [UUID] = []
    var skippedToday: [UUID] = []
    
    private let lastWorkoutCompletionDateKey = "lastWorkoutCompletionDate"

    private var lastWorkoutCompletionDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: lastWorkoutCompletionDateKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastWorkoutCompletionDateKey)
        }
    }

    func hasCompletedWorkoutToday() -> Bool {
        guard let lastCompletion = lastWorkoutCompletionDate else {
            return false
        }
        return Calendar.current.isDateInToday(lastCompletion)
    }

    func setWorkoutCompleted() {
        lastWorkoutCompletionDate = Date()
    }

    enum MedicationEffect {
        case optimal
        case wearingOff
        case offPeriod
    }
    
    var allMedsTaken: Bool {
        let threeHoursAgo = Calendar.current.date(byAdding: .hour, value: -3, to: Date())!
        let allLogs = DoseLogDataStore.shared.logs
        
        let recentLogs = allLogs.filter { log in
            return log.scheduledTime >= threeHoursAgo && log.scheduledTime <= Date()
        }
        
        if recentLogs.isEmpty {
            return true
        }
        
        return recentLogs.allSatisfy { $0.status == .taken }
    }
    
    func getMedicationEffect() -> MedicationEffect {
        let logs = DoseLogDataStore.shared.logs(for: Date())
        let takenDoses = logs
            .filter { $0.status == .taken }
            .sorted(by: { $0.loggedAt < $1.loggedAt })

        guard let lastDose = takenDoses.last else {
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
    func preferredExercisePosition() -> ExercisePosition {
        switch getMedicationEffect() {
        case .optimal:
            return .standing

        case .wearingOff:
            return userWantsToPushLimits ? .standing : .seated

        case .offPeriod:
            return .seated
        }
    }

    
    
    func generateDailyWorkout() {
        let effect = getMedicationEffect()
        
        var preferredPosition: ExercisePosition = preferredExercisePosition()

    
        var dailySet: [WorkoutExercise] = []
        let library = getFullLibrary()
        
        for category in ExerciseCategory.allCases {
            let filteredLibrary = library.filter { $0.category == category }
            
            switch category {
            case .warmup:
                let warmups = filteredLibrary.filter { $0.position == preferredPosition }
                dailySet.append(contentsOf: (warmups.isEmpty ? filteredLibrary : warmups).shuffled().prefix(2).map { applyAlgorithm(to: $0 ) })
            case .balance:
                if let balance = filteredLibrary.filter({ $0.position == preferredPosition}).randomElement() {
                    dailySet.append(applyAlgorithm(to: balance))
                } else if let altBalance = filteredLibrary.randomElement() {
                    dailySet.append(applyAlgorithm(to: altBalance))
                }
            case .aerobic:
                if let aerobic = filteredLibrary.filter({ $0.position == preferredPosition}).randomElement() {
                    dailySet.append(applyAlgorithm(to: aerobic))
                } else if let altAerobic = filteredLibrary.randomElement() {
                    dailySet.append(applyAlgorithm(to: altAerobic))
                }
            case .strength:
                if let strength = filteredLibrary.filter({ $0.position == preferredPosition}).randomElement() {
                    dailySet.append(applyAlgorithm(to: strength))
                } else if let altStrength = filteredLibrary.randomElement() {
                    dailySet.append(applyAlgorithm(to: altStrength))
                }
            case .cooldown:
                let cooldowns = filteredLibrary.filter { $0.position == preferredPosition }
                dailySet.append(contentsOf: (cooldowns.isEmpty ? filteredLibrary: cooldowns).shuffled().prefix(2).map{applyAlgorithm(to: $0) })
            }
            
            self.exercises = dailySet
        }
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
