////import HealthKit
//////
////class HealthKitManager {
////    static let shared = HealthKitManager()
////    let healthStore = HKHealthStore()
////    
////    private let typesToRead: Set<HKQuantityType> = [
////        .quantityType(forIdentifier: .walkingStepLength)!,
////        .quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
////        .quantityType(forIdentifier: .appleWalkingSteadiness)!,
////        .quantityType(forIdentifier: .distanceWalkingRunning)!,
////        .quantityType(forIdentifier: .stepCount)!
////    ]
////    
////    func requestAuthorization(completion: @escaping (Bool) -> Void) {
////        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, _ in
////            completion(success)
////        }
////    }
////    
//////    func fetchFullSummary(for session: RhythmicSession, completion: @escaping (GaitSummary) -> Void) {
//////        let predicate = HKQuery.predicateForSamples(withStart: session.startDate, end: session.endDate ?? Date(), options: .strictStartDate)
//////        let group = DispatchGroup()
//////        
//////        var steps = 0
//////        var distance = 0.0
//////        var stepLen = 0.0
//////        var asymmetry = 0.0
//////        var steadiness = 0.0
//////        
//////        // 1. Total Steps
//////        group.enter()
//////        fetchSum(for: .stepCount, predicate: predicate, unit: .count()) { val in
//////            steps = Int(val); group.leave()
//////        }
//////        
//////        // 2. Total Distance
//////        group.enter()
//////        fetchSum(for: .distanceWalkingRunning, predicate: predicate, unit: .meter()) { val in
//////            distance = val; group.leave()
//////        }
//////        
//////        // 3. Avg Step Length
//////        group.enter()
//////        fetchAvg(for: .walkingStepLength, predicate: predicate, unit: .meter()) { val in
//////            stepLen = val; group.leave()
//////        }
//////        
//////        // 4. Avg Asymmetry
//////        group.enter()
//////        fetchAvg(for: .walkingAsymmetryPercentage, predicate: predicate, unit: .percent()) { val in
//////            asymmetry = val * 100; group.leave()
//////        }
//////        
//////        // 5. Avg Steadiness
//////        group.enter()
//////        fetchAvg(for: .appleWalkingSteadiness, predicate: predicate, unit: .percent()) { val in
//////            steadiness = val * 100; group.leave()
//////        }
//////        
//////        group.notify(queue: .main) {
//////            // Calculate Speed: (km) / (hours)
//////            let durationHours = Double(session.elapsedSeconds) / 3600.0
//////            let speed = durationHours > 0 ? (distance / 1000.0) / durationHours : 0.0
//////            
//////            let summary = GaitSummary(
//////                steps: steps,
//////                distanceMeters: distance,
//////                speedKmH: speed,
//////                stepLengthMeters: stepLen,
//////                walkingAsymmetryPercent: asymmetry,
//////                walkingSteadiness: self.classifySteadiness(steadiness)
//////            )
//////            completion(summary)
//////        }
//////    }
////    func fetchFullSummary(for session: RhythmicSession, completion: @escaping (GaitSummary) -> Void) {
////        let predicate = HKQuery.predicateForSamples(withStart: session.startDate, end: session.endDate ?? Date(), options: .strictStartDate)
////        let group = DispatchGroup()
////        
////        var steps = 0
////        var distance = 0.0
////        var stepLen = 0.0
////        var asymmetry = 0.0
////        var steadiness = 0.0
////
////        // 1. Fetch Steps (Cumulative Sum)
////        group.enter()
////        fetchSum(for: .stepCount, predicate: predicate, unit: .count()) { val in
////            steps = Int(val)
////            group.leave()
////        }
////        
////        // 2. Fetch Distance (Cumulative Sum)
////        group.enter()
////        fetchSum(for: .distanceWalkingRunning, predicate: predicate, unit: .meter()) { val in
////            distance = val
////            group.leave()
////        }
////        
////        // 3. Fetch Step Length (Average)
////        group.enter()
////        fetchAvg(for: .walkingStepLength, predicate: predicate, unit: .meter()) { val in
////            stepLen = val
////            group.leave()
////        }
////        
////        // 4. Fetch Asymmetry (Average)
////        group.enter()
////        fetchAvg(for: .walkingAsymmetryPercentage, predicate: predicate, unit: .percent()) { val in
////            asymmetry = val * 100 // Convert 0.01 to 1.0%
////            group.leave()
////        }
////        
////        // 5. Fetch Steadiness (Average)
////        group.enter()
////        fetchAvg(for: .appleWalkingSteadiness, predicate: predicate, unit: .percent()) { val in
////            steadiness = val * 100
////            group.leave()
////        }
////
////        group.notify(queue: .main) {
////            let durationHours = Double(session.elapsedSeconds) / 3600.0
////            let calculatedSpeed = durationHours > 0 ? (distance / 1000.0) / durationHours : 0.0
////            
////            let summary = GaitSummary(
////                steps: steps,
////                distanceMeters: distance,
////                speedKmH: calculatedSpeed,
////                stepLengthMeters: stepLen,
////                walkingAsymmetryPercent: asymmetry,
////                walkingSteadiness: self.classifySteadiness(steadiness)
////            )
////            completion(summary)
////        }
////    }
////    
////    private func fetchSum(for id: HKQuantityTypeIdentifier, predicate: NSPredicate, unit: HKUnit, completion: @escaping (Double) -> Void) {
////        let query = HKStatisticsQuery(quantityType: .quantityType(forIdentifier: id)!, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
////            completion(stats?.sumQuantity()?.doubleValue(for: unit) ?? 0.0)
////        }
////        healthStore.execute(query)
////    }
////    
////    private func fetchAvg(for id: HKQuantityTypeIdentifier, predicate: NSPredicate, unit: HKUnit, completion: @escaping (Double) -> Void) {
////        let query = HKStatisticsQuery(quantityType: .quantityType(forIdentifier: id)!, quantitySamplePredicate: predicate, options: .discreteAverage) { _, stats, _ in
////            completion(stats?.averageQuantity()?.doubleValue(for: unit) ?? 0.0)
////        }
////        healthStore.execute(query)
////    }
////    
////    private func classifySteadiness(_ value: Double) -> String {
////        if value >= 67 { return "OK" }
////        if value >= 45 { return "Low" }
////        return "Very Low"
////    }
////}
////
//////import HealthKit
//////
//////final class HealthKitManager {
//////
//////    static let shared = HealthKitManager()
//////    private let healthStore = HKHealthStore()
//////
//////    private init() {}
//////}
//////extension HealthKitManager {
//////
//////    var stepCountType: HKQuantityType {
//////        HKQuantityType.quantityType(forIdentifier: .stepCount)!
//////    }
//////
//////    var distanceType: HKQuantityType {
//////        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
//////    }
//////
//////    var stepLengthType: HKQuantityType {
//////        HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!
//////    }
//////
//////    var asymmetryType: HKQuantityType {
//////        HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!
//////    }
//////
//////    var steadinessType: HKQuantityType {
//////        HKQuantityType.quantityType(forIdentifier: .walkingSteadiness)!
//////    }
//////    
//////    private func fetchSumQuantity(
//////        type: HKQuantityType,
//////        unit: HKUnit,
//////        startDate: Date,
//////        endDate: Date,
//////        completion: @escaping (Double) -> Void
//////    ) {
//////
//////        let predicate = HKQuery.predicateForSamples(
//////            withStart: startDate,
//////            end: endDate,
//////            options: .strictStartDate
//////        )
//////
//////        let query = HKStatisticsQuery(
//////            quantityType: type,
//////            quantitySamplePredicate: predicate,
//////            options: .cumulativeSum
//////        ) { _, result, _ in
//////            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
//////            completion(value)
//////        }
//////
//////        healthStore.execute(query)
//////    }
//////    private func fetchAverageQuantity(
//////        type: HKQuantityType,
//////        unit: HKUnit,
//////        startDate: Date,
//////        endDate: Date,
//////        completion: @escaping (Double) -> Void
//////    ) {
//////
//////        let predicate = HKQuery.predicateForSamples(
//////            withStart: startDate,
//////            end: endDate,
//////            options: .strictStartDate
//////        )
//////
//////        let query = HKStatisticsQuery(
//////            quantityType: type,
//////            quantitySamplePredicate: predicate,
//////            options: .discreteAverage
//////        ) { _, result, _ in
//////            let value = result?.averageQuantity()?.doubleValue(for: unit) ?? 0
//////            completion(value)
//////        }
//////
//////        healthStore.execute(query)
//////    }
//////
//////}
//////
//////extension HealthKitManager {
//////
//////    func buildRhythmicSession(
//////        startDate: Date,
//////        endDate: Date,
//////        completion: @escaping (RhythmicSessionBuilder) -> Void
//////    ) {
//////
//////        var builder = RhythmicSessionBuilder(
//////            startDate: startDate,
//////            endDate: endDate
//////        )
//////
//////        let group = DispatchGroup()
//////
//////        // Steps
//////        group.enter()
//////        fetchSumQuantity(
//////            type: stepCountType,
//////            unit: .count(),
//////            startDate: startDate,
//////            endDate: endDate
//////        ) { value in
//////            builder.steps = Int(value)
//////            group.leave()
//////        }
//////
//////        // Distance
//////        group.enter()
//////        fetchSumQuantity(
//////            type: distanceType,
//////            unit: .meter(),
//////            startDate: startDate,
//////            endDate: endDate
//////        ) { value in
//////            builder.distanceMeters = value
//////            group.leave()
//////        }
//////
//////        // Step Length
//////        group.enter()
//////        fetchAverageQuantity(
//////            type: stepLengthType,
//////            unit: .meter(),
//////            startDate: startDate,
//////            endDate: endDate
//////        ) { value in
//////            builder.stepLengthMeters = value
//////            group.leave()
//////        }
//////
//////        // Asymmetry
//////        group.enter()
//////        fetchAverageQuantity(
//////            type: asymmetryType,
//////            unit: .percent(),
//////            startDate: startDate,
//////            endDate: endDate
//////        ) { value in
//////            builder.walkingAsymmetry = value
//////            group.leave()
//////        }
//////
//////        // Steadiness
//////        group.enter()
//////        fetchAverageQuantity(
//////            type: steadinessType,
//////            unit: .count(),
//////            startDate: startDate,
//////            endDate: endDate
//////        ) { value in
//////            builder.walkingSteadiness = value
//////            group.leave()
//////        }
//////
//////        group.notify(queue: .main) {
//////            completion(builder)
//////        }
//////    }
//////}
//
//import HealthKit
//import CoreData
//
//class HealthKitManagerRhythmic {
//    static let shared = HealthKitManagerRhythmic()
//    let healthStore = HKHealthStore()
//    
//    private let typesToRead: Set<HKQuantityType> = [
//        .quantityType(forIdentifier: .walkingStepLength)!,
//        .quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
//        .quantityType(forIdentifier: .appleWalkingSteadiness)!,
//        .quantityType(forIdentifier: .distanceWalkingRunning)!,
//        .quantityType(forIdentifier: .stepCount)!
//    ]
//    
//    func requestAuthorization(completion: @escaping (Bool) -> Void) {
//        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
//            print("HealthKit auth success: \(success), error: \(String(describing: error))")
//            completion(success)
//        }
//    }
//    
//    
//    func checkAuthorizationStatus() {
//        let types: [HKQuantityTypeIdentifier] = [
//            .stepCount,
//            .distanceWalkingRunning,
//            .walkingStepLength,
//            .walkingAsymmetryPercentage,
//            .appleWalkingSteadiness
//        ]
//        for id in types {
//            let type = HKQuantityType.quantityType(forIdentifier: id)!
//            let status = healthStore.authorizationStatus(for: type)
//            print("Auth status for \(id.rawValue): \(status.rawValue)")
//            // 0 = notDetermined, 1 = sharingDenied, 2 = sharingAuthorized
//        }
//    }
//    
//    func fetchFullSummary(for session: RhythmicSessionDTO, completion: @escaping (GaitSummary) -> Void) {
//        let endDate = session.endDate ?? session.startDate.addingTimeInterval(TimeInterval(session.elapsedSeconds))
//        
//        let startWithBuffer = session.startDate.addingTimeInterval(-60)
//        let endWithBuffer = endDate.addingTimeInterval(60)
//        
//        // Loose predicate for cumulative types (steps, distance)
//        let loosePredicate = HKQuery.predicateForSamples(
//            withStart: startWithBuffer,
//            end: endWithBuffer,
//            options: []
//        )
//        // Strict predicate for average types (step length, asymmetry, steadiness)
//        let strictPredicate = HKQuery.predicateForSamples(
//            withStart: startWithBuffer,
//            end: endWithBuffer,
//            options: .strictStartDate
//        )
//        
//        print("=== HealthKit Fetch ===")
//        print("  Start: \(startWithBuffer)")
//        print("  End:   \(endWithBuffer)")
//        
//        let group = DispatchGroup()
//        var steps = 0, distance = 0.0, stepLen = 0.0, asymmetry = 0.0, steadiness = 0.0
//        
//        group.enter()
//        fetchSum(for: .stepCount, predicate: loosePredicate, unit: .count()) { val in
//            steps = Int(val); group.leave()
//        }
//        
//        group.enter()
//        fetchSum(for: .distanceWalkingRunning, predicate: loosePredicate, unit: .meter()) { val in
//            distance = val; group.leave()
//        }
//        
//        group.enter()
//        fetchAvg(for: .walkingStepLength, predicate: strictPredicate, unit: .meter()) { val in
//            stepLen = val; group.leave()
//        }
//        
//        group.enter()
//        fetchAvg(for: .walkingAsymmetryPercentage, predicate: strictPredicate, unit: .percent()) { val in
//            asymmetry = val * 100; group.leave()
//        }
//        
//        group.enter()
//        fetchAvg(for: .appleWalkingSteadiness, predicate: strictPredicate, unit: .percent()) { val in
//            steadiness = val * 100; group.leave()
//        }
//        
//        group.notify(queue: .main) {
//            print("=== HealthKit Results ===")
//            print("  Steps: \(steps), Distance: \(distance)m, StepLen: \(stepLen)m")
//            print("  Asymmetry: \(asymmetry)%, Steadiness: \(steadiness)%")
//            
//            let durationHours = Double(session.elapsedSeconds) / 3600.0
//            let speed = durationHours > 0 ? (distance / 1000.0) / durationHours : 0.0
//            
//            self.saveHealthKitData(
//                for: session.id, steps: steps, distanceMeters: distance,
//                stepLengthMeters: stepLen, walkingAsymmetry: asymmetry, walkingSteadiness: steadiness
//            )
//            
//            completion(GaitSummary(
//                steps: steps,
//                distanceMeters: distance,
//                speedKmH: speed,
//                stepLengthMeters: stepLen,
//                walkingAsymmetryPercent: asymmetry,
//                walkingSteadiness: self.classifySteadiness(steadiness)
//            ))
//        }
//    }
//    
//    private func saveHealthKitData(
//        for sessionID: UUID,
//        steps: Int,
//        distanceMeters: Double,
//        stepLengthMeters: Double,
//        walkingAsymmetry: Double,
//        walkingSteadiness: Double
//    ) {
//        let context = PersistenceController.shared.viewContext
//        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %@", sessionID as CVarArg)
//        guard let managed = try? context.fetch(request).first else {
//            print("⚠️ saveHealthKitData: no Core Data record found for \(sessionID)")
//            return
//        }
//        managed.steps             = Int32(steps)
//        managed.distanceMeters    = distanceMeters
//        managed.stepLengthMeters  = stepLengthMeters
//        managed.walkingAsymmetry  = walkingAsymmetry
//        managed.walkingSteadiness = walkingSteadiness
//        PersistenceController.shared.save()
//        print("✅ HealthKit data saved to Core Data")
//    }
//    
//    private func fetchSum(for id: HKQuantityTypeIdentifier, predicate: NSPredicate, unit: HKUnit, completion: @escaping (Double) -> Void) {
//        let query = HKStatisticsQuery(
//            quantityType: .quantityType(forIdentifier: id)!,
//            quantitySamplePredicate: predicate,
//            options: .cumulativeSum
//        ) { _, stats, error in
//            if let error = error { print("fetchSum error (\(id)): \(error)") }
//            completion(stats?.sumQuantity()?.doubleValue(for: unit) ?? 0.0)
//        }
//        healthStore.execute(query)
//    }
//    
//    private func fetchAvg(for id: HKQuantityTypeIdentifier, predicate: NSPredicate, unit: HKUnit, completion: @escaping (Double) -> Void) {
//        let query = HKStatisticsQuery(
//            quantityType: .quantityType(forIdentifier: id)!,
//            quantitySamplePredicate: predicate,
//            options: .discreteAverage
//        ) { _, stats, error in
//            if let error = error { print("fetchAvg error (\(id)): \(error)") }
//            completion(stats?.averageQuantity()?.doubleValue(for: unit) ?? 0.0)
//        }
//        healthStore.execute(query)
//    }
//    
//    private func classifySteadiness(_ value: Double) -> String {
//        if value >= 67 { return "OK" }
//        if value >= 45 { return "Low" }
//        return "Very Low"
//    }
//}



