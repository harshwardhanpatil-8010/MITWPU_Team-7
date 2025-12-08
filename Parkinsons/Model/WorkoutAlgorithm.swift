//
//  WorkoutAlgorithm.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation

struct Exercise: Codable, Identifiable {
    let id: UUID
    let name: String
    let category: ExerciseCategory
    var reps: Int
    let minReps: Int
    let maxReps: Int
    var skipCount: Int
    var isSuppressed: Bool
    var suppressedUntil: Date?
    var lastUsedModuleIndex: Int?
    var consecutiveUse: Int
    var usageHistory: [ExerciseUsage]
    var baseReps: Int?
    var offDayReps: Int?
    var lastOffDayUsed: Date?
    var consecutiveOffDaySuccess: Int
    var videoID: String?


    init(id: UUID = UUID(), name: String, category: ExerciseCategory, minReps: Int = 5, maxReps: Int = 20) {
        self.id = id
        self.name = name
        self.category = category
        self.reps = minReps
        self.minReps = minReps
        self.maxReps = maxReps
        self.skipCount = 0
        self.isSuppressed = false
        self.suppressedUntil = nil
        self.lastUsedModuleIndex = nil
        self.consecutiveUse = 0
        self.usageHistory = []
        self.baseReps = nil
        self.offDayReps = nil
        self.lastOffDayUsed = nil
        self.consecutiveOffDaySuccess = 0
    }
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case stretch
    case strength
    case balance
}

struct ExerciseUsage: Codable {
    let date: Date
    let completed: Bool
    let feedbackRating: WorkoutRating?
}

enum WorkoutRating: String, Codable {
    case easy
    case justRight
    case hard
}

enum QuitReason: String, Codable {
    case justTrying
    case tired
    case tooDifficult
}

struct WorkoutModule: Codable {
    let id: UUID
    let moduleIndex: Int
    let exercises: [Exercise]
    let createdAt: Date
    var completedExercises: Set<UUID>
    var skippedExercises: Set<UUID>
    var overallRating: WorkoutRating?
    var isOffDayModule: Bool

    init(moduleIndex: Int, exercises: [Exercise], isOffDayModule: Bool = false) {
        self.id = UUID()
        self.moduleIndex = moduleIndex
        self.exercises = exercises
        self.createdAt = Date()
        self.completedExercises = []
        self.skippedExercises = []
        self.overallRating = nil
        self.isOffDayModule = isOffDayModule
    }
}

struct WorkoutSession: Codable {
    let id: UUID
    let moduleIndex: Int
    let startTime: Date
    var quitTime: Date?
    var quitReason: QuitReason?
    var exercisesCompletedBeforeQuit: Int
    var wasResumed: Bool
    var resumedAt: Date?
    var difficultyAdjustmentApplied: String?

    init(moduleIndex: Int) {
        self.id = UUID()
        self.moduleIndex = moduleIndex
        self.startTime = Date()
        self.quitTime = nil
        self.quitReason = nil
        self.exercisesCompletedBeforeQuit = 0
        self.wasResumed = false
        self.resumedAt = nil
        self.difficultyAdjustmentApplied = nil
    }
}

struct ModuleHistory: Codable {
    let moduleIndex: Int
    let date: Date
    let rating: WorkoutRating?
    let isOffDayModule: Bool
}

struct UserHealthState: Codable {
    var isOffDay: Bool
    var offDayStartedAt: Date?
    var consecutiveOffDays: Int
    var lastOffDayDate: Date?
    var offDayHistory: [Date]

    init() {
        self.isOffDay = false
        self.offDayStartedAt = nil
        self.consecutiveOffDays = 0
        self.lastOffDayDate = nil
        self.offDayHistory = []
    }
}

enum WorkoutNotificationType {
    case supportive
    case encouragement
    case celebration
    case warning
    case critical
}

struct WorkoutNotification {
    let title: String
    let message: String
    let type: WorkoutNotificationType
}

class WorkoutManager {
    static let shared = WorkoutManager()
   
