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
    func fetchSamples(for range: TremorRange) -> [TremorSample] {
        let allSamples = fetchAll()
        let calendar = Calendar.current
        let now = Date()

        switch range {

        case .day:
            return allSamples.filter {
                calendar.isDate($0.date, inSameDayAs: now)
            }

        case .week:
            guard let start = calendar.date(byAdding: .day, value: -6, to: now) else { return [] }
            return allSamples.filter { $0.date >= start }

        case .month:
            guard let start = calendar.date(byAdding: .month, value: -1, to: now) else { return [] }
            return allSamples.filter { $0.date >= start }

        case .sixMonth:
            guard let start = calendar.date(byAdding: .month, value: -6, to: now) else { return [] }
            return allSamples.filter { $0.date >= start }

        case .year:
            guard let start = calendar.date(byAdding: .year, value: -1, to: now) else { return [] }
            return allSamples.filter { $0.date >= start }
        }
    }


    // MARK: - Save new sample
    func save(_ sample: TremorSample) {
        var all = fetchAll()
        all.append(sample)
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}


