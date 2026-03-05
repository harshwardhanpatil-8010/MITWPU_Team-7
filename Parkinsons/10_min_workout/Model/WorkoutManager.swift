import Foundation
import CoreData
import CryptoKit

class WorkoutManager {
    static let shared = WorkoutManager()

    // MARK: - Session State

    /// Prevents the safety/medication alert from re-appearing on every viewWillAppear.
    /// Reset this when starting a fresh session (e.g. new day or resetAllExercises).
    var hasCheckedSafetyThisSession = false

    /// Set to true by the UI when the user explicitly chooses standing exercises
    /// during a "medication wearing off" or "meds not taken" alert.
    var userWantsToPushLimits: Bool = false

    var exercises: [WorkoutExercise] = []
    var completedToday: [UUID] = []
    var skippedToday: [UUID] = []

    // MARK: - Persistence Keys

    private let lastWorkoutCompletionDateKey = "lastWorkoutCompletionDate"
    private let lastWorkoutPositionKey       = "lastWorkoutPosition"
    /// Stores the MD5 hash of the JSON last used to build exercises.
    /// When the bundled JSON changes, the hash won't match and exercises are regenerated.
    private let lastJSONHashKey = "lastWorkoutExercisesJSONHash"

    // MARK: - Enums

    enum Feedback {
        case easy       // stored value 1
        case perfect    // stored value 2  ← default if never set
        case hard       // stored value 3
    }

    enum MedicationEffect {
        case optimal     // < 3 hrs since last dose  → ON period
        case wearingOff  // 3–6 hrs since last dose  → transitioning
        case offPeriod   // > 6 hrs or no dose today → OFF period
    }

   
    enum ExerciseSafetyStatus {
       
        case approved(position: ExercisePosition)


        case safetyAlertRequired(stage: Int, proceedWithPosition: ExercisePosition)

      
        case onHold(reason: String)
    }

    // MARK: - Disease Stage

    /// Parkinson's stage (1–5) saved during onboarding or updated by a clinician.
    var diseaseStage: Int {
        return UserDefaults.standard.integer(forKey: "diseaseStage")
    }

    // MARK: - Workout Completion Tracking

    private var lastWorkoutCompletionDate: Date? {
        get { UserDefaults.standard.object(forKey: lastWorkoutCompletionDateKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastWorkoutCompletionDateKey) }
    }

    func hasCompletedWorkoutToday() -> Bool {
        guard let last = lastWorkoutCompletionDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    func setWorkoutCompleted() {
        lastWorkoutCompletionDate = Date()
        saveTodayPosition(preferredExercisePosition())
    }

    // MARK: - Position Persistence

    func saveTodayPosition(_ position: ExercisePosition) {
        UserDefaults.standard.set(position.rawValue, forKey: lastWorkoutPositionKey)
    }

    func loadLastWorkoutPosition() -> ExercisePosition? {
        guard let raw = UserDefaults.standard.string(forKey: lastWorkoutPositionKey) else { return nil }
        return ExercisePosition(rawValue: raw)
    }

    // MARK: - Feedback Persistence

    func saveFeedback(_ value: Int) {
        UserDefaults.standard.set(value, forKey: "lastWorkoutFeedback")
        UserDefaults.standard.set(Date(), forKey: "lastWorkoutFeedbackDate")
    }

    
    func loadLastFeedback() -> Int {
        let value = UserDefaults.standard.integer(forKey: "lastWorkoutFeedback")
        return value == 0 ? 2 : value
    }

    private func currentFeedback() -> Feedback {
        switch loadLastFeedback() {
        case 1:  return .easy
        case 3:  return .hard
        default: return .perfect
        }
    }

    // MARK: - Medication Status

 
    var allMedsTaken: Bool {
        let context       = PersistenceController.shared.viewContext
        let threeHoursAgo = Calendar.current.date(byAdding: .hour, value: -3, to: Date())!

        // Query by doseLoggedAt (actual intake time), not doseScheduledTime (scheduled time).
        // If no dose was physically logged in the last 3 hours → NOT in an ON period.
        let request: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "doseLoggedAt >= %@ AND doseLoggedAt <= %@ AND doseLogStatus == %@",
            threeHoursAgo as NSDate,
            Date() as NSDate,
            "taken"
        )

        do {
            let logs = try context.fetch(request)
            // No dose logged in the last 3 hours → not in an ON period
            return !logs.isEmpty
        } catch {
            return false
        }
    }


    var hasMedicationsAdded: Bool {
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        request.fetchLimit = 1
        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }


    func getMedicationEffect() -> MedicationEffect {
        let context    = PersistenceController.shared.viewContext
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay   = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        // Query by doseLoggedAt — when the user actually took the medication today.
        // Using doseScheduledTime was wrong: a dose scheduled at 8am looks "expired"
        // by 11am even if the user just took it moments ago.
        let request: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "doseLoggedAt >= %@ AND doseLoggedAt < %@ AND doseLogStatus == %@",
            startOfDay as NSDate,
            endOfDay as NSDate,
            "taken"
        )

