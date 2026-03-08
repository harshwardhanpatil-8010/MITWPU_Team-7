
import Foundation
import CoreData

final class DataStore {
    static let shared = DataStore()
    private init() {}

    private var context: NSManagedObjectContext {
        PersistenceController.shared.viewContext
    }

    var sessions: [RhythmicSessionDTO] {
        fetchSessions(for: Date())
    }

    var allSessions: [RhythmicSessionDTO] {
        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        let managed = (try? context.fetch(request)) ?? []
        return managed.enumerated().map { idx, obj in
            RhythmicSessionDTO(from: obj, sessionNumber: idx + 1)
        }
    }

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

    func cachedSummary(for session: RhythmicSessionDTO) -> GaitSummary? {
        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        guard let managed = (try? context.fetch(request))?.first else { return nil }
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

    var dailyGoalSession: RhythmicSessionDTO? {
        sessions.first { $0.requestedDurationSeconds >= 600
                      && $0.elapsedSeconds < $0.requestedDurationSeconds }
    }

    func setAsDailyGoal(_ dto: RhythmicSessionDTO) {}
    func cleanupOldSessions() {}

    func printAllSessions() {
        print("=== Core Data Sessions: \(allSessions.count) total ===")
        for s in allSessions {
            print("  [\(s.startDate)] #\(s.sessionNumber) elapsed:\(s.elapsedSeconds)s")
        }
    }
}