    var exercises: [Exercise] = []
    var currentModule: WorkoutModule?
    var currentSession: WorkoutSession?
    var moduleHistory: [ModuleHistory] = []
    var userHealthState: UserHealthState = UserHealthState()
    var pendingNotification: WorkoutNotification?

    private var currentModuleIndex: Int = 0
    private let exercisesPerCategory = 2
    private let suppressionRecoveryThreshold = 3
    private let maxModuleHistoryCount = 10
    private let offDayReductionPercentage = 0.4
    private let absoluteMinimumReps = 3

    var caregiverNotificationsEnabled = false
    var caregiverContactInfo: String?

    private init() {
        loadData()
    }

    private func loadData() {
        // Load exercises
        if let data = UserDefaults.standard.data(forKey: "exercises"),
           let decoded = try? JSONDecoder().decode([Exercise].self, from: data) {
            self.exercises.removeAll()
            self.exercises.append(contentsOf: decoded)
        } else {
            let defaultExercises = createDefaultExercises()
            self.exercises.removeAll()
            self.exercises.append(contentsOf: defaultExercises)
            saveExercises()
        }

        // Load moduleHistory
        if let h = UserDefaults.standard.data(forKey: "moduleHistory"),
           let d = try? JSONDecoder().decode([ModuleHistory].self, from: h) {
            self.moduleHistory = d
        }

        // Load userHealthState
        if let h = UserDefaults.standard.data(forKey: "userHealthState"),
           let d = try? JSONDecoder().decode(UserHealthState.self, from: h) {
            self.userHealthState = d
        }

        // Load currentSession
        if let h = UserDefaults.standard.data(forKey: "currentSession"),
           let d = try? JSONDecoder().decode(WorkoutSession.self, from: h) {
            self.currentSession = d
        }

        // Load simple values
        currentModuleIndex = UserDefaults.standard.integer(forKey: "currentModuleIndex")
        caregiverNotificationsEnabled = UserDefaults.standard.bool(forKey: "caregiverNotificationsEnabled")
        caregiverContactInfo = UserDefaults.standard.string(forKey: "caregiverContactInfo")
    }

    private func saveExercises() {

        let storeItems = self.exercises.map { exercise in
            ExerciseStoreItem(
                id: exercise.id,
                name: exercise.name,
                videoID: exercise.videoID ?? "",
                category: exercise.category.rawValue,
                reps: exercise.reps,
                minReps: exercise.minReps,
                maxReps: exercise.maxReps,
                skipCount: exercise.skipCount,
                isSuppressed: exercise.isSuppressed,
                suppressedUntil: exercise.suppressedUntil ?? .distantPast
            )
        }

        ExerciseStore.shared.replaceExercises(with: storeItems)
        ExerciseStore.shared.save()
    }


    private func saveModuleHistory() {
        if let encoded = try? JSONEncoder().encode(moduleHistory) { UserDefaults.standard.set(encoded, forKey: "moduleHistory") }
    }

    private func saveUserHealthState() {
        if let encoded = try? JSONEncoder().encode(userHealthState) { UserDefaults.standard.set(encoded, forKey: "userHealthState") }
    }

    private func saveCurrentSession() {
        if let encoded = try? JSONEncoder().encode(currentSession) { UserDefaults.standard.set(encoded, forKey: "currentSession") }
    }

    private func createDefaultExercises() -> [Exercise] {
        let stretch = ["Neck Rolls","Shoulder Circles","Arm Circles","Torso Twists","Hip Circles"]
        let strength = ["Push-ups","Squats","Lunges","Plank","Mountain Climbers"]
        let balance = ["Single Leg Stand","Tree Pose","Warrior III","Heel-to-Toe Walk","Single Leg Deadlift"]

        var result: [Exercise] = []
        for n in stretch { result.append(Exercise(name: n, category: .stretch, minReps: 3, maxReps: 15)) }
        for n in strength { result.append(Exercise(name: n, category: .strength, minReps: 3, maxReps: 20)) }
        for n in balance { result.append(Exercise(name: n, category: .balance, minReps: 3, maxReps: 20)) }
        return result
    }

