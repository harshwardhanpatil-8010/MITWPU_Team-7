//  HealthKitManager.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/01/26.
//

import Foundation
import HealthKit

final class HealthKitManager {

    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    private init() {}
}

// MARK: - HealthKit Types
extension HealthKitManager {

    var gaitTypes: Set<HKObjectType> {
        return [
            HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!,
            HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!
        ]
    }
}

// MARK: - Authorization
extension HealthKitManager {

    func requestAuthorization(completion: @escaping (Bool) -> Void) {

        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        healthStore.requestAuthorization(
            toShare: [],
            read: gaitTypes
        ) { success, error in
            if let error = error {
                print("HealthKit auth error:", error.localizedDescription)
            }
            completion(success)
        }
    }
}

// MARK: - Fetching Gait Data
extension HealthKitManager {

    func fetchWalkingSpeed(
        from startDate: Date,
        to endDate: Date,
        completion: @escaping ([Double]) -> Void
    ) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .walkingSpeed) else {
            completion([])
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in

            if let error = error {
                print("❌ Walking speed fetch error:", error.localizedDescription)
                completion([])
                return
            }

            let speeds = (samples as? [HKQuantitySample])?.map {
                $0.quantity.doubleValue(for: .meter().unitDivided(by: .second()))
            } ?? []

            completion(speeds)
        }

        healthStore.execute(query)
    }

    func fetchStepLength(
        from startDate: Date,
        to endDate: Date,
        completion: @escaping ([Double]) -> Void
    ) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .walkingStepLength) else {
            completion([])
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in

            if let error = error {
                print("❌ Step length fetch error:", error.localizedDescription)
                completion([])
                return
            }

            let values = (samples as? [HKQuantitySample])?.map {
                $0.quantity.doubleValue(for: .meter()) // meters
            } ?? []

            completion(values)
        }

        healthStore.execute(query)
    }
}

// MARK: - Walking Steadiness Calculation
extension HealthKitManager {

    func calculateWalkingSteadiness(speedValues: [Double], stepLengthValues: [Double]) -> Double? {
        guard !speedValues.isEmpty, !stepLengthValues.isEmpty else { return nil }

        // 1️⃣ Compute mean
        let speedMean = speedValues.reduce(0, +) / Double(speedValues.count)
        let stepMean = stepLengthValues.reduce(0, +) / Double(stepLengthValues.count)

        // 2️⃣ Compute standard deviation
        let speedStd = standardDeviation(speedValues)
        let stepStd = standardDeviation(stepLengthValues)

        // 3️⃣ Coefficient of variation (variability)
        let speedCV = speedStd / speedMean
        let stepCV = stepStd / stepMean

        // 4️⃣ Combine CVs → Steadiness (0–100)
        // Lower variability → higher steadiness
        let steadiness = 100 * (1 - ((speedCV + stepCV) / 2))

        // Clamp 0–100
        return max(0, min(steadiness, 100))
    }

    private func standardDeviation(_ values: [Double]) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        return sqrt(variance)
    }
}

// MARK: - Fetch + Compute Steadiness for a Date Range
extension HealthKitManager {

    func fetchWalkingSteadiness(from startDate: Date, to endDate: Date, completion: @escaping (Double?) -> Void) {
        var speeds: [Double] = []
        var stepLengths: [Double] = []

        let group = DispatchGroup()

        group.enter()
        fetchWalkingSpeed(from: startDate, to: endDate) { values in
            speeds = values
            group.leave()
        }

        group.enter()
        fetchStepLength(from: startDate, to: endDate) { values in
            stepLengths = values
            group.leave()
        }

        group.notify(queue: .main) {
            let steadiness = self.calculateWalkingSteadiness(speedValues: speeds, stepLengthValues: stepLengths)
            completion(steadiness)
        }
    }
}
