import Foundation
import CoreData
import CryptoKit

class WorkoutManager {
    static let shared = WorkoutManager()

    private init() {
        restorePersistedSessionIfAvailable()
    }

    var lastCheckedMedState: MedState = .unknown

    enum MedState: Equatable {
        case unknown
        case snapshot(hasMeds: Bool, allTaken: Bool, effectRaw: String, adherenceRaw: String)
    }

    func currentMedState() -> MedState {
        let adherence = medicationAdherenceSnapshot()
        return .snapshot(
            hasMeds:   hasMedicationsAdded,
            allTaken:  allMedsTaken,
            effectRaw: String(describing: getMedicationEffect()),
            adherenceRaw: adherence.signature
        )
    }

    var userWantsToPushLimits: Bool = false
    var exercises: [WorkoutExercise] = []
    var completedToday: [UUID] = []
    var skippedToday:   [UUID] = []



    private let lastWorkoutCompletionDateKey = "lastWorkoutCompletionDate"
    private let lastWorkoutPositionKey       = "lastWorkoutPosition"
    private let lastJSONHashKey              = "lastWorkoutExercisesJSONHash"
    private let workoutSessionDateKey        = "workoutSessionDate"
    private let workoutSessionExercisesKey   = "workoutSessionExercises"
    private let workoutSessionCompletedKey   = "workoutSessionCompletedIDs"
    private let workoutSessionSkippedKey     = "workoutSessionSkippedIDs"



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

    struct MedicationAdherenceSnapshot {
        let scheduledCount: Int
        let takenCount: Int
        let skippedCount: Int
        let missedCount: Int

        var signature: String {
            "\(scheduledCount)-\(takenCount)-\(skippedCount)-\(missedCount)"
        }

        var isReadyForFullAdaptiveWorkout: Bool {
            guard scheduledCount > 0 else { return false }
            return takenCount == scheduledCount && skippedCount == 0 && missedCount == 0
        }
    }


    var diseaseStage: Int {
        return UserDefaults.standard.integer(forKey: "diseaseStage")
    }


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


    func syncSessionPersistence() {
        persistCurrentSession()
        DailyWorkoutSummaryStore.shared.saveWorkoutSummary()
    }

    private func restorePersistedSessionIfAvailable() {
        guard let storedDate = UserDefaults.standard.object(forKey: workoutSessionDateKey) as? Date else { return }

        if !Calendar.current.isDate(storedDate, inSameDayAs: Date()) {
            clearPersistedSession()
            return
        }

        if let data = UserDefaults.standard.data(forKey: workoutSessionExercisesKey),
           let decoded = try? JSONDecoder().decode([WorkoutExercise].self, from: data) {
            exercises = decoded
        }

        let completedStrings = UserDefaults.standard.stringArray(forKey: workoutSessionCompletedKey) ?? []
        completedToday = completedStrings.compactMap(UUID.init(uuidString:))

        let skippedStrings = UserDefaults.standard.stringArray(forKey: workoutSessionSkippedKey) ?? []
        skippedToday = skippedStrings.compactMap(UUID.init(uuidString:))
    }

    private func persistCurrentSession() {
        UserDefaults.standard.set(Calendar.current.startOfDay(for: Date()), forKey: workoutSessionDateKey)

        if let data = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(data, forKey: workoutSessionExercisesKey)
        }