    func generateNewModule() {
        currentModuleIndex += 1
        recoverSuppressedExercises()
        checkOffDayRecovery()
        var selected: [Exercise] = []
        for c in ExerciseCategory.allCases {
            let list = userHealthState.isOffDay ? selectOffDayExercises(category: c, count: exercisesPerCategory) : selectExercisesForCategory(c, count: exercisesPerCategory)
            selected.append(contentsOf: list)
        }
        if userHealthState.isOffDay {
            for i in 0..<selected.count {
                if let off = selected[i].offDayReps { selected[i].reps = off }
            }
        }
        currentModule = WorkoutModule(moduleIndex: currentModuleIndex, exercises: selected, isOffDayModule: userHealthState.isOffDay)
        currentSession = WorkoutSession(moduleIndex: currentModuleIndex)
        saveCurrentSession()
        UserDefaults.standard.set(currentModuleIndex, forKey: "currentModuleIndex")
    }

    private func selectExercisesForCategory(_ category: ExerciseCategory, count: Int) -> [Exercise] {
        var pool = exercises.filter { $0.category == category && !$0.isSuppressed }
        if pool.count < count {
            let suppressed = exercises.filter { $0.category == category && $0.isSuppressed }.sorted { $0.skipCount < $1.skipCount }
            pool.append(contentsOf: suppressed.prefix(count - pool.count))
        }
        var scored = pool.map { e -> (Exercise, Double) in
            let t = calculateTimeSinceLastUsed(e)
            let s = (t * 2.0) - Double(e.consecutiveUse) - Double(e.skipCount) * 3.0
            return (e, s)
        }
        scored.sort { $0.1 > $1.1 }
        let list = scored.prefix(count).map { $0.0 }
        for e in list {
            if let idx = exercises.firstIndex(where: { $0.id == e.id }) { exercises[idx].lastUsedModuleIndex = currentModuleIndex }
        }
        return list
    }

    private func selectOffDayExercises(category: ExerciseCategory, count: Int) -> [Exercise] {
        var pool = exercises.filter { $0.category == category && !$0.isSuppressed }
        if pool.count < count {
            let suppressed = exercises.filter { $0.category == category && $0.isSuppressed }.sorted { $0.skipCount < $1.skipCount }
            pool.append(contentsOf: suppressed.prefix(count - pool.count))
        }
        var scored = pool.map { e -> (Exercise, Double) in
            let t = calculateTimeSinceLastUsed(e)
            let r = calculateCompletionRate(e)
            let s = (t * 1.0) - (Double(e.consecutiveUse) * 0.5) - Double(e.skipCount) * 5.0 + r * 3.0
            return (e, s)
        }
        scored.sort { $0.1 > $1.1 }
        let list = scored.prefix(count).map { $0.0 }
        for e in list {
            if let idx = exercises.firstIndex(where: { $0.id == e.id }) { exercises[idx].lastUsedModuleIndex = currentModuleIndex }
        }
        return list
    }

    private func calculateTimeSinceLastUsed(_ e: Exercise) -> Double {
        guard let last = e.lastUsedModuleIndex else { return Double(currentModuleIndex) }
        return Double(currentModuleIndex - last)
    }

    private func calculateCompletionRate(_ e: Exercise) -> Double {
        let c = e.usageHistory.filter { $0.completed }.count
        let t = e.usageHistory.count
        if t == 0 { return 0.5 }
        return Double(c) / Double(t)
    }

    func completeExercise(_ id: UUID) {
        guard var m = currentModule else { return }
        m.completedExercises.insert(id)
        currentModule = m
        if let idx = exercises.firstIndex(where: { $0.id == id }) {
            if exercises[idx].skipCount > 0 { exercises[idx].skipCount -= 1 }
            exercises[idx].consecutiveUse += 1
            exercises[idx].usageHistory.append(ExerciseUsage(date: Date(), completed: true, feedbackRating: nil))
            saveExercises()
        }
    }

