// SymptomLogManager.swift

import Foundation

class SymptomLogManager {
    
    static let shared = SymptomLogManager()
    private init() {} // Singleton
    
    private let logKey = "SymptomLogEntries"
    
    // NOTE: Your models (SymptomRating and SymptomLogEntry) MUST be Codable
    // for JSONEncoder/Decoder to work. (Assume this is fixed based on previous steps.)
    
    // MARK: - Saving Data
    
    func saveLogEntry(_ newEntry: SymptomLogEntry) {
        var allLogs = loadAllLogs()
        let calendar = Calendar.current
        
        // 1. Overwrite any existing log for today
        allLogs.removeAll { log in
            return calendar.isDate(log.date, inSameDayAs: newEntry.date)
        }
        
        // 2. Add the new log entry
        allLogs.append(newEntry)
        
        // 3. Encode and save
        do {
            let encodedData = try JSONEncoder().encode(allLogs)
            UserDefaults.standard.set(encodedData, forKey: logKey)
            print("✅ SymptomLogManager: Successfully saved log entry for today.")
        } catch {
            print("❌ SymptomLogManager: Failed to encode/save symptom logs: \(error)")
        }
    }
    
    // MARK: - Loading Data
    
    func loadAllLogs() -> [SymptomLogEntry] {
        guard let savedData = UserDefaults.standard.data(forKey: logKey) else {
            return []
        }
        
        do {
            let decodedLogs = try JSONDecoder().decode([SymptomLogEntry].self, from: savedData)
            return decodedLogs
        } catch {
            print("❌ SymptomLogManager: Failed to decode symptom logs: \(error)")
            return []
        }
    }
    
    // MARK: - Specific Log Retrieval
    
    func getLogForToday() -> SymptomLogEntry? {
        let allLogs = loadAllLogs()
        let today = Date()
        let calendar = Calendar.current
        
        return allLogs.first { log in
            // Compares date component (year, month, day) ignoring time
            return calendar.isDate(log.date, inSameDayAs: today)
        }
    }
}
