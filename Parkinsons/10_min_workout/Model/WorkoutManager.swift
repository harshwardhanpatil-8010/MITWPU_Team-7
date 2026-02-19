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
    private let lastWorkoutPositionKey = "lastWorkoutPosition"

    func saveTodayPosition(_ position: ExercisePosition) {
        UserDefaults.standard.set(position.rawValue, forKey: lastWorkoutPositionKey)
    }

    func loadLastWorkoutPosition() -> ExercisePosition? {
        guard let raw = UserDefaults.standard.string(forKey: lastWorkoutPositionKey) else {
            return nil
        }
        return ExercisePosition(rawValue: raw)
    }

    
    //Check for the Disease Stage
    var diseaseStage: Int {
        return UserDefaults.standard.integer(forKey: "diseaseStage")
    }


    func setWorkoutCompleted() {
        lastWorkoutCompletionDate = Date()
        saveTodayPosition(preferredExercisePosition())
    }
    enum Feedback {
        case easy
        case perfect
        case hard
    }


    enum MedicationEffect {
        case optimal
        case wearingOff
        case offPeriod
    }
    private func currentFeedback() -> Feedback {
        let stored = loadLastFeedback()
        
        switch stored {
        case 1: return .easy
        case 3: return .hard
        default: return .perfect
        }
    }
    
    
    private func calculateAdjustment(
        previous: ExercisePosition?,
        today: ExercisePosition,
        feedback: Feedback
    ) -> (reps: Int, seconds: Int) {
        
        guard let previous = previous else {
            return (0, 0) // first day
        }
        
        if previous == today {
            switch feedback {
            case .easy: return (2, 20)
            case .perfect: return (1, 10)
            case .hard: return (-2, -20)
            }
        }
        
        if previous == .seated && today == .standing {
            switch feedback {
            case .easy: return (1, 10)
            case .perfect: return (0, 0)
            case .hard: return (-2, -15)
            }
        }
        
        if previous == .standing && today == .seated {
            switch feedback {
            case .easy: return (1, 10)
            case .perfect: return (0, 0)
            case .hard: return (-1, -10)
            }
        }
        
        return (0, 0)
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
       // let effect = getMedicationEffect()
        let preferredPosition = preferredExercisePosition()
        var dailySet: [WorkoutExercise] = []
        let library = getFullLibrary()
        for category in ExerciseCategory.allCases {
            let filteredLibrary = library.filter { $0.category == category }
            
            switch category {
            case .warmup:
                let warmups = filteredLibrary.filter { $0.position == preferredPosition }
                dailySet.append(contentsOf: (warmups.isEmpty ? filteredLibrary : warmups).shuffled().prefix(2).map { applyAlgorithm(to: $0, todayPosition: preferredPosition) }
)
            case .balance:
                if let balance = filteredLibrary.filter({ $0.position == preferredPosition}).randomElement() {
                    dailySet.append(applyAlgorithm(to: balance, todayPosition: preferredPosition))

                } else if let altBalance = filteredLibrary.randomElement() {
                    dailySet.append(applyAlgorithm(to: altBalance, todayPosition: preferredPosition))
                }
            case .aerobic:
                if let aerobic = filteredLibrary.filter({ $0.position == preferredPosition}).randomElement() {
                    dailySet.append(applyAlgorithm(to: aerobic, todayPosition: preferredPosition))
                } else if let altAerobic = filteredLibrary.randomElement() {
                    dailySet.append(applyAlgorithm(to: altAerobic, todayPosition: preferredPosition))
                }
            case .strength:
                if let strength = filteredLibrary.filter({ $0.position == preferredPosition}).randomElement() {
                    dailySet.append(applyAlgorithm(to: strength, todayPosition: preferredPosition))
                } else if let altStrength = filteredLibrary.randomElement() {
                    dailySet.append(applyAlgorithm(to: altStrength, todayPosition: preferredPosition))
                }
            case .cooldown:
                let cooldowns = filteredLibrary.filter { $0.position == preferredPosition }
                dailySet.append(contentsOf: (cooldowns.isEmpty ? filteredLibrary: cooldowns).shuffled().prefix(2).map{applyAlgorithm(to: $0, todayPosition: preferredPosition)})
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
        
    private func applyAlgorithm(to exercise: WorkoutExercise,
                                todayPosition: ExercisePosition) -> WorkoutExercise {
        
        var modified = exercise
        
        let previousPosition = loadLastWorkoutPosition()
        let feedback = currentFeedback()
        
        let adjustment = calculateAdjustment(
            previous: previousPosition,
            today: todayPosition,
            feedback: feedback
        )
        
        modified.reps += adjustment.reps
        
        // Safety clamps
        modified.reps = max(4, modified.reps)
        modified.reps = min(25, modified.reps)
        
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
