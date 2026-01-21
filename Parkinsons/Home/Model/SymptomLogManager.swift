// SymptomLogManager.swift

import Foundation

class SymptomLogManager {
    
    static let shared = SymptomLogManager()
    private init() {}
    
    private let logKey = "SymptomLogEntries"
    
    
    func saveLogEntry(_ newEntry: SymptomLogEntry) {
        var allLogs = loadAllLogs()
        let calendar = Calendar.current
        
        allLogs.removeAll { log in
            return calendar.isDate(log.date, inSameDayAs: newEntry.date)
        }
        
        allLogs.append(newEntry)
        
        do {
            let encodedData = try JSONEncoder().encode(allLogs)
            UserDefaults.standard.set(encodedData, forKey: logKey)
        } catch {
           
        }
    }
    func loadAllLogs() -> [SymptomLogEntry] {
        guard let savedData = UserDefaults.standard.data(forKey: logKey) else {
            return []
        }
        
        do {
            let decodedLogs = try JSONDecoder().decode([SymptomLogEntry].self, from: savedData)
            return decodedLogs
        } catch {
            return []
        }
    }

    func getLogEntry(for date: Date) -> SymptomLogEntry? {
        let allLogs = loadAllLogs()
        
        return allLogs.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func getLogForToday() -> SymptomLogEntry? {
        let allLogs = loadAllLogs()
        let today = Date()
        let calendar = Calendar.current
        
        return allLogs.first { log in
            return calendar.isDate(log.date, inSameDayAs: today)
        }
    }
}
