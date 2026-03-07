////
////  DataStore.swift
////  Parkinsons
////
////  Created by SDC-USER on 25/11/25.
////
////
//import Foundation
//
////class DataStore {
////    static let shared = DataStore()
////    private let sessionsKey = "rhythmic_sessions_v1"
////    private let dailyGoalKey = "rhythmic_daily_goal_id"
////    private let lastCleanupKey = "rhythmic_sessions_last_cleanup"
////    
////    private init() {
////        load()
////        autoCleanupIfNeeded()
////    }
////    
////    private(set) var sessions: [RhythmicSession] = []
////    
////
////    func add(_ session: RhythmicSession) {
////        sessions.insert(session, at: 0)
////        save()
////    }
////    
////
////    func update(_ session: RhythmicSession) {
////        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
////            sessions[idx] = session
////            save()
////        }
////    }
////    
////
////    private func save() {
////        do {
////            let data = try JSONEncoder().encode(sessions)
////            UserDefaults.standard.set(data, forKey: sessionsKey)
////        } catch {
////            print("Failed to save sessions: \(error)")
////        }
////    }
////    
////
////    private func load() {
////        guard let data = UserDefaults.standard.data(forKey: sessionsKey) else { return }
////        do {
////            sessions = try JSONDecoder().decode([RhythmicSession].self, from: data)
////        } catch {
////            print("Failed to load sessions: \(error)")
////        }
////    }
////    var dailyGoalSession: RhythmicSession? {
////        let goalIDString = UserDefaults.standard.string(forKey: dailyGoalKey)
////        return sessions.first(where: { $0.id.uuidString == goalIDString })
////    }
////
////    func setAsDailyGoal(_ session: RhythmicSession) {
////        UserDefaults.standard.set(session.id.uuidString, forKey: dailyGoalKey)
////    }
////
////    func cleanupOldSessions() {
////        let calendar = Calendar.current
////        
////        sessions = sessions.filter {
////            calendar.isDateInToday($0.startDate)
////        }
////        
////        save()
////        UserDefaults.standard.set(Date(), forKey: lastCleanupKey)
////    }
////    
////
////    private func autoCleanupIfNeeded() {    
////        let calendar = Calendar.current
////        
////        let lastRun = UserDefaults.standard.object(forKey: lastCleanupKey) as? Date
//// 
////        guard let lastRun else {
////            cleanupOldSessions()
////            return
////        }
////        
////      
////        if !calendar.isDateInToday(lastRun) {
////            cleanupOldSessions()
////        }
////    }
////}
//
//
//import CoreData
//
//class DataStore {
//    static let shared = DataStore()
//    private init() {}
//    
//    private var context: NSManagedObjectContext {
//        PersistenceController.shared.viewContext
//    }
//    
//    // MARK: - Fetch all sessions (today's)
//    var sessions: [RhythmicSessionDTO] {
//        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: Date())
//        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
//        request.predicate = NSPredicate(
//            format: "startDate >= %@ AND startDate < %@",
//            startOfDay as NSDate,
//            endOfDay as NSDate
//        )
//        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
//        
//        let managed = (try? context.fetch(request)) ?? []
//        return managed.enumerated().map { index, obj in
//            RhythmicSessionDTO(from: obj, sessionNumber: index + 1)
//        }
//    }
//    
//    // MARK: - Add new session
//    func add(_ dto: RhythmicSessionDTO) {
//        let managed = RhythmicSession(context: context)
//        managed.id               = dto.id
//        managed.startDate        = dto.startDate
//        managed.endDate          = dto.endDate
//        managed.requestedDuration = Int32(dto.requestedDurationSeconds)
//        managed.elapsedSeconds   = Int32(dto.elapsedSeconds)
//        dto.saveExtras()
//        PersistenceController.shared.save()
//    }
//    
//    // MARK: - Update existing session
//    func update(_ dto: RhythmicSessionDTO) {
//        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %@", dto.id as CVarArg)
//        guard let managed = try? context.fetch(request).first else { return }
//        managed.endDate           = dto.endDate
//        managed.elapsedSeconds    = Int32(dto.elapsedSeconds)
//        managed.requestedDuration = Int32(dto.requestedDurationSeconds)
//        dto.saveExtras()
//        PersistenceController.shared.save()
//    }
//    
//    // MARK: - Daily goal session (first session >= 10 min today)
//    var dailyGoalSession: RhythmicSessionDTO? {
//        sessions.first { $0.requestedDurationSeconds >= 600 }
//    }
//    
//    // No-op: dailyGoalSession is computed from persisted sessions
//    func setAsDailyGoal(_ dto: RhythmicSessionDTO) {}
//    
//    // No-op: keep history, or add deletion logic if desired
//    func cleanupOldSessions() {}
//    
//    func printAllSessions() {
//        let all = sessions
//        print("=== Core Data Sessions: \(all.count) ===")
//        for s in all {
//            print("  ID: \(s.id) | Start: \(s.startDate) | Elapsed: \(s.elapsedSeconds)s | Beat: \(s.beat) | Pace: \(s.pace)")
//        }
//    }
//}




