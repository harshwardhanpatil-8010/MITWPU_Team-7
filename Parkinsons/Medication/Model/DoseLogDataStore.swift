import Foundation

final class DoseLogDataStore {

    static let shared = DoseLogDataStore()
    private let storageKey = "dose_logs"

    private(set) var logs: [DoseLog] = []

    private init() { load() }

    func logDose(_ log: DoseLog) {
        // Ensure the 'day' property is always normalized to midnight for consistent filtering
        var normalizedLog = log
        normalizedLog.day = log.scheduledTime.startOfDay
        
        logs.append(normalizedLog)
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

    func updateLogStatus(logID: UUID, status: DoseStatus) {
        // We use firstIndex to find the specific log by its ID
        guard let index = logs.firstIndex(where: { $0.id == logID }) else {
            return
        }
        
        // Only update and save if the status actually changed to save CPU cycles
        if logs[index].status != status {
            logs[index].status = status
            save() // Persistence is handled by saving the updated array to UserDefaults
        }
    }
}

