//
//  DataStore.swift
//  Parkinsons
//
//  Created by SDC-USER on 25/11/25.
//

import Foundation

class DataStore {
    static let shared = DataStore()
    private let sessionsKey = "rhythmic_sessions_v1"
    private let lastCleanupKey = "rhythmic_sessions_last_cleanup"
    
    private init() {
        load()
        autoCleanupIfNeeded()
    }
    
    private(set) var sessions: [RhythmicSession] = []
    

    func add(_ session: RhythmicSession) {
        sessions.insert(session, at: 0)
        save()
    }
    

    func update(_ session: RhythmicSession) {
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
            save()
        }
    }
    

    private func save() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: sessionsKey)
        } catch {
            print("Failed to save sessions: \(error)")
        }
    }
    

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey) else { return }
        do {
            sessions = try JSONDecoder().decode([RhythmicSession].self, from: data)
        } catch {
            print("Failed to load sessions: \(error)")
        }
    }

    func cleanupOldSessions() {
        let calendar = Calendar.current
        
        sessions = sessions.filter {
            calendar.isDateInToday($0.startDate)
        }
        
        save()
        UserDefaults.standard.set(Date(), forKey: lastCleanupKey)
    }
    

    private func autoCleanupIfNeeded() {    
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
