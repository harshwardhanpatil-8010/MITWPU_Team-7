//
//  DailyWorkoutSummaryStore.swift
//  Parkinsons
//
//  Created by SDC-USER on 03/02/26.
//

import CoreData

class DailyWorkoutSummaryStore {
    static let shared = DailyWorkoutSummaryStore()
    private init() {}
    private var context: NSManagedObjectContext {
        PersistenceController.shared.viewContext
    }


    func saveWorkoutSummary() {
        let summary = fetchSummary(for: Date()) ?? DailyWorkoutSummary(context: context)
        summary.date = Date()
        summary.completedCount = Int16(WorkoutManager.shared.completedToday.count)
        summary.skippedCount = Int16(WorkoutManager.shared.skippedToday.count)
        PersistenceController.shared.save()
    }


    func fetchSummary(for date: Date) -> DailyWorkoutSummary? {
        let request: NSFetchRequest<DailyWorkoutSummary> = DailyWorkoutSummary.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}
