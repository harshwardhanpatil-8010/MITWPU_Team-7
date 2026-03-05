import Foundation
import CoreData
import CryptoKit

class WorkoutManager {
    static let shared = WorkoutManager()

    // MARK: - Session State

    var lastCheckedMedState: MedState = .unknown

    enum MedState: Equatable {
        case unknown
        case snapshot(hasMeds: Bool, allTaken: Bool, effectRaw: String)
    }

    func currentMedState() -> MedState {
        .snapshot(
            hasMeds:   hasMedicationsAdded,
            allTaken:  allMedsTaken,
            effectRaw: String(describing: getMedicationEffect())
        )
    }

    var userWantsToPushLimits: Bool = false
    var exercises: [WorkoutExercise] = []
    var completedToday: [UUID] = []
    var skippedToday:   [UUID] = []

    // MARK: - Persistence Keys

    private let lastWorkoutCompletionDateKey = "lastWorkoutCompletionDate"
    private let lastWorkoutPositionKey       = "lastWorkoutPosition"
    private let lastJSONHashKey              = "lastWorkoutExercisesJSONHash"

    // MARK: - Enums

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

    // MARK: - Disease Stage

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

    /// True if at least one dose was physically logged (doseLoggedAt) within the
    /// last 3 hours with status "taken". Returns false when nothing logged → OFF period.
    var allMedsTaken: Bool {
        let context       = PersistenceController.shared.viewContext
        let threeHoursAgo = Calendar.current.date(byAdding: .hour, value: -3, to: Date())!

        let request: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "doseLoggedAt >= %@ AND doseLoggedAt <= %@ AND doseLogStatus == %@",
            threeHoursAgo as NSDate,
            Date() as NSDate,
            "taken"
        )
        do {
            let logs = try context.fetch(request)
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

    // MARK: - Exercise Generation

    /// Full adaptive — feedback ON, no intensity reduction.
    /// Use when: Stage 1/2 ON-period, OR Stage ≥ 3 standing with meds taken.
    func generateDailyWorkout(for position: ExercisePosition) {
        saveTodayPosition(position)
        exercises = buildExerciseSet(position: position, applyFeedback: true, reduceIntensity: false)
        saveCurrentJSONHash()
    }

    /// Reduced intensity, feedback NOT considered.
    /// Use when: meds NOT taken (any stage), OR Stage ≥ 3 standing without meds.
    func generateDailyWorkoutIgnoringFeedback(for position: ExercisePosition) {
        saveTodayPosition(position)
        exercises = buildExerciseSet(position: position, applyFeedback: false, reduceIntensity: true)
        saveCurrentJSONHash()
    }

    /// Reduced intensity, feedback IS considered.
    /// Use when: Stage ≥ 3 seated — safe position so feedback applies,
    /// but intensity is still moderated for the advanced stage.
    func generateDailyWorkoutReducedWithFeedback(for position: ExercisePosition) {
        saveTodayPosition(position)
        exercises = buildExerciseSet(position: position, applyFeedback: true, reduceIntensity: true)
        saveCurrentJSONHash()
    }

    // MARK: - Shared Exercise Set Builder

    private func buildExerciseSet(
        position: ExercisePosition,
        applyFeedback: Bool,
        reduceIntensity: Bool
    ) -> [WorkoutExercise] {
        let library = getStageFilteredLibrary(for: diseaseStage)
        var dailySet: [WorkoutExercise] = []

        for category in ExerciseCategory.allCases {
            let pool = library.filter { $0.category == category }

            switch category {

            case .warmup:
                let matched = pool.filter { $0.position == position }
                let source  = matched.isEmpty ? pool : matched
                dailySet += source.shuffled().prefix(2).map {
                    transform($0, position: position, applyFeedback: applyFeedback, reduceIntensity: reduceIntensity)
                }

            case .balance, .aerobic, .strength:
                let exercise = pool.filter { $0.position == position }.randomElement()
                              ?? pool.randomElement()
                if let ex = exercise {
                    dailySet.append(
                        transform(ex, position: position, applyFeedback: applyFeedback, reduceIntensity: reduceIntensity)
                    )
                }

            case .cooldown:
                let matched = pool.filter { $0.position == position }
                let source  = matched.isEmpty ? pool : matched
                dailySet += source.shuffled().prefix(2).map {
                    transform($0, position: position, applyFeedback: applyFeedback, reduceIntensity: reduceIntensity)
                }
            }
        }
        return dailySet
    }

    /// Single transform point: applies feedback adjustment first, then
    /// optionally clamps to minimum intensity if reduceIntensity is true.
    private func transform(
        _ exercise: WorkoutExercise,
        position: ExercisePosition,
        applyFeedback: Bool,
        reduceIntensity: Bool
    ) -> WorkoutExercise {
        var ex = applyFeedback
            ? applyProgressiveAlgorithm(to: exercise, todayPosition: position)
            : exercise

        if reduceIntensity {
            ex = applyMinimumIntensity(to: ex)
        }
        return ex
    }

    // MARK: - Lazy Load

    func getTodayWorkout() -> [WorkoutExercise] {
        if exercises.isEmpty || bundleJSONChanged() {
            generateDailyWorkout(for: loadLastWorkoutPosition() ?? .seated)
        }
        return exercises
    }

    // MARK: - Progressive Adjustment Algorithm

    private func calculateAdjustment(
        previous: ExercisePosition?,
        today: ExercisePosition,
        feedback: Feedback
    ) -> (reps: Int, seconds: Int) {
        guard let previous = previous else { return (0, 0) }

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
            let base = exercise.duration ?? 40
            modified.duration = max(15, min(60, base + adjustment.seconds))
        default:
            modified.reps = max(4, min(25, modified.reps + adjustment.reps))
        }
        return modified
    }

    // MARK: - Minimum Intensity

    private func applyMinimumIntensity(to exercise: WorkoutExercise) -> WorkoutExercise {
        var modified = exercise
        switch exercise.category {
        case .warmup, .cooldown:
            modified.duration = min(modified.duration ?? 40, 15)
        default:
            modified.reps = min(modified.reps, 4)
        }
        return modified
    }

    // MARK: - JSON Change Detection

    private func bundleJSONChanged() -> Bool {
        guard let currentHash = currentBundleJSONHash() else { return false }
        let savedHash = UserDefaults.standard.string(forKey: lastJSONHashKey)
        return currentHash != savedHash
    }

    private func currentBundleJSONHash() -> String? {
        guard let url = Bundle.main.url(forResource: "workout_exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func saveCurrentJSONHash() {
        if let hash = currentBundleJSONHash() {
            UserDefaults.standard.set(hash, forKey: lastJSONHashKey)
        }
    }

    // MARK: - Stage-Filtered Library

    private func getStageFilteredLibrary(for stage: Int) -> [WorkoutExercise] {
        let full = getFullLibrary()
        return stage >= 3 ? full.filter { $0.position == .seated } : full
    }

    private func getFullLibrary() -> [WorkoutExercise] {
        guard let url = Bundle.main.url(forResource: "workout_exercises", withExtension: "json") else { return [] }
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
        lastCheckedMedState   = .unknown
        userWantsToPushLimits = false
        UserDefaults.standard.removeObject(forKey: lastJSONHashKey)
        generateDailyWorkout(for: loadLastWorkoutPosition() ?? .seated)
    }
}
