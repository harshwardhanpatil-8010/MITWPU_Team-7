//
//  TremorStorage.swift
//  Parkinsons
//
//  Created by SDC-USER on 03/02/26.
//
import Foundation

struct TremorSample: Codable {
    let date: Date
    let frequencyHz: Double
}

import Foundation

final class TremorDataStore {

    static let shared = TremorDataStore()
    private let key = "tremor_samples"

    private init() {}

    // MARK: - Fetch all samples
    func fetchAll() -> [TremorSample] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let samples = try? JSONDecoder().decode([TremorSample].self, from: data)
        else {
            return []
        }
        return samples.sorted { $0.date < $1.date }
    }
    func fetchSamples(for date: Date) -> [TremorSample] {
        let calendar = Calendar.current
        return fetchAll().filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }
    }

    func fetchSamples(for range: TremorRange, referenceDate: Date) -> [TremorSample] {
        let all = fetchAll()
        let calendar = Calendar.current

        let startDate: Date
        let endDate: Date

        switch range {
        case .day:
            startDate = calendar.startOfDay(for: referenceDate)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        case .week:
            endDate = calendar.date(byAdding: .day, value: 1, to: referenceDate)!
            startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!

        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: referenceDate))!
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!

        case .sixMonth:
            endDate = calendar.date(byAdding: .day, value: 1, to: referenceDate)!
            startDate = calendar.date(byAdding: .month, value: -6, to: endDate)!

        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: referenceDate))!
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate)!
        }

        return all.filter { $0.date >= startDate && $0.date < endDate }
    }


    // MARK: - Save new sample
    func save(_ sample: TremorSample) {
        var all = fetchAll()

        // Prevent saving multiple samples within 1 minute
        if let last = all.last,
           abs(last.date.timeIntervalSince(sample.date)) < 60 {
            return
        }

        all.append(sample)

        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

}


