
import HealthKit
import CoreData

final class HealthKitManagerRhythmic {

    static let shared = HealthKitManagerRhythmic()
    let healthStore = HKHealthStore()
    private let typesToRead: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!,
        HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
        HKQuantityType.quantityType(forIdentifier: .appleWalkingSteadiness)!,
        HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!          // NEW
    ]

    private init() {}
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
    func checkAuthorizationStatus() {
        let ids: [HKQuantityTypeIdentifier] = [
            .stepCount, .distanceWalkingRunning, .walkingStepLength,
            .walkingAsymmetryPercentage, .appleWalkingSteadiness, .walkingSpeed
        ]
        for id in ids {
            let type   = HKQuantityType.quantityType(forIdentifier: id)!
            let status = healthStore.authorizationStatus(for: type)
            print("[HealthKit] \(id.rawValue): \(status.rawValue)")
        }
    }

    func fetchFullSummary(for session: RhythmicSessionDTO,
                          bufferSeconds: TimeInterval = 300,
                          completion: @escaping (GaitSummary) -> Void) {

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
        let predicate = HKQuery.predicateForSamples(
            withStart: start, end: end, options: .strictStartDate
        )

        print("[HealthKit] Fetching window: \(start) → \(end)")
        checkAuthorizationStatus()

        let group  = DispatchGroup()
        var steps      = 0
        var distance   = 0.0
        var stepLen    = 0.0
        var asymmetry  = 0.0
        var steadiness = 0.0
        var speedMS    = 0.0

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
        fetchAvg(.walkingAsymmetryPercentage, predicate: predicate, unit: .percent()) { val in
            asymmetry = val * 100; group.leave()
        }

        group.enter()
        fetchAvg(.appleWalkingSteadiness, predicate: predicate, unit: .percent()) { val in
            steadiness = val * 100; group.leave()
        }

        group.enter()
        fetchAvg(.walkingSpeed, predicate: predicate,
                 unit: HKUnit.meter().unitDivided(by: .second())) { val in
            speedMS = val; group.leave()
        }

        group.notify(queue: .main) {
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
