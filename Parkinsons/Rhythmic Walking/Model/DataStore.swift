//
//  DataStore.swift
//  Parkinsons
//
//  Created by SDC-USER on 25/11/25.
//
//
import Foundation

//class DataStore {
//    static let shared = DataStore()
//    private let sessionsKey = "rhythmic_sessions_v1"
//    private let dailyGoalKey = "rhythmic_daily_goal_id"
//    private let lastCleanupKey = "rhythmic_sessions_last_cleanup"
//    
//    private init() {
//        load()
//        autoCleanupIfNeeded()
//    }
//    
//    private(set) var sessions: [RhythmicSession] = []
//    
//
//    func add(_ session: RhythmicSession) {
//        sessions.insert(session, at: 0)
//        save()
//    }
//    
//
//    func update(_ session: RhythmicSession) {
//        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
//            sessions[idx] = session
//            save()
//        }
//    }
//    
//
//    private func save() {
//        do {
//            let data = try JSONEncoder().encode(sessions)
//            UserDefaults.standard.set(data, forKey: sessionsKey)
//        } catch {
//            print("Failed to save sessions: \(error)")
//        }
//    }
//    
//
//    private func load() {
//        guard let data = UserDefaults.standard.data(forKey: sessionsKey) else { return }
//        do {
//            sessions = try JSONDecoder().decode([RhythmicSession].self, from: data)
//        } catch {
//            print("Failed to load sessions: \(error)")
//        }
//    }
//    var dailyGoalSession: RhythmicSession? {
//        let goalIDString = UserDefaults.standard.string(forKey: dailyGoalKey)
//        return sessions.first(where: { $0.id.uuidString == goalIDString })
//    }
//
//    func setAsDailyGoal(_ session: RhythmicSession) {
//        UserDefaults.standard.set(session.id.uuidString, forKey: dailyGoalKey)
//    }
//
//    func cleanupOldSessions() {
//        let calendar = Calendar.current
//        
//        sessions = sessions.filter {
//            calendar.isDateInToday($0.startDate)
//        }
//        
//        save()
//        UserDefaults.standard.set(Date(), forKey: lastCleanupKey)
//    }
//    
//
//    private func autoCleanupIfNeeded() {    
//        let calendar = Calendar.current
//        
//        let lastRun = UserDefaults.standard.object(forKey: lastCleanupKey) as? Date
// 
//        guard let lastRun else {
//            cleanupOldSessions()
//            return
//        }
//        
//      
//        if !calendar.isDateInToday(lastRun) {
//            cleanupOldSessions()
//        }
//    }
//}


import CoreData

class DataStore {
    static let shared = DataStore()
    private init() {}
    
    private var context: NSManagedObjectContext {
        PersistenceController.shared.viewContext
    }
    
    // MARK: - Fetch all sessions (today's)
    var sessions: [RhythmicSessionDTO] {
        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(
            format: "startDate >= %@ AND startDate < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        
        let managed = (try? context.fetch(request)) ?? []
        return managed.enumerated().map { index, obj in
            RhythmicSessionDTO(from: obj, sessionNumber: index + 1)
        }
    }
    
    // MARK: - Add new session
    func add(_ dto: RhythmicSessionDTO) {
        let managed = RhythmicSession(context: context)
        managed.id               = dto.id
        managed.startDate        = dto.startDate
        managed.endDate          = dto.endDate
        managed.requestedDuration = Int32(dto.requestedDurationSeconds)
        managed.elapsedSeconds   = Int32(dto.elapsedSeconds)
        dto.saveExtras()
        PersistenceController.shared.save()
    }
    
    // MARK: - Update existing session
    func update(_ dto: RhythmicSessionDTO) {
        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", dto.id as CVarArg)
        guard let managed = try? context.fetch(request).first else { return }
        managed.endDate           = dto.endDate
        managed.elapsedSeconds    = Int32(dto.elapsedSeconds)
        managed.requestedDuration = Int32(dto.requestedDurationSeconds)
        dto.saveExtras()
        PersistenceController.shared.save()
    }
    
    // MARK: - Daily goal session (first session >= 10 min today)
    var dailyGoalSession: RhythmicSessionDTO? {
        sessions.first { $0.requestedDurationSeconds >= 600 }
    }
    
    // No-op: dailyGoalSession is computed from persisted sessions
    func setAsDailyGoal(_ dto: RhythmicSessionDTO) {}
    
    // No-op: keep history, or add deletion logic if desired
    func cleanupOldSessions() {}
    
    func printAllSessions() {
        let all = sessions
        print("=== Core Data Sessions: \(all.count) ===")
        for s in all {
            print("  ID: \(s.id) | Start: \(s.startDate) | Elapsed: \(s.elapsedSeconds)s | Beat: \(s.beat) | Pace: \(s.pace)")
        }
    }
}
