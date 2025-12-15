//
//  DataStore.swift
//  Parkinsons
//
//  Created by SDC-USER on 25/11/25.
//

import Foundation


//--------------------------------Rhythmic Walking--------------------------------------------------------



class DataStore {
    static let shared = DataStore()
    private let sessionsKey = "rhythmic_sessions_v1"
    private let lastCleanupKey = "rhythmic_sessions_last_cleanup"   // NEW
    
    private init() {
        load()
        autoCleanupIfNeeded()      // NEW: auto-clean on startup
    }
    
    private(set) var sessions: [RhythmicSession] = []
    
    // ADD SESSION
    func add(_ session: RhythmicSession) {
        sessions.insert(session, at: 0)
        save()
    }
    
    // UPDATE SESSION
    func update(_ session: RhythmicSession) {
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
            save()
        }
    }
    
    // SAVE TO USERDEFAULTS
    private func save() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: sessionsKey)
        } catch {
            print("Failed to save sessions: \(error)")
        }
    }
    
    // LOAD FROM USERDEFAULTS
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey) else { return }
        do {
            sessions = try JSONDecoder().decode([RhythmicSession].self, from: data)
        } catch {
            print("Failed to load sessions: \(error)")
        }
    }
    
    
    // --------------------------------------------------------------
    // MARK: - DAILY CLEANUP (IMPORTANT)
    // --------------------------------------------------------------
    
    /// Removes sessions older than today
    func cleanupOldSessions() {          // NEW
        let calendar = Calendar.current
        
        sessions = sessions.filter {
            calendar.isDateInToday($0.startDate)
        }
        
        save()
        UserDefaults.standard.set(Date(), forKey: lastCleanupKey)
    }
    
    
    /// Automatically runs cleanup when the app starts or user opens screen
    private func autoCleanupIfNeeded() {     // NEW
        let calendar = Calendar.current
        
        let lastRun = UserDefaults.standard.object(forKey: lastCleanupKey) as? Date
        
        // If never run before → run now
        guard let lastRun else {
            cleanupOldSessions()
            return
        }
        
        // If last cleanup was not today → run again
        if !calendar.isDateInToday(lastRun) {
            cleanupOldSessions()
        }
    }
}
//------------------------------------------------------------------------------------------------------------------------------------------