//
//  HealthKitManagerRhythmic.swift
//  Parkinsons
//
//  WHY HEALTHKIT DATA WAS RETURNING ZEROS — AND THE FIXES:
//  --------------------------------------------------------
//  1. TIME WINDOW TOO TIGHT / WRONG
//     session.startDate is the moment the Core Data record was CREATED, not
//     when the user physically started walking. Apple's pedometer pipeline
//     also writes samples slightly AFTER the motion occurs (sometimes 1–2 min
//     delay on device). Fix: expand the window by ±5 min on both sides.
//
//  2. .strictStartDate + .strictEndDate REJECTED EDGE SAMPLES
//     Pedometer samples that span the boundary are excluded entirely.
//     Fix: use no options ([] / .strictStartDate only) so samples that
//     overlap the window are included.
//
//  3. walkingAsymmetryPercentage & appleWalkingSteadiness ARE WRITTEN
//     BY APPLE'S OWN PIPELINE — they appear in HealthKit with a DELAY
//     (typically 1–10 minutes after the walk). fetchFullSummary now has
//     an optional `delay` parameter so the SummaryVC can re-fetch after
//     a short wait if values are still zero.
//
//  4. AUTHORIZATION must include .walkingSpeed (added to typesToRead)
//     which improves speed accuracy.
//
//  5. Added checkAuthorizationStatus() so you can log exactly which
//     types are denied at runtime.

