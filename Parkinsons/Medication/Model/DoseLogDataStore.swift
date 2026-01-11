//
//  DoseLogDataStore.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/01/26.
//

import Foundation

final class DoseLogDataStore {

    static let shared = DoseLogDataStore()
    private let storageKey = "dose_logs"

    private(set) var logs: [DoseLog] = []

    private init() { load() }

    func logDose(_ log: DoseLog) {
        logs.append(log)
        save()
    }

    func logs(for day: Date) -> [DoseLog] {
        logs.filter { $0.day == day.startOfDay }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([DoseLog].self, from: data) {
            logs = decoded
        }
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