        let completed = completedToday.map(\.uuidString)
        let skipped = skippedToday.map(\.uuidString)
        UserDefaults.standard.set(completed, forKey: workoutSessionCompletedKey)
        UserDefaults.standard.set(skipped, forKey: workoutSessionSkippedKey)
        DailyWorkoutSummaryStore.shared.saveWorkoutSummary()
    }

    private func clearPersistedSession() {
        UserDefaults.standard.removeObject(forKey: workoutSessionDateKey)
        UserDefaults.standard.removeObject(forKey: workoutSessionExercisesKey)
        UserDefaults.standard.removeObject(forKey: workoutSessionCompletedKey)
        UserDefaults.standard.removeObject(forKey: workoutSessionSkippedKey)
        exercises.removeAll()
        completedToday.removeAll()
        skippedToday.removeAll()
        DailyWorkoutSummaryStore.shared.saveWorkoutSummary()
    }

    private func rollOverSessionIfNeeded() {
        guard let storedDate = UserDefaults.standard.object(forKey: workoutSessionDateKey) as? Date else { return }
        if !Calendar.current.isDate(storedDate, inSameDayAs: Date()) {
            clearPersistedSession()
            lastCheckedMedState = .unknown
        }
    }


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

    var allMedsTaken: Bool {
        medicationAdherenceSnapshot().isReadyForFullAdaptiveWorkout
    }

    var hasMedicationsAdded: Bool {
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        request.fetchLimit = 1
        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }

    func medicationAdherenceSnapshot(
        windowHours: Int = 3,
        graceMinutes: Int = 30
    ) -> MedicationAdherenceSnapshot {
        let context = PersistenceController.shared.viewContext
        let now = Date()
        let windowStart = Calendar.current.date(byAdding: .hour, value: -windowHours, to: now) ?? now

        let medicationRequest: NSFetchRequest<Medication> = Medication.fetchRequest()
        let medications = (try? context.fetch(medicationRequest)) ?? []
        guard !medications.isEmpty else {
            return MedicationAdherenceSnapshot(scheduledCount: 0, takenCount: 0, skippedCount: 0, missedCount: 0)
        }

        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? now
        let logRequest: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
        logRequest.predicate = NSPredicate(
            format: "doseDay >= %@ AND doseDay < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        let logs = (try? context.fetch(logRequest)) ?? []

        var latestLogByDoseID: [UUID: MedicationDoseLog] = [:]
        for log in logs {
            guard let doseID = log.dose?.id else { continue }
            let current = latestLogByDoseID[doseID]
            let currentDate = current?.doseLoggedAt ?? .distantPast
            let newDate = log.doseLoggedAt ?? .distantPast
            if newDate >= currentDate {
                latestLogByDoseID[doseID] = log
            }
        }

        var scheduledCount = 0
        var takenCount = 0
        var skippedCount = 0
        var missedCount = 0
        let graceSeconds = TimeInterval(graceMinutes * 60)

        for medication in medications where isMedicationDueToday(medication) {
            let doseSet = medication.doses as? Set<MedicationDose> ?? []
            for dose in doseSet {
                guard
                    let doseID = dose.id,
                    let doseTime = dose.doseTime
                else { continue }

                let scheduledTime = normalizeToToday(doseTime)
                guard scheduledTime >= windowStart, scheduledTime <= now else { continue }

                guard scheduledTime.addingTimeInterval(graceSeconds) <= now else { continue }

                scheduledCount += 1
                let status = latestLogByDoseID[doseID]?.doseLogStatus ?? ""

                if status == "taken" {
                    takenCount += 1
                } else if status == "skipped" {
                    skippedCount += 1
                } else {
                    missedCount += 1
                }
            }
        }

        return MedicationAdherenceSnapshot(
            scheduledCount: scheduledCount,
            takenCount: takenCount,
            skippedCount: skippedCount,
            missedCount: missedCount
        )
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

    private func isMedicationDueToday(_ med: Medication) -> Bool {
        let type = med.medicationScheduleType ?? "none"
        let days = med.medicationScheduleDays as? [Int] ?? []

        switch type {
        case "everyday":
            return true
        case "weekly":
            let weekday = Calendar.current.component(.weekday, from: Date())
            return days.contains(weekday)
        default:
            return false
        }
    }

    private func normalizeToToday(_ date: Date) -> Date {
        let cal = Calendar.current
        let comp = cal.dateComponents([.hour, .minute], from: date)
        return cal.date(
            bySettingHour: comp.hour ?? 0,
            minute: comp.minute ?? 0,
            second: 0,
            of: Date()
        ) ?? Date()
    }


    func generateDailyWorkout(for position: ExercisePosition) {
        rollOverSessionIfNeeded()
        saveTodayPosition(position)
        exercises = buildExerciseSet(position: position, applyFeedback: true, reduceIntensity: false)
        saveCurrentJSONHash()
        persistCurrentSession()
    }
    func generateDailyWorkoutIgnoringFeedback(for position: ExercisePosition) {
        rollOverSessionIfNeeded()
        saveTodayPosition(position)
        exercises = buildExerciseSet(position: position, applyFeedback: false, reduceIntensity: true)
        saveCurrentJSONHash()
        persistCurrentSession()
    }

    func generateDailyWorkoutReducedWithFeedback(for position: ExercisePosition) {
        rollOverSessionIfNeeded()
        saveTodayPosition(position)
        exercises = buildExerciseSet(position: position, applyFeedback: true, reduceIntensity: true)
        saveCurrentJSONHash()
        persistCurrentSession()
    }


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


    func getTodayWorkout() -> [WorkoutExercise] {
        rollOverSessionIfNeeded()
        if exercises.isEmpty || bundleJSONChanged() {
            generateDailyWorkout(for: loadLastWorkoutPosition() ?? .seated)
        }
        return exercises
    }


    private func calculateAdjustment(
        previous: ExercisePosition?,
        today: ExercisePosition,
        feedback: Feedback
    ) -> (reps: Int, seconds: Int) {
        guard let previous = previous else { return (0, 0) }

        if previous == today || (previous == .seated && today == .standing) || (previous == .standing && today == .seated) {
            switch feedback {
            case .easy:    return ( 2, -10)
            case .perfect: return ( 0,   0)
            case .hard:    return (-1,  10)
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
            modified.duration = max(20, min(60, base + adjustment.seconds))
        default:
            modified.reps = max(6, min(14, modified.reps + adjustment.reps))
        }
        return modified
    }


    private func applyMinimumIntensity(to exercise: WorkoutExercise) -> WorkoutExercise {
        var modified = exercise
        switch exercise.category {
        case .warmup, .cooldown:
            modified.duration = min(modified.duration ?? 40, 30)
        default:
            modified.reps = min(modified.reps, 8)
        }
        return modified
    }


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


    private func getStageFilteredLibrary(for stage: Int) -> [WorkoutExercise] {
        _ = stage
        return getFullLibrary()
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


    func resetDailyProgress() {
        completedToday.removeAll()
        skippedToday.removeAll()
        persistCurrentSession()
    }

    func resetAllExercises() {
        resetDailyProgress()
        lastCheckedMedState   = .unknown
        userWantsToPushLimits = false
        UserDefaults.standard.removeObject(forKey: lastJSONHashKey)
        clearPersistedSession()
        generateDailyWorkout(for: loadLastWorkoutPosition() ?? .seated)
    }
}
