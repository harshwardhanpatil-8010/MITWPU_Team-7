import Foundation
import CoreData
import CryptoKit

class WorkoutManager {
    static let shared = WorkoutManager()

    // Thread synchronization using NSRecursiveLock to support safe multi-threaded access 
    // and reentrant calls during initialization/restoration.
    private let lock = NSRecursiveLock()
    private var hasRestored = false

    /// CRASH EXPLANATION & PREVENTION:
    /// Previously, WorkoutManager crashed on startup (EXC_BREAKPOINT / LLDB "parent is NULL") 
    /// due to a circular dependency during static initialization:
    /// 1. WorkoutManager.shared static initialization was triggered.
    /// 2. `init()` called `restorePersistedSessionIfAvailable()`.
    /// 3. If the persisted session was outdated, it called `clearPersistedSession()`.
    /// 4. `clearPersistedSession()` called `DailyWorkoutSummaryStore.shared.saveWorkoutSummary()`.
    /// 5. `saveWorkoutSummary()` accessed `WorkoutManager.shared` (which was still in the middle of initialization).
    /// This resulted in a thread deadlock on the dispatch_once lock for the static property.
    ///
    /// To prevent this crash:
    /// - The initializer is kept completely minimal, performing no heavy restoration or summary saving.
    /// - We implemented lazy bootstrapping via `ensureRestored()`. Any access to the workout session properties 
    ///   (`exercises`, `completedToday`, `skippedToday`) or operations triggering rollover will perform restoration 
    ///   exactly once, when `WorkoutManager.shared` has already been fully constructed.
    /// - We parameterized `clearPersistedSession(saveSummary:)` so we can bypass database sync 
    ///   during the bootstrap/restoration phase.
    private init() {
        print("[WorkoutManager] init: Minimal initialization completed. Lazy bootstrapping will be used.")
    }

    // Lazy bootstrap checker.
    private func ensureRestored() {
        lock.lock()
        defer { lock.unlock() }

        if hasRestored { return }
        hasRestored = true

        print("[WorkoutManager] restorePersistedSessionIfAvailable started")
        restorePersistedSessionIfAvailable()
        print("[WorkoutManager] session restore completed")
    }