    func skipExercise(_ id: UUID) {
        guard var m = currentModule else { return }
        m.skippedExercises.insert(id)
        currentModule = m
        if let idx = exercises.firstIndex(where: { $0.id == id }) {
            exercises[idx].skipCount += 1
            exercises[idx].consecutiveUse = 0
            if exercises[idx].skipCount >= 2 {
                exercises[idx].isSuppressed = true
                let days = 7 * exercises[idx].skipCount
                exercises[idx].suppressedUntil = Calendar.current.date(byAdding: .day, value: days, to: Date())
            }
            exercises[idx].usageHistory.append(ExerciseUsage(date: Date(), completed: false, feedbackRating: nil))
            saveExercises()
        }
    }

    func quitWorkout(reason: QuitReason) {
        guard var s = currentSession, let m = currentModule else { return }
        s.quitTime = Date()
        s.quitReason = reason
        s.exercisesCompletedBeforeQuit = m.completedExercises.count
        currentSession = s
        if reason == .tired { applyTiredAdjustment() }
        if reason == .tooDifficult { triggerOffDayProtocol() }
        saveCurrentSession()
        saveExercises()
    }

    private func applyTiredAdjustment() {
        guard let m = currentModule else { return }
        for e in m.exercises where !m.completedExercises.contains(e.id) {
            if let idx = exercises.firstIndex(where: { $0.id == e.id }) {
                exercises[idx].reps = max(exercises[idx].minReps, exercises[idx].reps - 1)
            }
        }
    }

    private func triggerOffDayProtocol() {
        userHealthState.isOffDay = true
        userHealthState.offDayStartedAt = Date()
        let today = Calendar.current.startOfDay(for: Date())
        if let last = userHealthState.lastOffDayDate, Calendar.current.isDate(last, inSameDayAs: today) {
            userHealthState.consecutiveOffDays += 1
        } else {
            userHealthState.consecutiveOffDays = 1
        }
        userHealthState.lastOffDayDate = today
        userHealthState.offDayHistory.append(today)
        applyOffDayAdjustments()
        if userHealthState.consecutiveOffDays >= 3 { handleExtendedOffDay() }
        saveUserHealthState()
    }

    private func applyOffDayAdjustments() {
        guard let m = currentModule else { return }
        for e in m.exercises where !m.completedExercises.contains(e.id) {
            if let idx = exercises.firstIndex(where: { $0.id == e.id }) {
                if exercises[idx].baseReps == nil { exercises[idx].baseReps = exercises[idx].reps }
                let reduction = Int(Double(exercises[idx].reps) * 0.4)
                exercises[idx].offDayReps = max(3, exercises[idx].reps - reduction)
                exercises[idx].reps = exercises[idx].offDayReps!
                exercises[idx].lastOffDayUsed = Date()
            }
        }
        for idx in 0..<exercises.count {
            if exercises[idx].baseReps == nil { exercises[idx].baseReps = exercises[idx].reps }
            let reduction = Int(Double(exercises[idx].reps) * 0.4)
            exercises[idx].offDayReps = max(3, exercises[idx].reps - reduction)
        }
        saveExercises()
    }

    private func handleExtendedOffDay() {
        for idx in 0..<exercises.count {
            if let off = exercises[idx].offDayReps {
                exercises[idx].offDayReps = max(3, Int(Double(off) * 0.8))
            }
        }
        saveExercises()
    }

    func resumeWorkout() {
        guard var s = currentSession else { return }
        s.wasResumed = true
        s.resumedAt = Date()
        currentSession = s
        saveCurrentSession()
        if userHealthState.isOffDay { generateNewModule() }
    }

    func submitModuleFeedback(rating: WorkoutRating) {
        guard var m = currentModule else { return }
        m.overallRating = rating
        currentModule = m
        let h = ModuleHistory(moduleIndex: currentModuleIndex, date: Date(), rating: rating, isOffDayModule: m.isOffDayModule)
        moduleHistory.append(h)
        if moduleHistory.count > 10 { moduleHistory.removeFirst() }
        saveModuleHistory()
        if m.isOffDayModule { updateOffDayExerciseDifficulty(rating: rating) }
        else {
            for id in m.completedExercises { updateExerciseDifficulty(exerciseId: id, rating: rating) }
        }
        saveExercises()
    }

