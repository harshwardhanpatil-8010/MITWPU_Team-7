import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    private let typesToRead: Set<HKQuantityType> = [
        .quantityType(forIdentifier: .walkingStepLength)!,
        .quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
        .quantityType(forIdentifier: .appleWalkingSteadiness)!,
        .quantityType(forIdentifier: .distanceWalkingRunning)!,
        .quantityType(forIdentifier: .stepCount)!
    ]
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, _ in
            completion(success)
        }
    }
    
//    func fetchFullSummary(for session: RhythmicSession, completion: @escaping (GaitSummary) -> Void) {
//        let predicate = HKQuery.predicateForSamples(withStart: session.startDate, end: session.endDate ?? Date(), options: .strictStartDate)
//        let group = DispatchGroup()
//        
//        var steps = 0
//        var distance = 0.0
//        var stepLen = 0.0
//        var asymmetry = 0.0
//        var steadiness = 0.0
//        
//        // 1. Total Steps
//        group.enter()
//        fetchSum(for: .stepCount, predicate: predicate, unit: .count()) { val in
//            steps = Int(val); group.leave()
//        }
//        
//        // 2. Total Distance
//        group.enter()
//        fetchSum(for: .distanceWalkingRunning, predicate: predicate, unit: .meter()) { val in
//            distance = val; group.leave()
//        }
//        
//        // 3. Avg Step Length
//        group.enter()
//        fetchAvg(for: .walkingStepLength, predicate: predicate, unit: .meter()) { val in
//            stepLen = val; group.leave()
//        }
//        
//        // 4. Avg Asymmetry
//        group.enter()
//        fetchAvg(for: .walkingAsymmetryPercentage, predicate: predicate, unit: .percent()) { val in
//            asymmetry = val * 100; group.leave()
//        }
//        
//        // 5. Avg Steadiness
//        group.enter()
//        fetchAvg(for: .appleWalkingSteadiness, predicate: predicate, unit: .percent()) { val in
//            steadiness = val * 100; group.leave()
//        }
//        
//        group.notify(queue: .main) {
//            // Calculate Speed: (km) / (hours)
//            let durationHours = Double(session.elapsedSeconds) / 3600.0
//            let speed = durationHours > 0 ? (distance / 1000.0) / durationHours : 0.0
//            
//            let summary = GaitSummary(
//                steps: steps,
//                distanceMeters: distance,
//                speedKmH: speed,
//                stepLengthMeters: stepLen,
//                walkingAsymmetryPercent: asymmetry,
//                walkingSteadiness: self.classifySteadiness(steadiness)
//            )
//            completion(summary)
//        }
//    }
    func fetchFullSummary(for session: RhythmicSession, completion: @escaping (GaitSummary) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: session.startDate, end: session.endDate ?? Date(), options: .strictStartDate)
        let group = DispatchGroup()
        
        var steps = 0
        var distance = 0.0
        var stepLen = 0.0
        var asymmetry = 0.0
        var steadiness = 0.0

        // 1. Fetch Steps (Cumulative Sum)
        group.enter()
        fetchSum(for: .stepCount, predicate: predicate, unit: .count()) { val in
            steps = Int(val)
            group.leave()
        }
        
        // 2. Fetch Distance (Cumulative Sum)
        group.enter()
        fetchSum(for: .distanceWalkingRunning, predicate: predicate, unit: .meter()) { val in
            distance = val
            group.leave()
        }
        
        // 3. Fetch Step Length (Average)
        group.enter()
        fetchAvg(for: .walkingStepLength, predicate: predicate, unit: .meter()) { val in
            stepLen = val
            group.leave()
        }
        
        // 4. Fetch Asymmetry (Average)
        group.enter()
        fetchAvg(for: .walkingAsymmetryPercentage, predicate: predicate, unit: .percent()) { val in
            asymmetry = val * 100 // Convert 0.01 to 1.0%
            group.leave()
        }
        
        // 5. Fetch Steadiness (Average)
        group.enter()
        fetchAvg(for: .appleWalkingSteadiness, predicate: predicate, unit: .percent()) { val in
            steadiness = val * 100
            group.leave()
        }

        group.notify(queue: .main) {
            let durationHours = Double(session.elapsedSeconds) / 3600.0
            let calculatedSpeed = durationHours > 0 ? (distance / 1000.0) / durationHours : 0.0
            
            let summary = GaitSummary(
                steps: steps,
                distanceMeters: distance,
                speedKmH: calculatedSpeed,
                stepLengthMeters: stepLen,
                walkingAsymmetryPercent: asymmetry,
                walkingSteadiness: self.classifySteadiness(steadiness)
            )
            completion(summary)
        }
    }
    
    private func fetchSum(for id: HKQuantityTypeIdentifier, predicate: NSPredicate, unit: HKUnit, completion: @escaping (Double) -> Void) {
        let query = HKStatisticsQuery(quantityType: .quantityType(forIdentifier: id)!, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
            completion(stats?.sumQuantity()?.doubleValue(for: unit) ?? 0.0)
        }
        healthStore.execute(query)
    }
    
    private func fetchAvg(for id: HKQuantityTypeIdentifier, predicate: NSPredicate, unit: HKUnit, completion: @escaping (Double) -> Void) {
        let query = HKStatisticsQuery(quantityType: .quantityType(forIdentifier: id)!, quantitySamplePredicate: predicate, options: .discreteAverage) { _, stats, _ in
            completion(stats?.averageQuantity()?.doubleValue(for: unit) ?? 0.0)
        }
        healthStore.execute(query)
    }
    
    private func classifySteadiness(_ value: Double) -> String {
        if value >= 67 { return "OK" }
        if value >= 45 { return "Low" }
        return "Very Low"
    }
}
