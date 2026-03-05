import Foundation
import CoreData
import CryptoKit

class WorkoutManager {
    static let shared = WorkoutManager()

    // MARK: - Session State

    /// Snapshot of med state at the time the last safety check ran.
    /// On every viewWillAppear (while no progress exists) we compare the
    /// live state to this snapshot — if they differ we re-run the check.
    var lastCheckedMedState: MedState = .unknown

    enum MedState: Equatable {
        case unknown
        case snapshot(hasMeds: Bool, allTaken: Bool, effectRaw: String)
    }

    func currentMedState() -> MedState {
        .snapshot(
            hasMeds:    hasMedicationsAdded,
            allTaken:   allMedsTaken,
            effectRaw:  String(describing: getMedicationEffect())
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
        case optimal      // < 3 hrs since last dose  → ON period
        case wearingOff   // 3–6 hrs since last dose  → transitioning
        case offPeriod    // > 6 hrs or no dose today → OFF period
    }

    enum ExerciseSafetyStatus {
        case approved(position: ExercisePosition)
        case safetyAlertRequired(stage: Int, proceedWithPosition: ExercisePosition)
        case onHold(reason: String)
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
    /// last 3 hours with status "taken". Returns false if nothing was logged → OFF period.
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
            return !logs.isEmpty     // at least one dose logged in the window → ON period
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

    /// Derives how far into the medication effect window the user currently is,
    /// using doseLoggedAt (actual intake time) — NOT doseScheduledTime.
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

    // MARK: - Exercise Generation (position passed explicitly by UI)

    /// Full feedback algorithm — call this when meds are confirmed taken (ON period)
    /// or when no meds are added and the user chose a position.
    func generateDailyWorkout(for position: ExercisePosition) {
        saveTodayPosition(position)
        exercises = buildExerciseSet(position: position, applyFeedback: true)
        saveCurrentJSONHash()
    }

    /// Reduced intensity, no feedback — call this when meds are NOT taken in window.
    func generateDailyWorkoutIgnoringFeedback(for position: ExercisePosition) {
        saveTodayPosition(position)
        exercises = buildExerciseSet(position: position, applyFeedback: false)
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
        if exercises.isEmpty || bundleJSONChanged() {
            // No position known yet — default to seated until the alert fires
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
            let baseDuration = exercise.duration ?? 40
            modified.duration = max(15, min(60, baseDuration + adjustment.seconds))
        default:
            modified.reps = max(4, min(25, modified.reps + adjustment.reps))
        }
        return modified
    }

    // MARK: - Minimum Intensity (Feedback NOT Considered)

    private func applyMinimumIntensity(to exercise: WorkoutExercise) -> WorkoutExercise {
        var modified = exercise
        switch exercise.category {
        case .warmup, .cooldown:
            modified.duration = 15
        default:
            modified.reps = 4
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
        lastCheckedMedState  = .unknown
        userWantsToPushLimits = false
        UserDefaults.standard.removeObject(forKey: lastJSONHashKey)
        generateDailyWorkout(for: loadLastWorkoutPosition() ?? .seated)
    }
}
