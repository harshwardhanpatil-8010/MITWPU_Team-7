//
//  SymptomDataStore.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 26/12/25.
//

import Foundation

// MARK: - Symptom Model
struct SymptomLog: Codable {
    let date: Date
    var tremorLevel: Int?
    var gaitRange: ClosedRange<Int>?
    var loggedSymptoms: [String]
}

// MARK: - Symptom Data Store
final class SymptomDataStore {
    
    static let shared = SymptomDataStore()
    private init() { load() }

    private(set) var logs: [Date: SymptomLog] = [:]

    private let storageKey = "symptom_logs"
    
    func addLog(_ log: SymptomLog) {
        logs.append(log)
        save()
    }

    func logs(for date: Date) -> [SymptomLog] {
        let calendar = Calendar.current
        return logs.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }
    }

    // MARK: - Save / Update
    func saveLog(_ log: SymptomLog) {
        let day = Calendar.current.startOfDay(for: log.date)
        logs[day] = log
        persist()
    }

    // MARK: - Fetch for calendar day
    func log(for date: Date) -> SymptomLog? {
        let day = Calendar.current.startOfDay(for: date)
        return logs[day]
    }

    // MARK: - Persistence
    private func save() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SymptomLog].self, from: data) else {
            return
        }
        logs = decoded
    }

}
