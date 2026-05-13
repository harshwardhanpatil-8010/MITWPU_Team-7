//  HealthKitManager.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/01/26.
//

import Foundation
import HealthKit

final class HealthKitManager {

    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()

    private init() {}
}


extension HealthKitManager {

    var gaitTypes: Set<HKObjectType> {
        return [
            HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!,
            HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
            HKQuantityType.quantityType(forIdentifier: .appleWalkingSteadiness)! 
        ]
    }

}


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


extension HealthKitManager {
    func fetchWalkingSteadinessSamples(
        from startDate: Date,
        to endDate: Date,
        completion: @escaping ([(Date, Double)]) -> Void
        
    ) {
        

        guard let type = HKObjectType.quantityType(
            forIdentifier: .appleWalkingSteadiness
        ) else {
            completion([])
            return
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: []
        )

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sort]
        ) { _, samples, error in
            if let error = error {
                print("Walking steadiness fetch error:", error.localizedDescription)
                completion([])
                return
            }
            guard let samples = samples as? [HKQuantitySample] else {
                completion([])
                return
            }
            let unit = HKUnit.percent()
            let result = samples.map {
                ($0.startDate, $0.quantity.doubleValue(for: unit))
            }
            print("Walking steadiness: \(result.count) sample(s) found")
            result.forEach { print("  \($0.0): \(String(format: "%.1f", $0.1 * 100))%") }
            completion(result)
        }

        healthStore.execute(query)
    }

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
                $0.quantity.doubleValue(for: .meter())
                
            } ?? []

            completion(values)
        }

        healthStore.execute(query)
    }
}


extension HealthKitManager {

    func calculateWalkingSteadiness(speedValues: [Double], stepLengthValues: [Double]) -> Double? {
        guard !speedValues.isEmpty, !stepLengthValues.isEmpty else { return nil }
        let speedMean = speedValues.reduce(0, +) / Double(speedValues.count)
        let stepMean  = stepLengthValues.reduce(0, +) / Double(stepLengthValues.count)
        let speedCV   = standardDeviation(speedValues) / speedMean
        let stepCV    = standardDeviation(stepLengthValues) / stepMean
        let steadiness = 100 * (1 - ((speedCV + stepCV) / 2))
        return max(0, min(steadiness, 100))
    }

    private func standardDeviation(_ values: [Double]) -> Double {
        let mean     = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        return sqrt(variance)
    }

    func fetchWalkingSpeedSamples(
        from startDate: Date,
        to endDate: Date,
        completion: @escaping ([(Date, Double)]) -> Void
    ) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .walkingSpeed) else {
            completion([]); return
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let query = HKSampleQuery(sampleType: type, predicate: predicate,
                                  limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, samples, _ in
            let pairs = (samples as? [HKQuantitySample])?.map {
                ($0.startDate, $0.quantity.doubleValue(for: .meter().unitDivided(by: .second())))
            } ?? []
            print("Walking speed samples: \(pairs.count)")
            completion(pairs)
        }
        healthStore.execute(query)
    }

    func fetchStepLengthSamples(
        from startDate: Date,
        to endDate: Date,
        completion: @escaping ([(Date, Double)]) -> Void
    ) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .walkingStepLength) else {
            completion([]); return
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let query = HKSampleQuery(sampleType: type, predicate: predicate,
                                  limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, samples, _ in
            let pairs = (samples as? [HKQuantitySample])?.map {
                ($0.startDate, $0.quantity.doubleValue(for: .meter()))
            } ?? []
            print("Step length samples: \(pairs.count)")
            completion(pairs)
        }
        healthStore.execute(query)
    }

    func fetchComputedSteadinessSamples(
        from startDate: Date,
        to endDate: Date,
        completion: @escaping ([(Date, Double)]) -> Void
    ) {
        let group = DispatchGroup()
        var speedSamples: [(Date, Double)] = []
        var stepSamples:  [(Date, Double)] = []

        group.enter()
        fetchWalkingSpeedSamples(from: startDate, to: endDate) { pairs in
            speedSamples = pairs; group.leave()
        }
        group.enter()
        fetchStepLengthSamples(from: startDate, to: endDate) { pairs in
            stepSamples = pairs; group.leave()
        }

        group.notify(queue: .global()) {
            guard !speedSamples.isEmpty || !stepSamples.isEmpty else {
                completion([]); return
            }

            let cal = Calendar.current

            func bucket(_ pairs: [(Date, Double)]) -> [Date: [Double]] {
                Dictionary(grouping: pairs) { cal.startOfDay(for: $0.0) }
                    .mapValues { $0.map { $0.1 } }
            }

            let speedByDay = bucket(speedSamples)
            let stepByDay  = bucket(stepSamples)

            let allDays = Set(speedByDay.keys).union(stepByDay.keys).sorted()

            var results: [(Date, Double)] = []

            for day in allDays {
                let speeds = speedByDay[day] ?? []
                let steps  = stepByDay[day]  ?? []

                let value: Double
                if speeds.count >= 2 && steps.count >= 2 {
                    let sMean = speeds.reduce(0,+)/Double(speeds.count)
                    let lMean = steps.reduce(0,+)/Double(steps.count)
                    let sCV   = self.standardDeviation(speeds) / sMean
                    let lCV   = self.standardDeviation(steps)  / lMean
                    value = max(0, min(100 * (1 - (sCV + lCV) / 2), 100))
                } else if speeds.count >= 2 {
                    let sMean = speeds.reduce(0,+)/Double(speeds.count)
                    let sCV   = self.standardDeviation(speeds) / sMean
                    value = max(0, min(100 * (1 - sCV), 100))
                } else if steps.count >= 2 {
                    let lMean = steps.reduce(0,+)/Double(steps.count)
                    let lCV   = self.standardDeviation(steps) / lMean
                    value = max(0, min(100 * (1 - lCV), 100))
                } else {
                    let v = (speeds + steps).first ?? 0
                    value = speeds.isEmpty ? max(0, min(v / 0.8 * 100, 100))
                                           : max(0, min(v / 2.0 * 100, 100))
                }
                results.append((day, value))
            }

            print("Computed steadiness points: \(results.count)")
            results.forEach { print("  \($0.0): \(String(format: "%.1f", $0.1))") }
            completion(results)
        }
    }

    func fetchWalkingSteadiness(from startDate: Date, to endDate: Date, completion: @escaping (Double?) -> Void) {
        var speeds: [Double] = []
        var stepLengths: [Double] = []
        let group = DispatchGroup()
        group.enter()
        fetchWalkingSpeed(from: startDate, to: endDate) { speeds = $0; group.leave() }
        group.enter()
        fetchStepLength(from: startDate, to: endDate) { stepLengths = $0; group.leave() }
        group.notify(queue: .main) {
            completion(self.calculateWalkingSteadiness(speedValues: speeds, stepLengthValues: stepLengths))
        }
    }
}
