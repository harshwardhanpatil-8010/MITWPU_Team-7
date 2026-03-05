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


    func saveWorkoutSummary(for date: Date = Date()) {
        let summary = fetchSummary(for: date) ?? DailyWorkoutSummary(context: context)
        let manager = WorkoutManager.shared
        let startOfDay = Calendar.current.startOfDay(for: date)
        let allExercises = manager.exercises
        let completedIDs = manager.completedToday
        let skippedIDs = manager.skippedToday

        let nameByID = Dictionary(uniqueKeysWithValues: allExercises.map { ($0.id, $0.name) })
        let completedNames = completedIDs.compactMap { nameByID[$0] }
        let skippedNames = skippedIDs.compactMap { nameByID[$0] }

        summary.date = startOfDay
        summary.totalExercises = Int16(allExercises.count)
        summary.completedCount = Int16(completedIDs.count)
        summary.skippedCount = Int16(skippedIDs.count)
        summary.completedExerciseIDs = completedIDs.map(\.uuidString) as NSArray
        summary.skippedExerciseIDs = skippedIDs.map(\.uuidString) as NSArray
        summary.completedExerciseNames = completedNames as NSArray
        summary.skippedExerciseNames = skippedNames as NSArray
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

    func completedExerciseNames(for date: Date) -> [String] {
        let raw = fetchSummary(for: date)?.completedExerciseNames as? [String]
        return raw ?? []
    }

    func skippedExerciseNames(for date: Date) -> [String] {
        let raw = fetchSummary(for: date)?.skippedExerciseNames as? [String]
        return raw ?? []
    }
}