    private var _lastCheckedMedState: MedState = .unknown
    var lastCheckedMedState: MedState {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _lastCheckedMedState
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _lastCheckedMedState = newValue
        }
    }

    enum MedState: Equatable {
        case unknown
        case snapshot(hasMeds: Bool, allTaken: Bool, effectRaw: String, adherenceRaw: String)
    }

    func currentMedState() -> MedState {
        let adherence = medicationAdherenceSnapshot()
        return .snapshot(
            hasMeds: hasMedicationsAdded,
            allTaken: allMedsTaken,
            effectRaw: String(describing: getMedicationEffect()),
            adherenceRaw: adherence.signature
        )
    }

    private var _userWantsToPushLimits: Bool = false
    var userWantsToPushLimits: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _userWantsToPushLimits
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _userWantsToPushLimits = newValue
        }
    }

    private var _exercises: [WorkoutExercise] = []
    var exercises: [WorkoutExercise] {
        get {
            lock.lock()
            defer { lock.unlock() }
            ensureRestored()
            return _exercises
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            ensureRestored()
            _exercises = newValue
        }
    }

    private var _completedToday: [UUID] = []
    var completedToday: [UUID] {
        get {
            lock.lock()
            defer { lock.unlock() }
            ensureRestored()
            return _completedToday
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            ensureRestored()
            _completedToday = newValue
        }
    }

    private var _skippedToday: [UUID] = []
    var skippedToday: [UUID] {
        get {
            lock.lock()
            defer { lock.unlock() }
            ensureRestored()
            return _skippedToday
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            ensureRestored()
            _skippedToday = newValue
        }
    }

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
        lock.lock()
        defer { lock.unlock() }
        return UserDefaults.standard.integer(forKey: "diseaseStage")
    }

    private var lastWorkoutCompletionDate: Date? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return UserDefaults.standard.object(forKey: lastWorkoutCompletionDateKey) as? Date
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            UserDefaults.standard.set(newValue, forKey: lastWorkoutCompletionDateKey)
        }
    }

    func hasCompletedWorkoutToday() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard let last = lastWorkoutCompletionDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    func setWorkoutCompleted() {
        lock.lock()
        defer { lock.unlock() }
        lastWorkoutCompletionDate = Date()
    }

    func syncSessionPersistence() {
        lock.lock()
        defer { lock.unlock() }
        persistCurrentSession()
    }

    /// SAFELY HANDLING CORRUPTED OR OUTDATED PERSISTENCE:
    /// Instead of using `try?` which fails silently or crashes, we implement:
    /// - Explicit `do-catch` validation block.
    /// - If JSON schema, struct format, or enum type mismatch is detected, we log a detailed error 
    ///   and clear ONLY workout-specific keys in UserDefaults via `clearPersistedSession(saveSummary: false)`.
    /// - Other UserDefaults keys (e.g. game rotation, layout settings, medication logs, stage) and CoreData structures
    ///   remain untouched to prevent data loss.
    private func restorePersistedSessionIfAvailable() {
        guard let storedDate = UserDefaults.standard.object(forKey: workoutSessionDateKey) as? Date else {
            print("[WorkoutManager] restore: No persisted workout session found. Initializing fresh empty arrays.")
            _exercises = []
            _completedToday = []
            _skippedToday = []
            return
        }

        if !Calendar.current.isDate(storedDate, inSameDayAs: Date()) {
            print("[WorkoutManager] restore: Stored session date (\(storedDate)) is outdated. Clearing yesterday's session data.")
            clearPersistedSession(saveSummary: false)
            return
        }

        if let data = UserDefaults.standard.data(forKey: workoutSessionExercisesKey) {
            do {
                let decoded = try JSONDecoder().decode([WorkoutExercise].self, from: data)
                _exercises = decoded
                print("[WorkoutManager] restore: Successfully decoded \(_exercises.count) exercises.")
            } catch {
                print("[WorkoutManager] ERROR: Failed to decode stored exercises: \(error). Performing fallback session recovery.")
                clearPersistedSession(saveSummary: false)
            }
        } else {
            print("[WorkoutManager] restore: No exercise session data key found.")
            _exercises = []
        }

        let completedStrings = UserDefaults.standard.stringArray(forKey: workoutSessionCompletedKey) ?? []
        _completedToday = completedStrings.compactMap { uuidString in
            guard let uuid = UUID(uuidString: uuidString) else {
                print("[WorkoutManager] restore WARNING: Invalid UUID string in completed array: \(uuidString)")
                return nil
            }
            return uuid
        }

        let skippedStrings = UserDefaults.standard.stringArray(forKey: workoutSessionSkippedKey) ?? []
        _skippedToday = skippedStrings.compactMap { uuidString in
            guard let uuid = UUID(uuidString: uuidString) else {
                print("[WorkoutManager] restore WARNING: Invalid UUID string in skipped array: \(uuidString)")
                return nil
            }
            return uuid
        }
    }

    private func persistCurrentSession() {
        lock.lock()
        defer { lock.unlock() }
        ensureRestored()

        print("[WorkoutManager] persistCurrentSession started")
        UserDefaults.standard.set(Calendar.current.startOfDay(for: Date()), forKey: workoutSessionDateKey)

        do {
            let data = try JSONEncoder().encode(_exercises)
            UserDefaults.standard.set(data, forKey: workoutSessionExercisesKey)
            print("[WorkoutManager] persistCurrentSession: Successfully encoded and saved \(_exercises.count) exercises.")
        } catch {
            print("[WorkoutManager] ERROR: Failed to encode current exercises: \(error)")
        }

        let completed = _completedToday.map(\.uuidString)
        let skipped = _skippedToday.map(\.uuidString)
        UserDefaults.standard.set(completed, forKey: workoutSessionCompletedKey)
        UserDefaults.standard.set(skipped, forKey: workoutSessionSkippedKey)
        print("[WorkoutManager] persistence save completed")
        DailyWorkoutSummaryStore.shared.saveWorkoutSummary()
    }

    private func clearPersistedSession(saveSummary: Bool = true) {
        lock.lock()
        defer { lock.unlock() }

        print("[WorkoutManager] clearPersistedSession triggered (saveSummary: \(saveSummary))")
        UserDefaults.standard.removeObject(forKey: workoutSessionDateKey)
        UserDefaults.standard.removeObject(forKey: workoutSessionExercisesKey)
        UserDefaults.standard.removeObject(forKey: workoutSessionCompletedKey)
        UserDefaults.standard.removeObject(forKey: workoutSessionSkippedKey)
        
        _exercises.removeAll()
        _completedToday.removeAll()
        _skippedToday.removeAll()
        
        if saveSummary {
            DailyWorkoutSummaryStore.shared.saveWorkoutSummary()
        }
    }

    private func rollOverSessionIfNeeded() {
        lock.lock()
        defer { lock.unlock() }
        ensureRestored()

        guard let storedDate = UserDefaults.standard.object(forKey: workoutSessionDateKey) as? Date else { return }
        if !Calendar.current.isDate(storedDate, inSameDayAs: Date()) {
            print("[WorkoutManager] rollOverSessionIfNeeded: Stored session date is different. Clearing session.")
            clearPersistedSession(saveSummary: true)
            lastCheckedMedState = .unknown
        }
    }

    func saveTodayPosition(_ position: ExercisePosition) {
        lock.lock()
        defer { lock.unlock() }
        UserDefaults.standard.set(position.rawValue, forKey: lastWorkoutPositionKey)
    }

    func loadLastWorkoutPosition() -> ExercisePosition? {
        lock.lock()
        defer { lock.unlock() }
        guard let raw = UserDefaults.standard.string(forKey: lastWorkoutPositionKey) else { return nil }
        return ExercisePosition(rawValue: raw)
    }

    func saveFeedback(_ value: Int) {
        lock.lock()
        defer { lock.unlock() }
        UserDefaults.standard.set(value, forKey: "lastWorkoutFeedback")
        UserDefaults.standard.set(Date(), forKey: "lastWorkoutFeedbackDate")
    }

    func loadLastFeedback() -> Int {
        lock.lock()
        defer { lock.unlock() }
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
        lock.lock()
        defer { lock.unlock() }
        ensureRestored()

        rollOverSessionIfNeeded()
        saveTodayPosition(position)
        _exercises = buildExerciseSet(position: position, applyFeedback: true, reduceIntensity: false)
        saveCurrentJSONHash()
        persistCurrentSession()
    }

    func generateDailyWorkoutIgnoringFeedback(for position: ExercisePosition) {
        lock.lock()
        defer { lock.unlock() }
        ensureRestored()

        rollOverSessionIfNeeded()
        saveTodayPosition(position)
        _exercises = buildExerciseSet(position: position, applyFeedback: false, reduceIntensity: true)
        saveCurrentJSONHash()
        persistCurrentSession()
    }

    func generateDailyWorkoutReducedWithFeedback(for position: ExercisePosition) {
        lock.lock()
        defer { lock.unlock() }
        ensureRestored()

        rollOverSessionIfNeeded()
        saveTodayPosition(position)
        _exercises = buildExerciseSet(position: position, applyFeedback: true, reduceIntensity: true)
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
        lock.lock()
        defer { lock.unlock() }
        ensureRestored()

        rollOverSessionIfNeeded()
        if _exercises.isEmpty || bundleJSONChanged() {
            generateDailyWorkout(for: loadLastWorkoutPosition() ?? .seated)
        }
        return _exercises
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
            case .perfect: return ( 0, 0)
            case .hard:    return (-1, 10)
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
        lock.lock()
        defer { lock.unlock() }
        ensureRestored()

        _completedToday.removeAll()
        _skippedToday.removeAll()
        persistCurrentSession()
    }

    func resetAllExercises() {
        lock.lock()
        defer { lock.unlock() }
        ensureRestored()

        resetDailyProgress()

        lastCheckedMedState   = .unknown
        userWantsToPushLimits = false
        UserDefaults.standard.removeObject(forKey: lastJSONHashKey)
        clearPersistedSession(saveSummary: true)
        generateDailyWorkout(for: loadLastWorkoutPosition() ?? .seated)
    }
}