import HealthKit
import CoreData

final class HealthKitManagerRhythmic {

    static let shared = HealthKitManagerRhythmic()
    private let healthStore = HKHealthStore()

    // Extra read types — expand this set if you add more metrics later
    private let typesToRead: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!,
        HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
        HKQuantityType.quantityType(forIdentifier: .appleWalkingSteadiness)!,
        HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!          // NEW
    ]

    private init() {}

    // MARK: - Authorization
    // Call ONCE from AppDelegate.application(_:didFinishLaunchingWithOptions:)

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("[HealthKit] Not available on this device.")
            completion(false)
            return
        }
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error { print("[HealthKit] Auth error: \(error)") }
            print("[HealthKit] Authorization granted: \(success)")
            DispatchQueue.main.async { completion(success) }
        }
    }

    /// Logs the current permission status for every type — useful for debugging "No data"
    func checkAuthorizationStatus() {
        let ids: [HKQuantityTypeIdentifier] = [
            .stepCount, .distanceWalkingRunning, .walkingStepLength,
            .walkingAsymmetryPercentage, .appleWalkingSteadiness, .walkingSpeed
        ]
        for id in ids {
            let type   = HKQuantityType.quantityType(forIdentifier: id)!
            let status = healthStore.authorizationStatus(for: type)
            // 0=notDetermined  1=denied  2=authorized
            print("[HealthKit] \(id.rawValue): \(status.rawValue)")
        }
    }

    // MARK: - Fetch full walking summary for a session

    /// - Parameters:
    ///   - session: The finished session DTO.
    ///   - bufferSeconds: Extra seconds added to BOTH ends of the time window
    ///     (default 300 = 5 min). Needed because Apple's motion pipeline writes
    ///     samples with a 1–3 min lag and step samples often straddle the boundary.
    func fetchFullSummary(for session: RhythmicSessionDTO,
                          bufferSeconds: TimeInterval = 300,
                          completion: @escaping (GaitSummary) -> Void) {

        // Build time window: session bounds ± buffer
        let rawStart = session.startDate
        let rawEnd   = session.endDate
                       ?? session.startDate.addingTimeInterval(TimeInterval(session.elapsedSeconds))

        guard rawEnd > rawStart else {
            print("[HealthKit] ⚠️ Invalid time window: start=\(rawStart) end=\(rawEnd)")
            DispatchQueue.main.async { completion(self.emptyGaitSummary()) }
            return
        }

        let start = rawStart.addingTimeInterval(-bufferSeconds)
        let end   = rawEnd.addingTimeInterval(bufferSeconds)

        // FIX: use .strictStartDate only (not strictEndDate) so samples that
        // overlap the end boundary are still counted.
        let predicate = HKQuery.predicateForSamples(
            withStart: start, end: end, options: .strictStartDate
        )

        print("[HealthKit] Fetching window: \(start) → \(end)")
        checkAuthorizationStatus()   // print auth state every fetch (remove in prod)

        let group  = DispatchGroup()
        var steps      = 0
        var distance   = 0.0
        var stepLen    = 0.0
        var asymmetry  = 0.0
        var steadiness = 0.0
        var speedMS    = 0.0   // m/s from HealthKit walkingSpeed type

        group.enter()
        fetchSum(.stepCount, predicate: predicate, unit: .count()) { val in
            steps = Int(val); group.leave()
        }

        group.enter()
        fetchSum(.distanceWalkingRunning, predicate: predicate, unit: .meter()) { val in
            distance = val; group.leave()
        }

        group.enter()
        fetchAvg(.walkingStepLength, predicate: predicate, unit: .meter()) { val in
            stepLen = val; group.leave()
        }

        group.enter()
        // walkingAsymmetryPercentage: HealthKit stores as 0.0–1.0
        fetchAvg(.walkingAsymmetryPercentage, predicate: predicate, unit: .percent()) { val in
            asymmetry = val * 100; group.leave()
        }

        group.enter()
        // appleWalkingSteadiness: HealthKit stores as 0.0–1.0
        fetchAvg(.appleWalkingSteadiness, predicate: predicate, unit: .percent()) { val in
            steadiness = val * 100; group.leave()
        }

        group.enter()
        fetchAvg(.walkingSpeed, predicate: predicate,
                 unit: HKUnit.meter().unitDivided(by: .second())) { val in
            speedMS = val; group.leave()
        }

        group.notify(queue: .main) {
            // Prefer HealthKit's measured speed; fall back to distance/time calculation
            let durationHours = Double(session.elapsedSeconds) / 3600.0
            let calculatedSpeedKmH = durationHours > 0 ? (distance / 1000.0) / durationHours : 0.0
            let speedKmH = speedMS > 0 ? speedMS * 3.6 : calculatedSpeedKmH

            print("[HealthKit] ✅ steps:\(steps) dist:\(String(format:"%.1f",distance))m "
                  + "stepLen:\(String(format:"%.2f",stepLen))m "
                  + "asym:\(String(format:"%.1f",asymmetry))% "
                  + "steady:\(String(format:"%.1f",steadiness))% "
                  + "speed:\(String(format:"%.2f",speedKmH))km/h")

            if steps == 0 && distance == 0 {
                print("[HealthKit] ⚠️ All zero — check: (a) HealthKit permission granted, "
                      + "(b) device was in pocket while walking (not held), "
                      + "(c) at least ~30 steps were taken, "
                      + "(d) not Simulator (no motion data).")
            }

            // Persist HealthKit data back into Core Data for history display
            self.saveToStore(sessionID: session.id,
                             steps: steps, distanceMeters: distance,
                             stepLengthMeters: stepLen,
                             walkingAsymmetry: asymmetry,
                             walkingSteadiness: steadiness)

            completion(GaitSummary(
                steps: steps,
                distanceMeters: distance,
                speedKmH: speedKmH,
                stepLengthMeters: stepLen,
                walkingAsymmetryPercent: asymmetry,
                walkingSteadiness: self.classifySteadiness(steadiness)
            ))
        }
    }

    // MARK: - Private fetch helpers

    private func fetchSum(_ id: HKQuantityTypeIdentifier,
                          predicate: NSPredicate,
                          unit: HKUnit,
                          completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else {
            completion(0); return
        }
        let q = HKStatisticsQuery(quantityType: type,
                                  quantitySamplePredicate: predicate,
                                  options: .cumulativeSum) { _, stats, error in
            if let error = error { print("[HealthKit] fetchSum \(id.rawValue): \(error)") }
            completion(stats?.sumQuantity()?.doubleValue(for: unit) ?? 0.0)
        }
        healthStore.execute(q)
    }

    private func fetchAvg(_ id: HKQuantityTypeIdentifier,
                          predicate: NSPredicate,
                          unit: HKUnit,
                          completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else {
            completion(0); return
        }
        let q = HKStatisticsQuery(quantityType: type,
                                  quantitySamplePredicate: predicate,
                                  options: .discreteAverage) { _, stats, error in
            if let error = error { print("[HealthKit] fetchAvg \(id.rawValue): \(error)") }
            completion(stats?.averageQuantity()?.doubleValue(for: unit) ?? 0.0)
        }
        healthStore.execute(q)
    }

    // MARK: - Persist to Core Data

    private func saveToStore(sessionID: UUID,
                             steps: Int, distanceMeters: Double,
                             stepLengthMeters: Double,
                             walkingAsymmetry: Double,
                             walkingSteadiness: Double) {
        let ctx     = PersistenceController.shared.viewContext
        let request = RhythmicSession.fetchRequest() as NSFetchRequest<RhythmicSession>
        request.predicate = NSPredicate(format: "id == %@", sessionID as CVarArg)
        guard let managed = try? ctx.fetch(request).first else {
            print("[HealthKit] ⚠️ saveToStore: no Core Data record for \(sessionID)")
            return
        }
        managed.steps             = Int32(steps)
        managed.distanceMeters    = distanceMeters
        managed.stepLengthMeters  = stepLengthMeters
        managed.walkingAsymmetry  = walkingAsymmetry
        managed.walkingSteadiness = walkingSteadiness
        PersistenceController.shared.save()
        print("[HealthKit] ✅ Saved to Core Data")
    }

    // MARK: - Helpers

    private func classifySteadiness(_ value: Double) -> String {
        if value >= 67 { return "OK" }
        if value >= 45 { return "Low" }
        return "Very Low"
    }

    private func emptyGaitSummary() -> GaitSummary {
        GaitSummary(steps: 0, distanceMeters: 0, speedKmH: 0,
                    stepLengthMeters: 0, walkingAsymmetryPercent: 0,
                    walkingSteadiness: "No data")
    }
}