    private func updateExerciseDifficulty(exerciseId: UUID, rating: WorkoutRating) {
        guard let idx = exercises.firstIndex(where: { $0.id == exerciseId }) else { return }
        switch rating {
        case .easy:
            exercises[idx].reps += 1
        case .hard:
            exercises[idx].reps -= 1
        case .justRight:
            exercises[idx].consecutiveUse += 1
            if exercises[idx].consecutiveUse >= 3 { exercises[idx].reps += 1; exercises[idx].consecutiveUse = 0 }
        }
        exercises[idx].reps = max(exercises[idx].minReps, min(exercises[idx].maxReps, exercises[idx].reps))
    }

    private func updateOffDayExerciseDifficulty(rating: WorkoutRating) {
        guard let m = currentModule else { return }
        for id in m.completedExercises {
            guard let idx = exercises.firstIndex(where: { $0.id == id }) else { continue }
            switch rating {
            case .easy:
                exercises[idx].consecutiveOffDaySuccess += 1
                if exercises[idx].consecutiveOffDaySuccess >= 2, let off = exercises[idx].offDayReps, let base = exercises[idx].baseReps { exercises[idx].offDayReps = min(off + 1, base) }
            case .justRight:
                exercises[idx].consecutiveOffDaySuccess += 1
            case .hard:
                if let off = exercises[idx].offDayReps { exercises[idx].offDayReps = max(3, off - 1) }
                exercises[idx].consecutiveOffDaySuccess = 0
            }
        }
    }

    private func recoverSuppressedExercises() {
        let today = Date()
        for (idx, e) in exercises.enumerated() where e.isSuppressed {
            guard let until = e.suppressedUntil, today >= until else { continue }
            let used = countExercisesUsedInCategory(e.category, since: until)
            if used >= suppressionRecoveryThreshold {
                exercises[idx].isSuppressed = false
                exercises[idx].skipCount = 0
                exercises[idx].suppressedUntil = nil
            }
        }
        saveExercises()
    }

    private func countExercisesUsedInCategory(_ category: ExerciseCategory, since date: Date) -> Int {
        let items = exercises.filter { $0.category == category && !$0.isSuppressed }
        var used = Set<UUID>()
        for e in items {
            let recent = e.usageHistory.filter { $0.date > date && $0.completed }
            if !recent.isEmpty { used.insert(e.id) }
        }
        return used.count
    }

    private func checkOffDayRecovery() {
        guard userHealthState.isOffDay else { return }
        let last = moduleHistory.filter { $0.isOffDayModule }.suffix(2).compactMap { $0.rating }
        if last.count == 2, last.allSatisfy({ $0 == .easy || $0 == .justRight }) { confirmOffDayRecovery() }
    }

    func confirmOffDayRecovery() {
        for idx in 0..<exercises.count {
            if let base = exercises[idx].baseReps, let off = exercises[idx].offDayReps {
                exercises[idx].reps = (base + off) / 2
                exercises[idx].offDayReps = nil
            }
        }
        userHealthState.isOffDay = false
        userHealthState.offDayStartedAt = nil
        saveExercises()
        saveUserHealthState()
    }

    func resetAllExercises() {
        exercises = createDefaultExercises()
        moduleHistory = []
        currentModuleIndex = 0
        currentModule = nil
        currentSession = nil
        userHealthState = UserHealthState()
        saveExercises()
        saveModuleHistory()
        saveUserHealthState()
        UserDefaults.standard.set(0, forKey: "currentModuleIndex")
        UserDefaults.standard.removeObject(forKey: "currentSession")
    }
}

struct WorkoutStep {
    let title: String
    let youtubeURL: String?
    let duration: Int
    let isRest: Bool
}

class WorkoutAlgorithm {
    static func generateWorkout(from list: [WorkoutStep]) -> [WorkoutStep] {
        var selected: [WorkoutStep] = []
        let filtered = list.filter { !$0.isRest }
        let shuffled = filtered.shuffled()
        selected.append(shuffled[0])
        selected.append(WorkoutStep(title: "Rest", youtubeURL: nil, duration: 30, isRest: true))
        selected.append(shuffled[1])
        selected.append(WorkoutStep(title: "Rest", youtubeURL: nil, duration: 30, isRest: true))
        selected.append(shuffled[2])
        return selected
    }
}