//
//  DataStore.swift
//  Parkinsons
//

import Foundation
import CoreData

final class DataStore {
    static let shared = DataStore()
    private init() {}

    private var context: NSManagedObjectContext {
        PersistenceController.shared.viewContext
    }

    // MARK: - Today's sessions

    var sessions: [RhythmicSessionDTO] {
        fetchSessions(for: Date())
    }

    // MARK: - All-time sessions

    var allSessions: [RhythmicSessionDTO] {
        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        let managed = (try? context.fetch(request)) ?? []
        return managed.enumerated().map { idx, obj in
            RhythmicSessionDTO(from: obj, sessionNumber: idx + 1)
        }
    }

    // MARK: - Sessions for a specific date

    func fetchSessions(for date: Date) -> [RhythmicSessionDTO] {
        let calendar = Calendar.current
        let start    = calendar.startOfDay(for: date)
        let end      = calendar.date(byAdding: .day, value: 1, to: start)!
        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
        request.predicate       = NSPredicate(format: "startDate >= %@ AND startDate < %@",
                                              start as NSDate, end as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        let managed = (try? context.fetch(request)) ?? []
        return managed.enumerated().map { idx, obj in
            RhythmicSessionDTO(from: obj, sessionNumber: idx + 1)
        }
    }

    // MARK: - Cached HealthKit summary (instant, from Core Data)

    /// Returns a GaitSummary built from the HealthKit values already saved in
    /// Core Data for this session. Returns nil if no data has been saved yet
    /// (steps == 0 and all doubles are 0).
    /// Use this to populate the Summary screen immediately, then refresh once
    /// the live HealthKit fetch completes.
    func cachedSummary(for session: RhythmicSessionDTO) -> GaitSummary? {
        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        guard let managed = (try? context.fetch(request))?.first else { return nil }

        // Only return cached data if something meaningful has been stored
        guard managed.steps > 0 || managed.distanceMeters > 0 else { return nil }

        let durationHours = Double(session.elapsedSeconds) / 3600.0
        let speed = durationHours > 0
            ? (managed.distanceMeters / 1000.0) / durationHours : 0.0

        return GaitSummary(
            steps:                   Int(managed.steps),
            distanceMeters:          managed.distanceMeters,
            speedKmH:                speed,
            stepLengthMeters:        managed.stepLengthMeters,
            walkingAsymmetryPercent: managed.walkingAsymmetry,
            walkingSteadiness:       classifySteadiness(managed.walkingSteadiness)
        )
    }

    private func classifySteadiness(_ value: Double) -> String {
        if value >= 67 { return "OK" }
        if value >= 45 { return "Low" }
        return value > 0 ? "Very Low" : "No data"
    }

    // MARK: - Previous session for change% comparison

    func previousSession(before session: RhythmicSessionDTO) -> RhythmicSession? {
        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
        request.predicate = NSPredicate(
            format: "startDate < %@ AND id != %@ AND steps > 0",
            session.startDate as NSDate,
            session.id as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        request.fetchLimit = 1
        return (try? context.fetch(request))?.first
    }

    // MARK: - Add / Update

    func add(_ dto: RhythmicSessionDTO) {
        let managed               = RhythmicSession(context: context)
        managed.id                = dto.id
        managed.startDate         = dto.startDate
        managed.endDate           = dto.endDate
        managed.requestedDuration = Int32(dto.requestedDurationSeconds)
        managed.elapsedSeconds    = Int32(dto.elapsedSeconds)
        dto.saveExtras()
        PersistenceController.shared.save()
    }

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

    // MARK: - Daily goal

    var dailyGoalSession: RhythmicSessionDTO? {
        sessions.first { $0.requestedDurationSeconds >= 600
                      && $0.elapsedSeconds < $0.requestedDurationSeconds }
    }

    func setAsDailyGoal(_ dto: RhythmicSessionDTO) {}
    func cleanupOldSessions() {}

    // MARK: - Debug

    func printAllSessions() {
        print("=== Core Data Sessions: \(allSessions.count) total ===")
        for s in allSessions {
            print("  [\(s.startDate)] #\(s.sessionNumber) elapsed:\(s.elapsedSeconds)s")
        }
    }
}