        let logs   = (try? context.fetch(request)) ?? []
        let sorted = logs.sorted { ($0.doseLoggedAt ?? Date.distantPast) < ($1.doseLoggedAt ?? Date.distantPast) }

        guard let lastDose = sorted.last, let loggedAt = lastDose.doseLoggedAt else {
            return .offPeriod
        }

        let hours = Date().timeIntervalSince(loggedAt) / 3600
        if hours < 3 { return .optimal }
        if hours < 6 { return .wearingOff }
        return .offPeriod
    }

    // MARK: - Preferred Exercise Position

   
    func preferredExercisePosition() -> ExercisePosition {
     
        if !hasMedicationsAdded {
            return userWantsToPushLimits ? .standing : .seated
        }

        
        switch getMedicationEffect() {
        case .optimal:    return .standing
        case .wearingOff: return userWantsToPushLimits ? .standing : .seated
        case .offPeriod:  return userWantsToPushLimits ? .standing : .seated
        }
    }

    // MARK: - FIG. 2: Internal Safety Gate

    func evaluateSafetyStatus() -> ExerciseSafetyStatus {
        let stage        = diseaseStage
        let medicEffect  = getMedicationEffect()
        let preferredPos = preferredExercisePosition()

        // Stage ≥ 3 — safety alert already shown by LandingPage before calling generate
        if stage >= 3 {
            return .safetyAlertRequired(stage: stage, proceedWithPosition: preferredPos)
        }

      
        if !hasMedicationsAdded {
            return .approved(position: preferredPos)
        }

        // Stage 1/2 with medications present
        if preferredPos == .standing {
            switch medicEffect {
            case .offPeriod:
              
                if !userWantsToPushLimits {
                    return .onHold(reason: "Standing exercises are not safe during an OFF medication period. Please wait for your next ON period or switch to seated exercises.")
                }
                return .approved(position: .standing)
            case .wearingOff:
                return .approved(position: .standing)
            case .optimal:
                return .approved(position: .standing)
            }
        }

        // Seated is always safe
        return .approved(position: .seated)
    }

    // MARK: - FIG. 1 + FIG. 2: Primary Workout Generation  ← FEEDBACK CONSIDERED

    /// Generates workout using the UI-chosen position directly.
    /// Use this when the user has explicitly selected Standing or Seated from an alert.
    func generateDailyWorkout(for position: ExercisePosition) {
        self.exercises = buildExerciseSet(position: position, applyFeedback: true)
        saveCurrentJSONHash()
    }

    /// Derives position automatically from medication state + userWantsToPushLimits.
    /// Use this only when position was not explicitly chosen by the user this session.
    func generateDailyWorkout() {
        let safetyStatus = evaluateSafetyStatus()

        let approvedPosition: ExercisePosition
        switch safetyStatus {
        case .approved(let pos):
            approvedPosition = pos
        case .safetyAlertRequired(_, let pos):
            approvedPosition = pos
        case .onHold:
            self.exercises = []
            return
        }

        self.exercises = buildExerciseSet(position: approvedPosition, applyFeedback: true)
        saveCurrentJSONHash()
    }

    // MARK: - FIG. 2: Reduced-Intensity Generation  ← FEEDBACK NOT CONSIDERED

    /// Reduced intensity with UI-chosen position.
    func generateDailyWorkoutIgnoringFeedback(for position: ExercisePosition) {
        self.exercises = buildExerciseSet(position: position, applyFeedback: false)
        saveCurrentJSONHash()
    }

    /// Reduced intensity with auto-derived position.
    func generateDailyWorkoutIgnoringFeedback() {
        let safetyStatus = evaluateSafetyStatus()

        let approvedPosition: ExercisePosition
        switch safetyStatus {
        case .approved(let pos):
            approvedPosition = pos
        case .safetyAlertRequired(_, let pos):
            approvedPosition = pos
        case .onHold:
            self.exercises = []
            return
        }

        self.exercises = buildExerciseSet(position: approvedPosition, applyFeedback: false)
        saveCurrentJSONHash()
    }

    // MARK: - Shared Exercise Set Builder

    private func buildExerciseSet(position: ExercisePosition, applyFeedback: Bool) -> [WorkoutExercise] {
        let library = getStageFilteredLibrary(for: diseaseStage)
        var dailySet: [WorkoutExercise] = []

        for category in ExerciseCategory.allCases {
            let pool = library.filter { $0.category == category }

            switch category {

            case .warmup:
                
                let matched = pool.filter { $0.position == position }
                let source  = matched.isEmpty ? pool : matched
                dailySet += source.shuffled().prefix(2).map {
                    applyFeedback
                        ? applyProgressiveAlgorithm(to: $0, todayPosition: position)
                        : applyMinimumIntensity(to: $0)
                }

            case .balance, .aerobic, .strength:
                
                let exercise = pool.filter { $0.position == position }.randomElement()
                              ?? pool.randomElement()
                if let ex = exercise {
                    dailySet.append(
                        applyFeedback
                            ? applyProgressiveAlgorithm(to: ex, todayPosition: position)
                            : applyMinimumIntensity(to: ex)
                    )
                }

            case .cooldown:
                
                let matched = pool.filter { $0.position == position }
                let source  = matched.isEmpty ? pool : matched
                dailySet += source.shuffled().prefix(2).map {
                    applyFeedback
                        ? applyProgressiveAlgorithm(to: $0, todayPosition: position)
                        : applyMinimumIntensity(to: $0)
                }
            }
        }

        return dailySet
    }

    // MARK: - Lazy Load

    func getTodayWorkout() -> [WorkoutExercise] {
        // Force regeneration if the bundled JSON has changed since last build.
        // This ensures edits to workout_exercises.json are always picked up
        // without needing to manually clear the app or reset state.
        if exercises.isEmpty || bundleJSONChanged() {
            generateDailyWorkout()
            saveCurrentJSONHash()
        }
        return exercises
    }

    // MARK: - Progressive Adjustment Algorithm  (Feedback Considered)

  
    private func calculateAdjustment(
        previous: ExercisePosition?,
        today: ExercisePosition,
        feedback: Feedback
    ) -> (reps: Int, seconds: Int) {

        guard let previous = previous else {
            return (0, 0)
        }

        if previous == today {
            switch feedback {
            case .easy:    return ( 2,  20)
            case .perfect: return ( 1,  10)
            case .hard:    return (-2, -20)
            }
        }

        if previous == .seated && today == .standing {
            
            switch feedback {
            case .easy:    return ( 1,  10)
            case .perfect: return ( 0,   0)
            case .hard:    return (-2, -15)
            }
        }

        if previous == .standing && today == .seated {
            
            switch feedback {
            case .easy:    return ( 1,  10)
            case .perfect: return ( 0,   0)
            case .hard:    return (-1, -10)
            }
        }

        return (0, 0)
    }

    
    private func applyProgressiveAlgorithm(
        to exercise: WorkoutExercise,
        todayPosition: ExercisePosition
    ) -> WorkoutExercise {
        var modified   = exercise
        let prevPos    = loadLastWorkoutPosition()
        let feedback   = currentFeedback()
        let adjustment = calculateAdjustment(previous: prevPos, today: todayPosition, feedback: feedback)

        switch exercise.category {
        case .warmup, .cooldown:
            // Timed exercises: adjust duration (seconds), leave reps untouched
            let baseDuration = exercise.duration ?? 30
            modified.duration = max(15, min(60, baseDuration + adjustment.seconds))
        default:
            // Rep-based exercises: adjust reps, leave duration untouched
            modified.reps = max(4, min(25, modified.reps + adjustment.reps))
        }
        return modified
    }

    // MARK: - Minimum Intensity  (Feedback NOT Considered)

    
    
    private func applyMinimumIntensity(to exercise: WorkoutExercise) -> WorkoutExercise {
        var modified = exercise
        switch exercise.category {
        case .warmup, .cooldown:
            modified.duration = 15   // minimum 15-second timer for timed exercises
        default:
            modified.reps = 4        // minimum 4 reps for rep-based exercises
        }
        return modified
    }

    // MARK: - JSON Change Detection

    /// Returns true if the bundled workout_exercises.json has changed
    /// since the last time exercises were generated.
    private func bundleJSONChanged() -> Bool {
        guard let currentHash = currentBundleJSONHash() else { return false }
        let savedHash = UserDefaults.standard.string(forKey: lastJSONHashKey)
        return currentHash != savedHash
    }

    /// Computes a SHA256 hash of the bundled JSON data.
    private func currentBundleJSONHash() -> String? {
        guard let url = Bundle.main.url(forResource: "workout_exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Saves the current bundle JSON hash to UserDefaults.
    private func saveCurrentJSONHash() {
        if let hash = currentBundleJSONHash() {
            UserDefaults.standard.set(hash, forKey: lastJSONHashKey)
        }
    }

    // MARK: - Stage-Filtered Exercise Library

    private func getStageFilteredLibrary(for stage: Int) -> [WorkoutExercise] {
        let full = getFullLibrary()
        return stage >= 3 ? full.filter { $0.position == .seated } : full
    }

    private func getFullLibrary() -> [WorkoutExercise] {
        guard let url = Bundle.main.url(forResource: "workout_exercises", withExtension: "json") else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([WorkoutExercise].self, from: data)
        } catch {
            return []
        }
    }

    // MARK: - Reset

    func resetDailyProgress() {
        completedToday.removeAll()
        skippedToday.removeAll()
    }

    func resetAllExercises() {
        resetDailyProgress()
        hasCheckedSafetyThisSession = false
        userWantsToPushLimits       = false
        UserDefaults.standard.removeObject(forKey: lastJSONHashKey)
        generateDailyWorkout()
        saveCurrentJSONHash()
    }
}
