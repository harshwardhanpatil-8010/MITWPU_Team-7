import Foundation
import CoreData
class WorkoutManager {
    static let shared = WorkoutManager()
    var hasCheckedSafetyThisSession = false
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
    func saveFeedback(_ value: Int) {
           UserDefaults.standard.set(value, forKey: "lastWorkoutFeedback")
           UserDefaults.standard.set(Date(), forKey: "lastWorkoutFeedbackDate")
       }
    func loadLastFeedback() -> Int {
           let value = UserDefaults.standard.integer(forKey: "lastWorkoutFeedback")
           return value == 0 ? 2 : value
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
        let context = PersistenceController.shared.viewContext
        let threeHoursAgo = Calendar.current.date(byAdding: .hour, value: -3, to: Date())!

        let request: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "doseScheduledTime >= %@ AND doseScheduledTime <= %@",
            threeHoursAgo as NSDate,
            Date() as NSDate
        )

        do {
            let logs = try context.fetch(request)

            if logs.isEmpty { return true }

            return logs.allSatisfy { $0.doseLogStatus == "taken" }
        } catch {
            return true
        }
    }



    
    
    func getMedicationEffect() -> MedicationEffect {

        let context = PersistenceController.shared.viewContext

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let request: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "doseScheduledTime >= %@ AND doseScheduledTime < %@ AND doseLogStatus == %@",
            startOfDay as NSDate,
            endOfDay as NSDate,
            "taken"
        )

        let logs = (try? context.fetch(request)) ?? []

        let takenDoses = logs.sorted {
            ($0.doseLoggedAt ?? Date()) < ($1.doseLoggedAt ?? Date())
        }

        guard let lastDose = takenDoses.last,
              let loggedAt = lastDose.doseLoggedAt else {
            return .offPeriod
        }

        let hoursSinceDose = Date().timeIntervalSince(loggedAt) / 3600

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

        let storedFeedback = UserDefaults.standard.integer(forKey: "lastWorkoutFeedback")
        let feedback = storedFeedback == 0 ? 2 : storedFeedback

        let effectiveFeedback: Int
        if allMedsTaken {
            effectiveFeedback = feedback
        } else {
            effectiveFeedback = 2
        }

        if exercise.category == .warmup || exercise.category == .cooldown {
            switch effectiveFeedback {
            case 1:  //Easy
                modified.reps = 60
            case 3:  //Hard
                modified.reps = 30
            default:  //Medium
                modified.reps = 40
            }
        } else {
            switch effectiveFeedback {
            case 1:
                modified.reps = 14
            case 3:
                modified.reps = 8
            default:
                modified.reps = 12
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
