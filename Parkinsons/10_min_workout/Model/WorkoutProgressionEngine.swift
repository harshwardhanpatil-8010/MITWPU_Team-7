import Foundation

enum WorkoutPhase {
    case main
    case revisiting
    case completed
}

class WorkoutProgressionEngine {
    private(set) var allExercises: [WorkoutExercise]
    
    // The exact sequence of exercise indices we are currently working through
    private(set) var activeQueue: [Int] = []
    
    // The strict linear pointer within `activeQueue`
    private(set) var queuePointer: Int = 0
    
    private(set) var phase: WorkoutPhase = .main
    
    // Start a new session from the landing page. It resumes where the user left off.
    init(exercises: [WorkoutExercise]) {
        self.allExercises = exercises
        self.activeQueue = Array(0..<exercises.count)
        self.queuePointer = 0
        
        let completed = Set(WorkoutManager.shared.completedToday)
        let skipped = Set(WorkoutManager.shared.skippedToday)
        
        // Fast-forward only on initial setup to find where they left off.
        if let firstPending = activeQueue.firstIndex(where: { 
            let id = exercises[$0].id
            return !completed.contains(id) && !skipped.contains(id)
        }) {
            self.queuePointer = firstPending
        } else {
            // All were completed or skipped. See if we should jump to revisiting.
            checkAndTransitionPhaseIfNeeded()
        }
    }
    
    // Force start a revisit phase directly (used from landing page if only skipped remain)
    init(exercises: [WorkoutExercise], forceRevisitIndices: [Int]) {
        self.allExercises = exercises
        self.activeQueue = forceRevisitIndices
        self.queuePointer = 0
        self.phase = .revisiting
    }
    
    var currentExercise: WorkoutExercise? {
        guard queuePointer >= 0 && queuePointer < activeQueue.count else { return nil }
        return allExercises[activeQueue[queuePointer]]
    }
    
    var currentIndexInGlobalArray: Int {
        guard queuePointer >= 0 && queuePointer < activeQueue.count else { return allExercises.count }
        return activeQueue[queuePointer]
    }
    
    var canGoPrevious: Bool {
        return queuePointer > 0
    }
    
    func goPrevious() {
        guard canGoPrevious else { return }
        queuePointer -= 1
    }
    
    func markCurrent(skipped: Bool) {
        guard let current = currentExercise else { return }
        
        // Mutate global state securely
        if skipped {
            if !WorkoutManager.shared.skippedToday.contains(current.id) {
                WorkoutManager.shared.skippedToday.append(current.id)
            }
            WorkoutManager.shared.completedToday.removeAll { $0 == current.id }
        } else {
            if !WorkoutManager.shared.completedToday.contains(current.id) {
                WorkoutManager.shared.completedToday.append(current.id)
            }
            WorkoutManager.shared.skippedToday.removeAll { $0 == current.id }
        }
        WorkoutManager.shared.syncSessionPersistence()
        
        // Deterministically advance the local pointer.
        queuePointer += 1
        
        // Skip over any exercises that are already completed when advancing forward
        let completed = Set(WorkoutManager.shared.completedToday)
        while queuePointer < activeQueue.count {
            let nextGlobalIndex = activeQueue[queuePointer]
            let nextID = allExercises[nextGlobalIndex].id
            if completed.contains(nextID) {
                queuePointer += 1
            } else {
                break
            }
        }
        checkAndTransitionPhaseIfNeeded()
    }
    
    private func checkAndTransitionPhaseIfNeeded() {
        if queuePointer >= activeQueue.count {
            if phase == .main {
                // Evaluated once we hit the end of the main queue
                let completed = Set(WorkoutManager.shared.completedToday)
                let unresolvedSkipped = allExercises.enumerated().compactMap { (index, ex) -> Int? in
                    if WorkoutManager.shared.skippedToday.contains(ex.id) && !completed.contains(ex.id) {
                        return index
                    }
                    return nil
                }
                
                if !unresolvedSkipped.isEmpty {
                    self.activeQueue = unresolvedSkipped
                    self.queuePointer = 0
                    self.phase = .revisiting
                } else {
                    self.phase = .completed
                }
            } else if phase == .revisiting {
                self.phase = .completed
            }
        }
    }
    
    func quitEarlyAndModifyRemaining() {
        // Used when user taps "Physical Pain / Fatigue"
        guard phase == .main else { return }
        
        for i in queuePointer..<activeQueue.count {
            let globalIndex = activeQueue[i]
            let cat = allExercises[globalIndex].category
            if cat == .warmup || cat == .cooldown {
                allExercises[globalIndex].duration = 50
                if let mi = WorkoutManager.shared.exercises.firstIndex(where: { $0.id == allExercises[globalIndex].id }) {
                    WorkoutManager.shared.exercises[mi].duration = 50
                }
            } else {
                allExercises[globalIndex].reps = 6
                if let mi = WorkoutManager.shared.exercises.firstIndex(where: { $0.id == allExercises[globalIndex].id }) {
                    WorkoutManager.shared.exercises[mi].reps = 6
                }
            }
        }
        WorkoutManager.shared.syncSessionPersistence()
        self.phase = .completed
    }
    
    func forceComplete() {
        self.phase = .completed
    }
}
