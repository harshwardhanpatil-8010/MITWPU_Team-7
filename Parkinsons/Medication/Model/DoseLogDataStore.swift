//
//  DoseLogDataStore.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/01/26.
//

import Foundation
class DoseLogDataStore {
    static let shared = DoseLogDataStore()

    private let storageKey = "dose_logs"
    private(set) var logs: [DoseLog] = []

    private init() {
        load()
    }

    func logDose(_ log: DoseLog) {
        logs.append(log)
        save()
    }

    func logs(for day: Date) -> [DoseLog] {
        let normalized = day.startOfDay
        return logs.filter { $0.day == normalized }
    }

    func isDoseLogged(doseID: UUID, on day: Date) -> Bool {
        let normalized = day.startOfDay
        return logs.contains {
            $0.doseID == doseID && $0.day == normalized
        }
    }
    func updateLogStatus(logID: UUID, newStatus: DoseStatus) {
        if let index = logs.firstIndex(where: { $0.id == logID }) {
            logs[index] = DoseLog(
                id: logs[index].id,
                medicationID: logs[index].medicationID,
                doseID: logs[index].doseID,
                scheduledTime: logs[index].scheduledTime,
                loggedAt: Date(), // update time if needed
                status: newStatus,
                day: logs[index].day
            )
            save()
        }
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
