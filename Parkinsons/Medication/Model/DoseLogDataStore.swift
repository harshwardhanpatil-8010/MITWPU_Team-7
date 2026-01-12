import Foundation

final class DoseLogDataStore {

    static let shared = DoseLogDataStore()
    private let storageKey = "dose_logs"

    private(set) var logs: [DoseLog] = []

    private init() { load() }

    // MARK: - Add / Log a dose
    func logDose(_ log: DoseLog) {
        logs.append(log)
        save()
    }

    // MARK: - Fetch logs for a day
    func logs(for day: Date) -> [DoseLog] {
        logs.filter { $0.day == day.startOfDay }
    }

    // MARK: - Persistence
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
        guard let index = logs.firstIndex(where: { $0.id == logID }) else {
            return
        }

        logs[index].status = status
    }

}
